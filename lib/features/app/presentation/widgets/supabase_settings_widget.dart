import 'package:day_tracker/core/provider/theme_provider.dart';
import 'package:day_tracker/core/settings/settings_container.dart';
import 'package:day_tracker/features/synchronization/domain/providers/supabase_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SupabaseSettingsWidget extends ConsumerStatefulWidget {
  const SupabaseSettingsWidget({super.key});

  @override
  ConsumerState<SupabaseSettingsWidget> createState() => _SupabaseSettingsWidgetState();
}

class _SupabaseSettingsWidgetState extends ConsumerState<SupabaseSettingsWidget> {
  final _urlController = TextEditingController();
  final _anonKeyController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _passwordVisible = false;
  bool _anonKeyVisible = false;

  @override
  void initState() {
    super.initState();
    // Load existing settings
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final settings = settingsContainer.activeUserSettings.supabaseSettings;
      _urlController.text = settings.supabaseUrl;
      _anonKeyController.text = settings.supabaseAnonKey;
      _emailController.text = settings.email;
      _passwordController.text = settings.password;
    });
  }

  @override
  void dispose() {
    _urlController.dispose();
    _anonKeyController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final isSmallScreen = screenWidth < 600;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.surfaceContainerHighest,
              theme.colorScheme.surface,
            ],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                children: [
                  Icon(
                    Icons.cloud,
                    color: theme.colorScheme.primary,
                    size: isSmallScreen ? 24 : 28,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Supabase Settings',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: isSmallScreen ? 18 : 22,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              Text(
                'Configure your Supabase cloud storage settings for backup and cross-device access.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),

              const SizedBox(height: 24),

              // Settings Form
              _buildTextField(
                controller: _urlController,
                label: 'Supabase URL',
                hint: 'https://your-project.supabase.co',
                icon: Icons.link,
                onChanged: (value) {
                  ref.read(supabaseSettingsProvider.notifier).updateUrl(value);
                  settingsContainer.activeUserSettings.supabaseSettings = settingsContainer.activeUserSettings.supabaseSettings.copyWith(supabaseUrl: value);
                },
                theme: theme,
                isSmallScreen: isSmallScreen,
              ),
              SizedBox(height: isSmallScreen ? 12 : 16),

              _buildTextField(
                controller: _anonKeyController,
                label: 'Anon Key',
                hint: 'Your Supabase anon key',
                icon: Icons.key,
                isPassword: !_anonKeyVisible,
                toggleVisibility: () {
                  setState(() {
                    _anonKeyVisible = !_anonKeyVisible;
                  });
                },
                onChanged: (value) {
                  ref.read(supabaseSettingsProvider.notifier).updateAnonKey(value);
                  settingsContainer.activeUserSettings.supabaseSettings = settingsContainer.activeUserSettings.supabaseSettings.copyWith(supabaseAnonKey: value);
                },
                theme: theme,
                isSmallScreen: isSmallScreen,
              ),
              SizedBox(height: isSmallScreen ? 12 : 16),

              _buildTextField(
                controller: _emailController,
                label: 'Email',
                hint: 'your.email@example.com',
                icon: Icons.email,
                keyboardType: TextInputType.emailAddress,
                onChanged: (value) {
                  ref.read(supabaseSettingsProvider.notifier).updateEmail(value);
                  settingsContainer.activeUserSettings.supabaseSettings = settingsContainer.activeUserSettings.supabaseSettings.copyWith(email: value);
                },
                theme: theme,
                isSmallScreen: isSmallScreen,
              ),
              SizedBox(height: isSmallScreen ? 12 : 16),

              _buildTextField(
                controller: _passwordController,
                label: 'Password',
                hint: 'Your Supabase password',
                icon: Icons.lock,
                isPassword: !_passwordVisible,
                toggleVisibility: () {
                  setState(() {
                    _passwordVisible = !_passwordVisible;
                  });
                },
                onChanged: (value) {
                  ref.read(supabaseSettingsProvider.notifier).updatePassword(value);
                  settingsContainer.activeUserSettings.supabaseSettings = settingsContainer.activeUserSettings.supabaseSettings.copyWith(password: value);
                },
                theme: theme,
                isSmallScreen: isSmallScreen,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    VoidCallback? toggleVisibility,
    required Function(String) onChanged,
    TextInputType keyboardType = TextInputType.text,
    required ThemeData theme,
    required bool isSmallScreen,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: keyboardType,
      onChanged: onChanged,
      style: theme.textTheme.bodyMedium?.copyWith(
        fontSize: isSmallScreen ? 14 : 16,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, size: isSmallScreen ? 20 : 24),
        suffixIcon: toggleVisibility != null
            ? IconButton(
                icon: Icon(
                  isPassword ? Icons.visibility : Icons.visibility_off,
                  size: isSmallScreen ? 20 : 24,
                ),
                onPressed: toggleVisibility,
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.colorScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.colorScheme.primary),
        ),
        filled: true,
        fillColor: theme.colorScheme.surface,
        labelStyle: TextStyle(
          color: theme.colorScheme.onSurface,
          fontSize: isSmallScreen ? 14 : 16,
        ),
        hintStyle: TextStyle(
          color: theme.colorScheme.onSurface.withOpacity(0.5),
          fontSize: isSmallScreen ? 14 : 16,
        ),
      ),
    );
  }
}
