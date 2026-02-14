import 'dart:convert';

class DescriptionSection {
  final String title;
  final String hint;

  const DescriptionSection({
    required this.title,
    this.hint = '',
  });

  Map<String, dynamic> toMap() => {
        'title': title,
        'hint': hint,
      };

  factory DescriptionSection.fromMap(Map<String, dynamic> map) {
    return DescriptionSection(
      title: map['title'] as String? ?? '',
      hint: map['hint'] as String? ?? '',
    );
  }

  DescriptionSection copyWith({String? title, String? hint}) {
    return DescriptionSection(
      title: title ?? this.title,
      hint: hint ?? this.hint,
    );
  }

  static String encode(List<DescriptionSection> sections) {
    if (sections.isEmpty) return '';
    return json.encode(sections.map((s) => s.toMap()).toList());
  }

  static List<DescriptionSection> decode(String jsonString) {
    if (jsonString.isEmpty) return [];
    try {
      final List<dynamic> list = json.decode(jsonString);
      return list
          .map((e) => DescriptionSection.fromMap(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }
}
