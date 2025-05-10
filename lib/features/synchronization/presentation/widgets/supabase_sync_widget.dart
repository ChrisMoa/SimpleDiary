// lib/features/synchronization/presentation/widgets/supabase_sync_widget.dart
import 'package:day_tracker/core/provider/theme_provider.dart';
import 'package:day_tracker/features/synchronization/data/models/supabase_settings.dart';
import 'package:day_tracker/features/synchronization/domain/providers/supabase_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SupabaseSyncWidget extends ConsumerStatefulWidget {
  const SupabaseSyncWidget({super.key});

  @override
  ConsumerState<SupabaseSyncWidget> createState() => _SupabaseSyncWidgetState();
}

class _SupabaseSyncWidgetState extends ConsumerState<SupabaseSyncWidget> {
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
      final settings = ref.read(supabaseSettingsProvider);
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
    final syncState = ref.watch(supabaseSyncProvider);
    final settings = ref.watch(supabaseSettingsProvider);

    // Responsive design considerations
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
                    Icons.cloud_sync,
                    color: theme.colorScheme.primary,
                    size: isSmallScreen ? 24 : 28,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Supabase Synchronization',
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
                'Sync your diary data with Supabase cloud storage for backup and cross-device access.',
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
                onChanged: (value) => ref
                    .read(supabaseSettingsProvider.notifier)
                    .updateUrl(value),
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
                onChanged: (value) => ref
                    .read(supabaseSettingsProvider.notifier)
                    .updateAnonKey(value),
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
                onChanged: (value) => ref
                    .read(supabaseSettingsProvider.notifier)
                    .updateEmail(value),
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
                onChanged: (value) => ref
                    .read(supabaseSettingsProvider.notifier)
                    .updatePassword(value),
                theme: theme,
                isSmallScreen: isSmallScreen,
              ),

              SizedBox(height: isSmallScreen ? 20 : 24),

              // Sync Status
              if (syncState.status != SyncStatus.idle)
                _buildSyncStatus(syncState, theme, isSmallScreen),

              if (syncState.status != SyncStatus.idle)
                SizedBox(height: isSmallScreen ? 16 : 20),

              // Action Buttons
              Column(
                children: [
                  _buildSyncButton(
                    context: context,
                    icon: Icons.cloud_upload,
                    label: 'Upload to Supabase',
                    description: 'Save your diary data to the cloud',
                    onPressed: _canSync(settings)
                        ? () => ref
                            .read(supabaseSyncProvider.notifier)
                            .syncToSupabase()
                        : null,
                    theme: theme,
                    isSmallScreen: isSmallScreen,
                  ),
                  const SizedBox(height: 16),
                  _buildSyncButton(
                    context: context,
                    icon: Icons.cloud_download,
                    label: 'Download from Supabase',
                    description: 'Load diary data from the cloud',
                    onPressed: _canSync(settings)
                        ? () => ref
                            .read(supabaseSyncProvider.notifier)
                            .syncFromSupabase()
                        : null,
                    theme: theme,
                    isSmallScreen: isSmallScreen,
                  ),
                ],
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

  Widget _buildSyncButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String description,
    required VoidCallback? onPressed,
    required ThemeData theme,
    required bool isSmallScreen,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
        decoration: BoxDecoration(
          color: onPressed != null
              ? theme.colorScheme.surfaceContainer
              : theme.colorScheme.onSurface.withOpacity(0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.colorScheme.outline.withOpacity(0.2),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(isSmallScreen ? 8 : 12),
              decoration: BoxDecoration(
                color: onPressed != null
                    ? theme.colorScheme.primaryContainer
                    : theme.colorScheme.onSurface.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: onPressed != null
                    ? theme.colorScheme.onPrimaryContainer
                    : theme.colorScheme.onSurface.withOpacity(0.38),
                size: isSmallScreen ? 20 : 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: onPressed != null
                          ? theme.colorScheme.onSurface
                          : theme.colorScheme.onSurface.withOpacity(0.38),
                      fontSize: isSmallScreen ? 14 : 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: onPressed != null
                          ? theme.colorScheme.onSurface.withOpacity(0.7)
                          : theme.colorScheme.onSurface.withOpacity(0.38),
                      fontSize: isSmallScreen ? 12 : 14,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: onPressed != null
                  ? theme.colorScheme.onSurface.withOpacity(0.5)
                  : theme.colorScheme.onSurface.withOpacity(0.38),
              size: isSmallScreen ? 16 : 18,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSyncStatus(
      SyncState syncState, ThemeData theme, bool isSmallScreen) {
    Color statusColor;
    IconData statusIcon;

    switch (syncState.status) {
      case SyncStatus.syncing:
        statusColor = theme.colorScheme.primary;
        statusIcon = Icons.sync;
        break;
      case SyncStatus.success:
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case SyncStatus.error:
        statusColor = theme.colorScheme.error;
        statusIcon = Icons.error;
        break;
      default:
        statusColor = theme.colorScheme.onSurface;
        statusIcon = Icons.info;
    }

    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(statusIcon,
                  color: statusColor, size: isSmallScreen ? 18 : 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  syncState.message,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: statusColor,
                    fontSize: isSmallScreen ? 14 : 16,
                  ),
                ),
              ),
            ],
          ),
          if (syncState.status == SyncStatus.syncing) ...[
            SizedBox(height: isSmallScreen ? 8 : 12),
            LinearProgressIndicator(
              value: syncState.progress,
              backgroundColor: statusColor.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(statusColor),
            ),
          ],
        ],
      ),
    );
  }

  bool _canSync(SupabaseSettings settings) {
    return settings.supabaseUrl.isNotEmpty &&
        settings.supabaseAnonKey.isNotEmpty &&
        settings.email.isNotEmpty &&
        settings.password.isNotEmpty;
  }
}
