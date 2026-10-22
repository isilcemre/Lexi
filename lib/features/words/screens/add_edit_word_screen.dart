import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/models/word_model.dart';
import '../../../core/constants/enums.dart';
import '../../../core/theme/app_colors.dart';
import '../../../features/languages/providers/language_provider.dart';

class AddEditWordScreen extends ConsumerStatefulWidget {
  final String languageId;
  final WordModel? wordToEdit;

  const AddEditWordScreen({
    super.key,
    required this.languageId,
    this.wordToEdit,
  });

  @override
  ConsumerState<AddEditWordScreen> createState() => _AddEditWordScreenState();
}

class _AddEditWordScreenState extends ConsumerState<AddEditWordScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _wordCtrl;
  late final List<TextEditingController> _meaningCtrls;
  late final TextEditingController _noteCtrl;
  late WordType _selectedType;
  late WordStatus _selectedStatus;
  bool _isLoading = false;

  bool get _isEditing => widget.wordToEdit != null;

  @override
  void initState() {
    super.initState();
    _wordCtrl = TextEditingController(text: widget.wordToEdit?.word ?? '');
    if (widget.wordToEdit != null) {
      _meaningCtrls = widget.wordToEdit!.meanings
          .map((m) => TextEditingController(text: m))
          .toList();
      if (_meaningCtrls.isEmpty) {
        _meaningCtrls.add(TextEditingController());
      }
    } else {
      _meaningCtrls = [TextEditingController()];
    }
    _noteCtrl = TextEditingController(text: widget.wordToEdit?.note ?? '');
    _selectedType = widget.wordToEdit?.type ?? WordType.noun;
    _selectedStatus = widget.wordToEdit?.status ?? WordStatus.newWord;
  }

  @override
  void dispose() {
    _wordCtrl.dispose();
    for (final c in _meaningCtrls) {
      c.dispose();
    }
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final service = ref.read(firestoreServiceProvider);

      if (_isEditing) {
        final updated = widget.wordToEdit!.copyWith(
          word: _wordCtrl.text.trim(),
          meanings: _meaningCtrls
              .map((c) => c.text.trim())
              .where((t) => t.isNotEmpty)
              .toList(),
          type: _selectedType,
          note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
          status: _selectedStatus,
        );
        await service.updateWord(updated);
      } else {
        final newWord = WordModel(
          id: '',
          languageId: widget.languageId,
          word: _wordCtrl.text.trim(),
          meanings: _meaningCtrls
              .map((c) => c.text.trim())
              .where((t) => t.isNotEmpty)
              .toList(),
          type: _selectedType,
          note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
          status: _selectedStatus,
          createdAt: DateTime.now(),
        );
        await service.addWord(newWord);
      }

      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditing ? 'Word updated!' : 'Word added!'),
            backgroundColor: AppColors.statusKnown,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.accent,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => context.pop(),
        ),
        title: Text(_isEditing ? 'Edit Word' : 'Add Word'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _save,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : Text(
                    _isEditing ? 'Update' : 'Save',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Word field
              _SectionLabel('Word *'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _wordCtrl,
                autofocus: !_isEditing,
                textCapitalization: TextCapitalization.none,
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.text,
                enableSuggestions: true,
                autocorrect: false,
                enableIMEPersonalizedLearning: true,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.w600),
                decoration: const InputDecoration(
                  hintText: 'e.g. intervention',
                  prefixIcon: Icon(Icons.text_fields_rounded),
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Word is required' : null,
              ),

              const SizedBox(height: 20),

              // Meaning field(s)
              _SectionLabel('Meaning *'),
              const SizedBox(height: 8),
              ...List.generate(_meaningCtrls.length, (index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: TextFormField(
                    controller: _meaningCtrls[index],
                    textCapitalization: TextCapitalization.sentences,
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.text,
                    enableSuggestions: true,
                    autocorrect: false,
                    enableIMEPersonalizedLearning: true,
                    decoration: InputDecoration(
                      hintText: index == 0
                          ? 'e.g. müdahale'
                          : 'Another meaning...',
                      prefixIcon: const Icon(Icons.translate_rounded),
                      suffixIcon: index > 0
                          ? IconButton(
                              icon: Icon(Icons.remove_circle_outline_rounded,
                                  color: Colors.red.shade300, size: 20),
                              onPressed: () {
                                setState(() {
                                  _meaningCtrls[index].dispose();
                                  _meaningCtrls.removeAt(index);
                                });
                              },
                            )
                          : null,
                    ),
                    validator: index == 0
                        ? (v) => v == null || v.trim().isEmpty
                            ? 'Meaning is required'
                            : null
                        : null,
                  ),
                );
              }),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _meaningCtrls.add(TextEditingController());
                    });
                  },
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('Add another meaning'),
                ),
              ),

              const SizedBox(height: 20),

              // Word Type selector
              _SectionLabel('Word Type *'),
              const SizedBox(height: 10),
              _WordTypeSelector(
                selected: _selectedType,
                onChanged: (t) => setState(() => _selectedType = t),
              ),

              const SizedBox(height: 20),

              // Status selector
              _SectionLabel('Status'),
              const SizedBox(height: 10),
              _StatusSelector(
                selected: _selectedStatus,
                onChanged: (s) => setState(() => _selectedStatus = s),
              ),

              const SizedBox(height: 20),

              // Note field
              _SectionLabel('Note (optional)'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _noteCtrl,
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
                keyboardType: TextInputType.multiline,
                enableSuggestions: true,
                autocorrect: false,
                enableIMEPersonalizedLearning: true,
                decoration: const InputDecoration(
                  hintText: 'e.g. Government intervention was necessary.',
                  prefixIcon: Padding(
                    padding: EdgeInsets.only(bottom: 40),
                    child: Icon(Icons.notes_rounded),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Save button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _save,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : Text(_isEditing ? 'Update Word' : 'Save Word'),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ).animate().fadeIn(duration: 300.ms),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.darkTextSecondary
                : AppColors.lightTextSecondary,
            letterSpacing: 0.8,
          ),
    );
  }
}

