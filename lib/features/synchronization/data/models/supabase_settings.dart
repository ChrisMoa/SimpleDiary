class SupabaseSettings {
  final String supabaseUrl;
  final String supabaseAnonKey;
  final String email;
  final String password;

  SupabaseSettings({
    required this.supabaseUrl,
    required this.supabaseAnonKey,
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toMap() {
    return {
      'supabase_url': supabaseUrl,
      'supabase_anon_key': supabaseAnonKey,
      'email': email,
      'password': password,
    };
  }

  factory SupabaseSettings.fromMap(Map<String, dynamic> map) {
    return SupabaseSettings(
      supabaseUrl: map['supabase_url'] ?? '',
      supabaseAnonKey: map['supabase_anon_key'] ?? '',
      email: map['email'] ?? '',
      password: map['password'] ?? '',
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
  }) {
    return SupabaseSettings(
      supabaseUrl: supabaseUrl ?? this.supabaseUrl,
      supabaseAnonKey: supabaseAnonKey ?? this.supabaseAnonKey,
      email: email ?? this.email,
      password: password ?? this.password,
    );
  }
}
