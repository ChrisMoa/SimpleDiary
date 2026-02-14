#!/usr/bin/env python3
"""
Translation Coverage Checker for SimpleDiary (Flutter/Dart)

Scans all .dart files under lib/ for hardcoded user-facing strings that should
be localized. Reports them grouped by file with severity, suggested l10n key,
and a summary table.

Usage:
    python3 tools/check_translations.py
    python3 tools/check_translations.py --json          # machine-readable output
    python3 tools/check_translations.py --severity HIGH # filter by severity
"""

import argparse
import json
import os
import re
import sys
from dataclasses import dataclass, field, asdict
from enum import Enum
from pathlib import Path
from typing import Optional


# ──────────────────────────────────────────────────────────────────────
# Configuration
# ──────────────────────────────────────────────────────────────────────

PROJECT_ROOT = Path(__file__).resolve().parent.parent
LIB_DIR = PROJECT_ROOT / "lib"
ARB_FILE = PROJECT_ROOT / "lib" / "l10n" / "app_en.arb"

# Directories / files to skip entirely
SKIP_DIRS = {
    "l10n",           # generated localisation files
    ".dart_tool",
}
SKIP_FILES = {
    "app_localizations.dart",
    "app_localizations_de.dart",
    "app_localizations_en.dart",
    "app_localizations_es.dart",
    "app_localizations_fr.dart",
}


class Severity(str, Enum):
    CRITICAL = "CRITICAL"  # user-facing text in buttons, dialogs, snackbars
    HIGH = "HIGH"          # labels, hints, titles
    MEDIUM = "MEDIUM"      # tooltips, empty-state descriptions
    LOW = "LOW"            # unlikely user-facing or borderline


class StringContext(str, Enum):
    """Where the hardcoded string was found."""
    TEXT_WIDGET = "Text widget"
    BUTTON_LABEL = "Button label"
    DIALOG_TITLE = "Dialog title"
    DIALOG_CONTENT = "Dialog content"
    SNACKBAR = "SnackBar message"
    INPUT_LABEL = "InputDecoration label"
    INPUT_HINT = "InputDecoration hint"
    TOOLTIP = "Tooltip"
    APPBAR_TITLE = "AppBar title"
    VALIDATOR = "Validator message"
    SNACKBAR_ACTION = "SnackBar action label"
    TAB_TEXT = "Tab text"
    SECTION_HEADER = "Section header"
    GENERIC = "Literal string"


@dataclass
class HardcodedString:
    file: str           # relative path from project root
    line: int
    column: int
    raw_string: str     # the literal value
    context: StringContext
    severity: Severity
    existing_key: Optional[str] = None     # if a matching ARB key exists
    suggested_key: Optional[str] = None    # proposed new key name


@dataclass
class FileReport:
    path: str
    total_strings: int = 0
    localized_strings: int = 0
    hardcoded: list = field(default_factory=list)


# ──────────────────────────────────────────────────────────────────────
# Load existing ARB keys + values for matching
# ──────────────────────────────────────────────────────────────────────

def load_arb_strings(arb_path: Path) -> dict[str, str]:
    """Return {key: english_value} from the ARB file."""
    if not arb_path.exists():
        print(f"WARNING: ARB file not found at {arb_path}", file=sys.stderr)
        return {}
    with open(arb_path, "r", encoding="utf-8") as f:
        data = json.load(f)
    return {k: v for k, v in data.items() if not k.startswith("@")}


def build_reverse_arb(arb: dict[str, str]) -> dict[str, str]:
    """Map normalised english value -> arb key for quick matching."""
    rev = {}
    for k, v in arb.items():
        if k.startswith("@@"):
            continue
        # Normalise: lowercase, strip outer whitespace, collapse inner ws
        norm = re.sub(r"\s+", " ", v.strip().lower())
        rev[norm] = k
    return rev


# ──────────────────────────────────────────────────────────────────────
# False-positive filters
# ──────────────────────────────────────────────────────────────────────