class _WordTypeSelector extends StatelessWidget {
  final WordType selected;
  final ValueChanged<WordType> onChanged;

  const _WordTypeSelector(
      {required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: WordType.values.map((type) {
        final isSelected = type == selected;
        final color = switch (type) {
          WordType.noun => AppColors.noun,
          WordType.verb => AppColors.verb,
          WordType.adjective => AppColors.adjective,
          WordType.adverb => AppColors.adverb,
          WordType.pronoun => AppColors.pronoun,
          WordType.preposition => AppColors.preposition,
          WordType.conjunction => AppColors.conjunction,
          WordType.phrase => AppColors.phrase,
          WordType.idiom => AppColors.idiom,
          WordType.phrasalVerb => AppColors.phrasalVerb,
          WordType.collocation => AppColors.collocation,
        };
        return GestureDetector(
          onTap: () => onChanged(type),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? color.withAlpha(26) : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? color : (Theme.of(context).brightness == Brightness.dark
                    ? AppColors.darkBorder
                    : AppColors.lightBorder),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Text(
              type.label,
              style: TextStyle(
                color: isSelected ? color : (Theme.of(context).brightness == Brightness.dark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary),
                fontWeight:
                    isSelected ? FontWeight.w700 : FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _StatusSelector extends StatelessWidget {
  final WordStatus selected;
  final ValueChanged<WordStatus> onChanged;

  const _StatusSelector(
      {required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: WordStatus.values.map((status) {
        final isSelected = status == selected;
        final color = switch (status) {
          WordStatus.newWord => AppColors.statusNew,
          WordStatus.learning => AppColors.statusLearning,
          WordStatus.known => AppColors.statusKnown,
        };
        final icon = switch (status) {
          WordStatus.newWord => Icons.fiber_new_rounded,
          WordStatus.learning => Icons.school_rounded,
          WordStatus.known => Icons.check_circle_rounded,
        };
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => onChanged(status),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? color.withAlpha(26) : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? color : (Theme.of(context).brightness == Brightness.dark
                        ? AppColors.darkBorder
                        : AppColors.lightBorder),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(icon,
                        color: isSelected ? color : (Theme.of(context).brightness == Brightness.dark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary),
                        size: 22),
                    const SizedBox(height: 4),
                    Text(
                      status.label,
                      style: TextStyle(
                        color: isSelected ? color : (Theme.of(context).brightness == Brightness.dark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary),
                        fontSize: 11,
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
