import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';

class AddLanguageDialog extends StatefulWidget {
  final Future<void> Function(String name, String emoji) onAdd;

  const AddLanguageDialog({super.key, required this.onAdd});

  @override
  State<AddLanguageDialog> createState() => _AddLanguageDialogState();
}

class _AddLanguageDialogState extends State<AddLanguageDialog> {
  final _nameCtrl = TextEditingController();
  String _selectedEmoji = '📖';
  bool _isLoading = false;

  static const _emojis = [
    '🇬🇧', '🇩🇪', '🇫🇷', '🇪🇸', '🇮🇹', '🇵🇱',
    '🇯🇵', '🇰🇷', '🇨🇳', '🇷🇺', '🇧🇷', '🇳🇱',
    '🇸🇪', '🇳🇴', '🇩🇰', '🇵🇹', '🇬🇷', '🇹🇷',
    '📖', '🌍', '💬', '🎓',
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return;
    setState(() => _isLoading = true);
    await widget.onAdd(name, _selectedEmoji);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(
        24,
        16,
        24,
        MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          Text(
            'Add Language',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 4),
          Text(
            'Create a new vocabulary file',
            style: Theme.of(context).textTheme.bodySmall,
          ),

          const SizedBox(height: 24),

          // Language name field
          TextFormField(
            controller: _nameCtrl,
            autofocus: true,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _submit(),
            decoration: const InputDecoration(
              labelText: 'Language name',
              hintText: 'e.g. English, German, Polish...',
              prefixIcon: Icon(Icons.language_rounded),
            ),
          ),

          const SizedBox(height: 20),

          // Emoji picker
          Text(
            'Choose an icon',
            style: Theme.of(context).textTheme.labelMedium,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _emojis.map((emoji) {
              final isSelected = emoji == _selectedEmoji;
              return GestureDetector(
                onTap: () => setState(() => _selectedEmoji = emoji),
                child: AnimatedContainer(
                  duration: 200.ms,
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary.withAlpha(26)
                        : (isDark
                            ? AppColors.darkCard
                            : AppColors.lightBackground),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : (isDark
                              ? AppColors.darkBorder
                              : AppColors.lightBorder),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Center(
                    child: Text(emoji, style: const TextStyle(fontSize: 22)),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 28),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _submit,
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : const Text('Add Language'),
            ),
          ),
        ],
      ),
    ).animate().slideY(begin: 0.3, end: 0, duration: 300.ms, curve: Curves.easeOut);
  }
}