# Strings that are intentionally NOT translated
FALSE_POSITIVE_PATTERNS = [
    # Logging – LogWrapper / logger calls
    r"LogWrapper\.logger\.\w+\(",
    r"logger\.\w+\(",
    r"debugPrint\(",
    r"print\(",

    # Keys, identifiers, technical strings
    r"Key\(",
    r"ValueKey\(",
    r"tableName:",
    r"primaryKey:",
    r"columnName:",
    r"SharedPreferences",

    # Database / SQL
    r"CREATE\s+TABLE",
    r"INSERT\s+INTO",
    r"SELECT\s+",
    r"ALTER\s+TABLE",
    r"DROP\s+TABLE",
    r"database\!\.execute",

    # Map keys, JSON keys
    r"\[.+\]\s*=",
    r"map\[",

    # Assert messages (not user-facing)
    r"assert\(",

    # Import / export / package references
    r"^import\s",
    r"^export\s",
    r"package:",

    # Route names
    r"MaterialPageRoute",
    r"Navigator\.",

    # dotenv / env keys
    r"dotenv",
    r"\.env",

    # Font families, asset paths
    r"assets/",
    r"google_fonts",

    # Test file strings
    r"test\(",
    r"expect\(",
    r"group\(",

    # Error/exception throws (not user-facing)
    r"throw\s+",
    r"Exception\(",
    r"Error\(",
    r"FormatException\(",
    r"StateError\(",

    # Status update strings in non-presentation code
    r"setState\s*\(\s*\(\)\s*\{.*_status\s*=",
]

# Strings that are never user-facing
IGNORED_STRING_VALUES = {
    "",
    " ",
    "  ",
    ".",
    ",",
    ":",
    ";",
    "-",
    "/",
    "|",
    "\\n",
    "\n",
    "0",
    "1",
    "true",
    "false",
    "null",
    "id",
    "title",
    "description",
    "day",
    "notes",
    "ratings",
    "color",
    "tagList",
    "fromDate",
    "toDate",
    "isAllDay",
    "noteCategory",
    "username",
    "password",
    "email",
    "passwordHash",
    "isLoggedIn",
    "darkThemeMode",
    "themeSeedColor",
}

# Regex for strings that look like identifiers or technical values
TECHNICAL_PATTERNS = [
    r"^[a-z][a-zA-Z0-9_]*[A-Z_][a-zA-Z0-9_]*$",  # camelCase identifier (must have uppercase/underscore)
    r"^[A-Z][A-Z0-9_]+$",          # SCREAMING_SNAKE (constants)
    r"^[a-z_]+\.[a-z_]+",          # dot.notation
    r"^\$",                          # string interpolation start
    r"^https?://",                   # URLs
    r"^[\d\.\-\+:\/]+$",           # numbers, dates, times
    r"^[^\w\s]+$",                  # pure punctuation/symbols
    r"^\w+\.dart$",                 # file names
    r"^%",                          # format patterns
    r"^[dMyHhms\.\-/:, ]+$",       # date/time format patterns (dd.MM.yyyy etc.)
    r"^\.\w{1,5}$",                # file extensions (.json, .ics, .env)
    r"^[a-zA-Z]+_\$\{",            # template filenames (data_export_${...})
    r"^[a-zA-Z0-9_]+\.[a-zA-Z]+$",  # filenames (settings.json)
    r"^[a-z]+://",                  # URI schemes
    r"^/storage/",                  # Android storage paths
    r"^/data/",                     # Android data paths
    r"^\w+/\w+",                    # path-like strings
]


# ──────────────────────────────────────────────────────────────────────
# Context detection — what kind of UI element contains this string?
# ──────────────────────────────────────────────────────────────────────

