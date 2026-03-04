class SupabaseSettings {
  final String supabaseUrl;
  final String supabaseAnonKey;
  final String email;
  final String password;
  final bool autoSyncEnabled;
  final int autoSyncDebounceSeconds;
  final String? lastAutoSyncTimestamp;

  SupabaseSettings({
    required this.supabaseUrl,
    required this.supabaseAnonKey,
    required this.email,
    required this.password,
    this.autoSyncEnabled = false,
    this.autoSyncDebounceSeconds = 30,
    this.lastAutoSyncTimestamp,
  });

  /// Whether Supabase connection credentials are fully configured
  bool get isConfigured =>
      supabaseUrl.isNotEmpty &&
      supabaseAnonKey.isNotEmpty &&
      email.isNotEmpty &&
      password.isNotEmpty;

  /// Get the last auto-sync as DateTime, or null if never synced
  DateTime? get lastAutoSyncDateTime {
    if (lastAutoSyncTimestamp == null) return null;
    return DateTime.tryParse(lastAutoSyncTimestamp!);
  }

  Map<String, dynamic> toMap() {
    return {
      'supabase_url': supabaseUrl,
      'supabase_anon_key': supabaseAnonKey,
      'email': email,
      'password': password,
      'auto_sync_enabled': autoSyncEnabled,
      'auto_sync_debounce_seconds': autoSyncDebounceSeconds,
      'last_auto_sync_timestamp': lastAutoSyncTimestamp,
    };
  }

  factory SupabaseSettings.fromMap(Map<String, dynamic> map) {
    return SupabaseSettings(
      supabaseUrl: map['supabase_url'] ?? '',
      supabaseAnonKey: map['supabase_anon_key'] ?? '',
      email: map['email'] ?? '',
      password: map['password'] ?? '',
      autoSyncEnabled: map['auto_sync_enabled'] as bool? ?? false,
      autoSyncDebounceSeconds: map['auto_sync_debounce_seconds'] as int? ?? 30,
      lastAutoSyncTimestamp: map['last_auto_sync_timestamp'] as String?,
    );
  }

  factory SupabaseSettings.empty() {
    return SupabaseSettings(
      supabaseUrl: '',
      supabaseAnonKey: '',
      email: '',
      password: '',
    );
  }

  SupabaseSettings copyWith({
    String? supabaseUrl,
    String? supabaseAnonKey,
    String? email,
    String? password,
    bool? autoSyncEnabled,
    int? autoSyncDebounceSeconds,
    String? lastAutoSyncTimestamp,
  }) {
    return SupabaseSettings(
      supabaseUrl: supabaseUrl ?? this.supabaseUrl,
      supabaseAnonKey: supabaseAnonKey ?? this.supabaseAnonKey,
      email: email ?? this.email,
      password: password ?? this.password,
      autoSyncEnabled: autoSyncEnabled ?? this.autoSyncEnabled,
      autoSyncDebounceSeconds:
          autoSyncDebounceSeconds ?? this.autoSyncDebounceSeconds,
      lastAutoSyncTimestamp:
          lastAutoSyncTimestamp ?? this.lastAutoSyncTimestamp,
    );
  }
}
