# ADR-004: Security Model

## Status
Accepted

## Context
SimpleDiary stores personal journal entries, mood data, and wellbeing metrics — sensitive information that users expect to remain private. The security model must protect data at rest (on-device storage, backups, exports), authenticate users reliably, and support biometric convenience on mobile platforms.

Key constraints:
- No server-side session management (local-first architecture)
- Must work offline without token refresh
- Multiple user profiles on the same device
- Backup files may be stored on shared storage or transferred between devices

## Decision
We adopted a **layered security model** combining PBKDF2 password hashing, AES-256-CBC data encryption, and platform-native biometric authentication.

### 1. Password hashing: PBKDF2-SHA256

| Parameter | Value |
|-----------|-------|
| Algorithm | PBKDF2 with HMAC-SHA256 (via PointyCastle) |
| Salt | 32 bytes (256 bits) of cryptographically secure random data, unique per user |
| Iterations | 10,000 rounds |
| Key length | 32 bytes (256 bits) |
| Output | Base64-encoded hash stored in `UserData.passwordHash` |

Passwords are never stored in cleartext on disk. The cleartext password is held in memory only during an active session (required for encryption key derivation).

### 2. Data encryption: AES-256-CBC

| Parameter | Value |
|-----------|-------|
| Algorithm | AES in CBC mode |
| Key size | 256 bits (32 bytes) |
| IV | 16 bytes, randomly generated per encryption operation |
| IV storage | Prepended to ciphertext |
| Library | `encrypt` package |

Used for: backup files, JSON/ICS exports, and file-level encryption.

### 3. Encryption key derivation (domain-separated)

The encryption key is derived separately from the password hash to prevent cross-protocol attacks:

```
Encryption key = PBKDF2(password, salt + "db_encryption_key", iterations: 20,000)
```

- **Domain separation:** Appending `"db_encryption_key"` context to the salt ensures the encryption key differs from the password hash even with the same password and salt
- **Higher iterations:** 20,000 rounds (vs 10,000 for password hashing) for additional brute-force resistance on the encryption key

### 4. Biometric authentication

- **Platforms:** Android and iOS only (desktop platforms return `unsupportedPlatform`)
- **Implementation:** Delegates to `local_auth` package for hardware-backed biometric prompts
- **Credential storage:** After successful biometric enrollment, credentials are stored via `flutter_secure_storage` (Android KeyStore / iOS Keychain)
- **Auto-lock:** Configurable timeout (0 = always require biometric on resume)

### 5. Per-user database isolation

Each user profile gets a separate SQLite database file (`${userId}.db`). Switching users closes the current database connection and opens the new user's file, providing complete data isolation without row-level access control.

## Consequences

### Benefits
- **Defense in depth:** Three independent layers (hashing, encryption, biometric) each protect against different attack vectors
- **Domain-separated key derivation:** Compromising the password hash does not reveal the encryption key, and vice versa
- **Random IVs per operation:** Identical plaintexts produce different ciphertexts, preventing pattern analysis on encrypted backups
- **Hardware-backed biometrics:** Delegates to OS-level security (Secure Enclave / TEE) rather than implementing custom biometric logic
- **Offline-compatible:** No server round-trips needed for authentication; all crypto operations are local

### Trade-offs
- **Session cleartext in memory:** The cleartext password must be held in memory during the session for encryption key derivation; this is unavoidable without a separate key management service
- **No authenticated encryption:** CBC mode provides confidentiality but not integrity verification (no HMAC or GCM). A tampered backup would decrypt to garbage rather than being explicitly rejected
- **Desktop has no biometric option:** Linux and Windows users can only use password authentication; there is no equivalent to mobile biometric hardware
- **10,000 PBKDF2 iterations:** While meeting NIST baseline recommendations, modern guidance suggests higher iteration counts (100,000+). This was chosen as a balance between security and mobile device performance

## Alternatives Considered

### bcrypt / Argon2 for password hashing
- Argon2 is the current OWASP recommendation with memory-hard properties
- No mature pure-Dart implementation at time of decision; would require native FFI bindings
- PBKDF2 has well-tested Dart implementations via PointyCastle and meets security requirements

### AES-GCM (authenticated encryption)
- Provides both confidentiality and integrity in a single operation
- Would detect tampered backup files rather than silently decrypting to garbage
- The `encrypt` package supports GCM but was not available when the encryption layer was initially built; a future migration is possible

### PIN-based authentication (instead of password)
- Simpler UX for quick access
- Severely limited keyspace (4-6 digits) makes brute-force trivial on local databases
- Password provides adequate security with biometric available as the convenience option

### No encryption (rely on OS-level protection)
- Simpler implementation
- Leaves backup files and exports completely unprotected when transferred or stored on shared media
- Unacceptable for a privacy-focused diary app

---

*Decided: Project inception*
*Last reviewed: 2026-02-27*