# Patterns that look backwards from the string to determine context.
# Order matters — first match wins.
CONTEXT_RULES: list[tuple[re.Pattern, StringContext, Severity]] = [
    # SnackBar action labels  (SnackBarAction(label: '...'
    (re.compile(r"SnackBarAction\s*\(\s*label:\s*$"), StringContext.SNACKBAR_ACTION, Severity.CRITICAL),

    # SnackBar content  (content: Text('...'
    (re.compile(r"SnackBar\b.*content:\s*(?:const\s+)?Text\s*\(\s*$", re.DOTALL),
        StringContext.SNACKBAR, Severity.CRITICAL),
    # Catch simpler SnackBar content patterns
    (re.compile(r"showSnackBar\b.*?Text\s*\(\s*$", re.DOTALL),
        StringContext.SNACKBAR, Severity.CRITICAL),

    # AlertDialog / Dialog title
    (re.compile(r"title:\s*(?:const\s+)?Text\s*\(\s*$"),
        StringContext.DIALOG_TITLE, Severity.CRITICAL),

    # AlertDialog / Dialog content
    (re.compile(r"content:\s*(?:const\s+)?Text\s*\(\s*$"),
        StringContext.DIALOG_CONTENT, Severity.CRITICAL),

    # AppBar title
    (re.compile(r"AppBar\s*\(.*?title:\s*(?:const\s+)?Text\s*\(\s*$", re.DOTALL),
        StringContext.APPBAR_TITLE, Severity.CRITICAL),

    # Button child: const Text('...')
    (re.compile(r"(?:ElevatedButton|TextButton|OutlinedButton|FilledButton)"
                r".*?child:\s*(?:const\s+)?Text\s*\(\s*$", re.DOTALL),
        StringContext.BUTTON_LABEL, Severity.CRITICAL),
    # Button label: const Text('...')  (for .icon constructors)
    (re.compile(r"label:\s*(?:const\s+)?Text\s*\(\s*$"),
        StringContext.BUTTON_LABEL, Severity.CRITICAL),

    # Tab text
    (re.compile(r"Tab\s*\(.*?text:\s*$", re.DOTALL),
        StringContext.TAB_TEXT, Severity.HIGH),

    # InputDecoration labelText
    (re.compile(r"labelText:\s*$"), StringContext.INPUT_LABEL, Severity.HIGH),

    # InputDecoration hintText
    (re.compile(r"hintText:\s*$"), StringContext.INPUT_HINT, Severity.MEDIUM),

    # Tooltip
    (re.compile(r"tooltip:\s*$"), StringContext.TOOLTIP, Severity.MEDIUM),

    # Validator return
    (re.compile(r"return\s+$"), StringContext.VALIDATOR, Severity.HIGH),

    # Generic Text widget
    (re.compile(r"(?:const\s+)?Text\s*\(\s*$"), StringContext.TEXT_WIDGET, Severity.HIGH),

    # child: Text(... used as generic button text
    (re.compile(r"child:\s*(?:const\s+)?Text\s*\(\s*$"),
        StringContext.BUTTON_LABEL, Severity.CRITICAL),
]


# ──────────────────────────────────────────────────────────────────────
# Core scanning logic
# ──────────────────────────────────────────────────────────────────────

# Match single- and double-quoted Dart string literals (non-interpolated or
# simple interpolation). We deliberately keep it simple — triple-quotes and
# raw strings are rare in UI code.
STRING_RE = re.compile(
    r"""(?:const\s+)?"""               # optional const keyword
    r"""(?:"""
    r"""'([^'\\]*(?:\\.[^'\\]*)*)'"""  # single-quoted
    r"""|"""
    r'''"([^"\\]*(?:\\.[^"\\]*)*)"'''  # double-quoted
    r""")"""
)


def is_false_positive_line(line: str) -> bool:
    """Return True if the whole line is clearly not user-facing."""
    stripped = line.strip()
    for pat in FALSE_POSITIVE_PATTERNS:
        if re.search(pat, stripped):
            return True
    return False


def is_ignored_value(s: str) -> bool:
    """Return True if the string value itself is technical / uninteresting."""
    if s in IGNORED_STRING_VALUES:
        return True
    # Very short strings (single char) are usually not user-facing words
    if len(s) <= 1:
        return True
    for pat in TECHNICAL_PATTERNS:
        if re.match(pat, s):
            return True
    return False


def is_localized_call(line: str, match_start: int) -> bool:
    """Check if the string is already inside an AppLocalizations / l10n call."""
    prefix = line[:match_start]
    if "l10n." in prefix or "AppLocalizations" in prefix:
        return True
    # Also check for the pattern where the string IS the l10n getter
    if re.search(r"l10n\.\w+", line):
        return True
    return False


