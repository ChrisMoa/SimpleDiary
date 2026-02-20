// ignore_for_file: public_member_api_docs
import 'dart:convert';

/// The type/trigger of a backup
enum BackupType {
  manual,
  scheduled,
  preRestore;

  String toJson() => name;

  static BackupType fromJson(String json) {
    return BackupType.values.firstWhere(
      (e) => e.name == json,
      orElse: () => BackupType.manual,
    );
  }
}

/// Metadata describing a single backup file
class BackupMetadata {
  /// Unique backup identifier (timestamp-based)
  final String id;

  /// When the backup was created
  final DateTime createdAt;

  /// Backup file size in bytes
  final int sizeBytes;

  /// Local file path of the backup
  final String filePath;

  /// What triggered the backup
  final BackupType type;

  /// Number of diary days in this backup
  final int diaryDayCount;

  /// Number of notes in this backup
  final int noteCount;

  /// Number of habits in this backup
  final int habitCount;

  /// Number of habit entries in this backup
  final int habitEntryCount;

  /// Whether the backup data is encrypted
  final bool encrypted;

  /// Whether this backup has been synced to cloud storage
  final bool cloudSynced;

  /// Error message if backup failed (null = success)
  final String? error;

  BackupMetadata({
    required this.id,
    required this.createdAt,
    required this.sizeBytes,
    required this.filePath,
    required this.type,
    required this.diaryDayCount,
    required this.noteCount,
    required this.habitCount,
    required this.habitEntryCount,
    this.encrypted = false,
    this.cloudSynced = false,
    this.error,
  });

  /// Whether this backup completed successfully
  bool get isSuccessful => error == null;

  /// Human-readable file size
  String get formattedSize {
    if (sizeBytes < 1024) return '$sizeBytes B';
    if (sizeBytes < 1024 * 1024) return '${(sizeBytes / 1024).toStringAsFixed(1)} KB';
    return '${(sizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'createdAt': createdAt.toIso8601String(),
      'sizeBytes': sizeBytes,
      'filePath': filePath,
      'type': type.toJson(),
      'diaryDayCount': diaryDayCount,
      'noteCount': noteCount,
      'habitCount': habitCount,
      'habitEntryCount': habitEntryCount,
      'encrypted': encrypted,
      'cloudSynced': cloudSynced,
      'error': error,
    };
  }

  factory BackupMetadata.fromMap(Map<String, dynamic> map) {
    return BackupMetadata(
      id: map['id'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
      sizeBytes: map['sizeBytes'] as int? ?? 0,
      filePath: map['filePath'] as String,
      type: BackupType.fromJson(map['type'] as String? ?? 'manual'),
      diaryDayCount: map['diaryDayCount'] as int? ?? 0,
      noteCount: map['noteCount'] as int? ?? 0,
      habitCount: map['habitCount'] as int? ?? 0,
      habitEntryCount: map['habitEntryCount'] as int? ?? 0,
      encrypted: map['encrypted'] as bool? ?? false,
      cloudSynced: map['cloudSynced'] as bool? ?? false,
      error: map['error'] as String?,
    );
  }

  String toJson() => json.encode(toMap());

  factory BackupMetadata.fromJson(String source) =>
      BackupMetadata.fromMap(json.decode(source) as Map<String, dynamic>);

  BackupMetadata copyWith({
    String? id,
    DateTime? createdAt,
    int? sizeBytes,
    String? filePath,
    BackupType? type,
    int? diaryDayCount,
    int? noteCount,
    int? habitCount,
    int? habitEntryCount,
    bool? encrypted,
    bool? cloudSynced,
    String? error,
  }) {
    return BackupMetadata(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      filePath: filePath ?? this.filePath,
      type: type ?? this.type,
      diaryDayCount: diaryDayCount ?? this.diaryDayCount,
      noteCount: noteCount ?? this.noteCount,
      habitCount: habitCount ?? this.habitCount,
      habitEntryCount: habitEntryCount ?? this.habitEntryCount,
      encrypted: encrypted ?? this.encrypted,
      cloudSynced: cloudSynced ?? this.cloudSynced,
      error: error ?? this.error,
    );
  }

  @override
  String toString() {
    return 'BackupMetadata(id: $id, type: ${type.name}, days: $diaryDayCount, notes: $noteCount, habits: $habitCount, size: $formattedSize, encrypted: $encrypted, cloudSynced: $cloudSynced, error: $error)';
  }
}
