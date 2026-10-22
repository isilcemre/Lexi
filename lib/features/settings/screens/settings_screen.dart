import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/theme_provider.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../core/theme/app_colors.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final user = ref.watch(currentUserProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // User info
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.primaryLight],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.white.withAlpha(51),
                  child: Text(
                    (user?.email?.isNotEmpty == true)
                        ? user!.email![0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 22,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Signed in as',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        user?.email ?? 'Unknown',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 400.ms),

          const SizedBox(height: 24),

          // Appearance
          _SectionTitle('Appearance'),
          const SizedBox(height: 10),
          _SettingsCard(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.palette_outlined,
                            size: 20,
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary),
                        const SizedBox(width: 12),
                        Text('Theme',
                            style: Theme.of(context).textTheme.titleMedium),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: ThemeMode.values.map((mode) {
                        final isSelected = themeMode == mode;
                        final icon = switch (mode) {
                          ThemeMode.light => Icons.wb_sunny_rounded,
                          ThemeMode.dark => Icons.nightlight_rounded,
                          ThemeMode.system => Icons.phone_android_rounded,
                        };
                        final label = switch (mode) {
                          ThemeMode.light => 'Light',
                          ThemeMode.dark => 'Dark',
                          ThemeMode.system => 'System',
                        };
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: GestureDetector(
                              onTap: () => ref
                                  .read(themeProvider.notifier)
                                  .setTheme(mode),
                              child: AnimatedContainer(
                                duration: 200.ms,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 12),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.primary.withAlpha(26)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.primary
                                        : (isDark
                                            ? AppColors.darkBorder
                                            : AppColors.lightBorder),
                                    width: isSelected ? 2 : 1,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Icon(icon,
                                        size: 20,
                                        color: isSelected
                                            ? AppColors.primary
                                            : (isDark
                                                ? AppColors.darkTextSecondary
                                                : AppColors.lightTextSecondary)),
                                    const SizedBox(height: 4),
                                    Text(
                                      label,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: isSelected
                                            ? AppColors.primary
                                            : (isDark
                                                ? AppColors.darkTextSecondary
                                                : AppColors
                                                    .lightTextSecondary),
                                        fontWeight: isSelected
                                            ? FontWeight.w700
                                            : FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ],
          ).animate().fadeIn(delay: 100.ms),

          const SizedBox(height: 20),

          // Account
          _SectionTitle('Account'),
          const SizedBox(height: 10),
          _SettingsCard(
            children: [
              _SettingsTile(
                icon: Icons.lock_reset_rounded,
                title: 'Change Password',
                onTap: () async {
                  if (user?.email != null) {
                    await ref
                        .read(authServiceProvider)
                        .sendPasswordResetEmail(user!.email!);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Password reset email sent!')),
                      );
                    }
                  }
                },
              ),
              const Divider(height: 1),
              _SettingsTile(
                icon: Icons.logout_rounded,
                title: 'Sign Out',
                color: AppColors.accent,
                onTap: () => _confirmSignOut(context, ref),
              ),
            ],
          ).animate().fadeIn(delay: 200.ms),

          const SizedBox(height: 20),

          // About
          _SectionTitle('About'),
          const SizedBox(height: 10),
          _SettingsCard(
            children: [
              _SettingsTile(
                icon: Icons.info_outline_rounded,
                title: 'App Version',
                trailing: const Text('1.0.0',
                    style: TextStyle(color: AppColors.lightTextSecondary)),
              ),
              const Divider(height: 1),
              _SettingsTile(
                icon: Icons.menu_book_rounded,
                title: 'About Lexi',
                onTap: () => showAboutDialog(
                  context: context,
                  applicationName: 'Lexi',
                  applicationVersion: '1.0.0',
                  applicationLegalese: '© 2024 Lexi',
                  children: [
                    const Text(
                        'Your personal vocabulary learning companion.\nSave → Review → Learn'),
                  ],
                ),
              ),
            ],
          ).animate().fadeIn(delay: 300.ms),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  void _confirmSignOut(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await ref.read(authServiceProvider).signOut();
              if (ctx.mounted) Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
            letterSpacing: 1.2,
          ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Column(children: children),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color? color;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.color,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tileColor = color ??
        (isDark ? AppColors.darkText : AppColors.lightText);

    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: tileColor, size: 20),
      title: Text(
        title,
        style: Theme.of(context)
            .textTheme
            .titleSmall
            ?.copyWith(color: tileColor),
      ),
      trailing: trailing ??
          (onTap != null
              ? Icon(Icons.chevron_right_rounded,
                  size: 18,
                  color: isDark
                      ? AppColors.darkTextHint
                      : AppColors.lightTextHint)
              : null),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }
}