def detect_context(lines: list[str], line_idx: int, col: int) -> tuple[StringContext, Severity]:
    """Look at surrounding code to determine what kind of UI element this is."""
    # Build a context window: current line up to the match, plus a few previous lines
    current_prefix = lines[line_idx][:col]
    # Combine up to 5 previous lines for multi-line pattern matching
    window_lines = []
    for i in range(max(0, line_idx - 5), line_idx):
        window_lines.append(lines[i])
    window_lines.append(current_prefix)
    window = "\n".join(window_lines)

    for pattern, ctx, sev in CONTEXT_RULES:
        if pattern.search(window):
            return ctx, sev

    # Fallback: if inside a Text() widget on the same line
    if re.search(r"Text\s*\(\s*$", current_prefix):
        return StringContext.TEXT_WIDGET, Severity.HIGH

    return StringContext.GENERIC, Severity.LOW


def suggest_key(s: str) -> str:
    """Generate a camelCase ARB key suggestion from the string value."""
    # Remove special chars, lowercase, split into words
    cleaned = re.sub(r"[^\w\s]", "", s)
    words = cleaned.strip().lower().split()
    if not words:
        return "untranslated"
    # camelCase: first word lowercase, rest capitalised
    key = words[0] + "".join(w.capitalize() for w in words[1:])
    # Truncate overly long keys
    if len(key) > 40:
        key = key[:40]
    return key


# Directories where strings are almost never user-facing
NON_UI_DIR_SEGMENTS = {"data", "domain", "repositories", "models"}

# Files (by directory layer) where strings are rarely user-facing
NON_UI_FILE_PATTERNS = [
    r"/data/",
    r"/domain/",
    r"/repositories/",
    r"/models/",
    r"core/database/",
    r"core/encryption/",
    r"core/log/",
    r"core/settings/",
    r"core/utils/",
    r"core/authentication/",
]


def is_non_ui_file(rel_path: str) -> bool:
    """Check if the file is in a non-UI layer (data, domain, utils, etc.)."""
    for pat in NON_UI_FILE_PATTERNS:
        if pat in rel_path:
            return True
    return False


def scan_file(filepath: Path, arb: dict[str, str], reverse_arb: dict[str, str]) -> FileReport:
    """Scan a single Dart file for hardcoded strings."""
    rel_path = str(filepath.relative_to(PROJECT_ROOT))
    report = FileReport(path=rel_path)

    try:
        content = filepath.read_text(encoding="utf-8")
    except (UnicodeDecodeError, PermissionError):
        return report

    # For non-UI files, only report if it looks like there's a UI element
    is_non_ui = is_non_ui_file(rel_path)

    lines = content.splitlines()

    for line_idx, line in enumerate(lines):
        line_no = line_idx + 1

        # Skip comment-only lines
        stripped = line.strip()
        if stripped.startswith("//") or stripped.startswith("///"):
            continue

        # Count localized string usages on this line
        l10n_count = len(re.findall(r"\bl10n\.\w+", line))
        l10n_count += len(re.findall(r"AppLocalizations\.of\(context\)!\.\w+", line))
        report.localized_strings += l10n_count

        # Skip lines that are clearly non-UI
        if is_false_positive_line(line):
            continue

        # Find all string literals on this line
        for match in STRING_RE.finditer(line):
            raw = match.group(1) if match.group(1) is not None else match.group(2)
            if raw is None:
                continue

            col = match.start()
            report.total_strings += 1

            # Filter out ignored / technical values
            if is_ignored_value(raw):
                continue

            # Skip if it's inside a localization call
            if is_localized_call(line, col):
                continue

            # Skip strings that are purely interpolated (start with $)
            if raw.startswith("$") or raw.startswith("{"):
                continue

            # Skip map key access patterns like ['key']
            if col > 0 and line[col - 1:col] == "[":
                continue

            # Skip named parameter string values that are clearly identifiers
            # e.g.  tableName: 'notes'
            param_match = re.search(r"(\w+):\s*$", line[:col])
            if param_match:
                param_name = param_match.group(1)
                if param_name in {
                    "tableName", "primaryKey", "columnName", "key",
                    "fontFamily", "package", "name", "routeName",
                    "heroTag", "restorationId", "semanticsLabel",
                    "debugLabel", "initialRoute", "allowedExtensions",
                    "dialogTitle", "lockParentWindow",
                }:
                    continue

            # Skip internal status variable assignments: _status = '...'
            if re.search(r"_\w*[Ss]tatus\s*=\s*$", line[:col]):
                continue

            # Skip replaceAll / RegExp patterns
            if re.search(r"replaceAll\s*\(\s*(RegExp\s*\()?\s*$", line[:col]):
                continue

            # Skip strings that contain mostly interpolation
            interp_count = len(re.findall(r'\$\{?\w+', raw))
            word_count = len(re.findall(r'[a-zA-Z]{2,}', raw))
            if interp_count > 0 and word_count <= interp_count:
                continue

            # Detect context and severity
            ctx, severity = detect_context(lines, line_idx, col)

            # In non-UI files, skip GENERIC context strings (likely internal)
            # but keep explicitly detected UI contexts (could be data passed to UI)
            if is_non_ui and ctx == StringContext.GENERIC:
                # Exception: keep strings that contain natural language (multiple words)
                if len(raw.split()) < 3:
                    continue

            # Skip GENERIC/LOW if the string looks like a format/template
            if severity == Severity.LOW and ctx == StringContext.GENERIC:
                # Only keep it if it looks like real words (3+ alpha chars)
                if not re.search(r"[a-zA-Z]{3,}", raw):
                    continue

            # Check if an existing ARB key matches
            norm_val = re.sub(r"\s+", " ", raw.strip().lower())
            existing_key = reverse_arb.get(norm_val)

            # Also try partial matching for parameterised strings
            if existing_key is None:
                # Check if the raw string appears as a substring of an ARB value
                for arb_key, arb_val in arb.items():
                    if arb_key.startswith("@@"):
                        continue
                    arb_norm = re.sub(r"\s+", " ", arb_val.strip().lower())
                    if norm_val == arb_norm:
                        existing_key = arb_key
                        break

            entry = HardcodedString(
                file=rel_path,
                line=line_no,
                column=col + 1,
                raw_string=raw,
                context=ctx,
                severity=severity,
                existing_key=existing_key,
                suggested_key=existing_key or suggest_key(raw),
            )
            report.hardcoded.append(entry)

    return report


# ──────────────────────────────────────────────────────────────────────
# Main driver
# ──────────────────────────────────────────────────────────────────────

def collect_dart_files(lib_dir: Path) -> list[Path]:
    """Collect all .dart files, skipping excluded dirs/files."""
    files = []
    for root, dirs, filenames in os.walk(lib_dir):
        # Prune excluded directories
        dirs[:] = [d for d in dirs if d not in SKIP_DIRS]
        for fname in filenames:
            if fname.endswith(".dart") and fname not in SKIP_FILES:
                files.append(Path(root) / fname)
    return sorted(files)


def print_text_report(reports: list[FileReport], severity_filter: Optional[str] = None):
    """Pretty-print the report to stdout."""
    total_hardcoded = 0
    total_localized = 0
    total_with_existing_key = 0
    files_with_issues = 0
    severity_counts = {s: 0 for s in Severity}

    print("=" * 80)
    print("  TRANSLATION COVERAGE REPORT — SimpleDiary")
    print("=" * 80)
    print()

    for report in reports:
        entries = report.hardcoded
        if severity_filter == "__NO_LOW__":
            entries = [e for e in entries if e.severity != Severity.LOW]
        elif severity_filter:
            entries = [e for e in entries if e.severity.value == severity_filter]
        if not entries:
            continue

        files_with_issues += 1
        total_localized += report.localized_strings

        print(f"{'─' * 80}")
        print(f"  FILE: {report.path}")
        print(f"  Localized usages: {report.localized_strings} | "
              f"Hardcoded strings: {len(entries)}")
        print(f"{'─' * 80}")

        for entry in entries:
            total_hardcoded += 1
            severity_counts[entry.severity] += 1
            if entry.existing_key:
                total_with_existing_key += 1

            key_info = ""
            if entry.existing_key:
                key_info = f"  -> USE EXISTING: l10n.{entry.existing_key}"
            elif entry.suggested_key:
                key_info = f"  -> SUGGESTED KEY: {entry.suggested_key}"

            sev_marker = {
                Severity.CRITICAL: "!!",
                Severity.HIGH: "! ",
                Severity.MEDIUM: "~ ",
                Severity.LOW: "  ",
            }[entry.severity]

            print(f"  {sev_marker} [{entry.severity.value:>8}] "
                  f"L{entry.line}:{entry.column:<4} "
                  f"({entry.context.value})")
            # Truncate very long strings
            display_str = entry.raw_string
            if len(display_str) > 60:
                display_str = display_str[:57] + "..."
            print(f"       \"{display_str}\"")
            if key_info:
                print(f"       {key_info}")
            print()

    # ── Summary ──
    print()
    print("=" * 80)
    print("  SUMMARY")
    print("=" * 80)
    print()
    print(f"  Files scanned:            {len(reports)}")
    print(f"  Files with issues:        {files_with_issues}")
    print(f"  Total localized usages:   {total_localized}")
    print(f"  Total hardcoded strings:  {total_hardcoded}")
    print(f"  Already have ARB key:     {total_with_existing_key} "
          f"(translation exists but not used!)")
    print()
    print("  By severity:")
    for sev in Severity:
        bar = "█" * severity_counts[sev]
        print(f"    {sev.value:>8}: {severity_counts[sev]:>3}  {bar}")
    print()

    if total_with_existing_key > 0:
        print(f"  ⚠  {total_with_existing_key} strings already have translations "
              f"in app_en.arb but are not using them!")
        print(f"     These are quick wins — just replace with the l10n call.")
        print()

    # Coverage estimate
    total_ui_strings = total_localized + total_hardcoded
    if total_ui_strings > 0:
        pct = (total_localized / total_ui_strings) * 100
        print(f"  Estimated coverage: {pct:.1f}% "
              f"({total_localized}/{total_ui_strings} UI strings localized)")
    print()
    print("=" * 80)

    return total_hardcoded


def print_json_report(reports: list[FileReport], severity_filter: Optional[str] = None):
    """Output machine-readable JSON."""
    output = {"files": [], "summary": {}}
    total_hardcoded = 0
    total_localized = 0
    severity_counts = {s.value: 0 for s in Severity}

    for report in reports:
        entries = report.hardcoded
        if severity_filter == "__NO_LOW__":
            entries = [e for e in entries if e.severity != Severity.LOW]
        elif severity_filter:
            entries = [e for e in entries if e.severity.value == severity_filter]
        if not entries:
            continue

        total_localized += report.localized_strings
        file_entry = {
            "path": report.path,
            "localized_usages": report.localized_strings,
            "hardcoded": [],
        }
        for entry in entries:
            total_hardcoded += 1
            severity_counts[entry.severity.value] += 1
            file_entry["hardcoded"].append({
                "line": entry.line,
                "column": entry.column,
                "string": entry.raw_string,
                "context": entry.context.value,
                "severity": entry.severity.value,
                "existing_key": entry.existing_key,
                "suggested_key": entry.suggested_key,
            })
        output["files"].append(file_entry)

    output["summary"] = {
        "files_scanned": len(reports),
        "files_with_issues": len(output["files"]),
        "total_localized": total_localized,
        "total_hardcoded": total_hardcoded,
        "by_severity": severity_counts,
    }
    print(json.dumps(output, indent=2, ensure_ascii=False))
    return total_hardcoded


def main():
    parser = argparse.ArgumentParser(
        description="Check Flutter/Dart files for hardcoded UI strings "
                    "that should be localized."
    )
    parser.add_argument(
        "--json", action="store_true",
        help="Output in JSON format"
    )
    parser.add_argument(
        "--severity", choices=["CRITICAL", "HIGH", "MEDIUM", "LOW"],
        help="Only show results of this severity level"
    )
    parser.add_argument(
        "--no-low", action="store_true",
        help="Exclude LOW severity results (reduce noise)"
    )
    args = parser.parse_args()

    # Load ARB translations
    arb = load_arb_strings(ARB_FILE)
    reverse_arb = build_reverse_arb(arb)

    # Collect and scan files
    dart_files = collect_dart_files(LIB_DIR)
    reports = []
    for f in dart_files:
        report = scan_file(f, arb, reverse_arb)
        reports.append(report)

    severity_filter = args.severity
    if args.no_low and not severity_filter:
        # Filter to exclude LOW by passing a special value
        severity_filter = "__NO_LOW__"

    # Output
    if args.json:
        count = print_json_report(reports, severity_filter)
    else:
        count = print_text_report(reports, severity_filter)

    # Exit code: non-zero if any hardcoded strings found
    sys.exit(1 if count > 0 else 0)


if __name__ == "__main__":
    main()
