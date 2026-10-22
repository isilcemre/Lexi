import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/quiz_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/models/word_model.dart';

class FlashcardScreen extends ConsumerStatefulWidget {
  const FlashcardScreen({super.key});

  @override
  ConsumerState<FlashcardScreen> createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends ConsumerState<FlashcardScreen>
    with TickerProviderStateMixin {
  // Flip (kart çevirme) controller
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;

  // Swipe-out (uçurma) controller
  late AnimationController _swipeController;
  late Animation<double> _swipeOffsetAnim;

  bool _isAnimating = false;
  double _dragOffset = 0;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _flipAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOutCubic),
    );

    _swipeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    // Varsayılan (override edilecek)
    _swipeOffsetAnim = Tween<double>(begin: 0, end: 0).animate(_swipeController);
  }

  @override
  void dispose() {
    _flipController.dispose();
    _swipeController.dispose();
    super.dispose();
  }

  void _flip() {
    if (_isAnimating) return;
    final quiz = ref.read(quizProvider);
    if (!quiz.isFlipped) {
      ref.read(quizProvider.notifier).flipCard();
      _flipController.forward();
    } else {
      ref.read(quizProvider.notifier).flipCard();
      _flipController.reverse();
    }
  }

  // Kartı ekrandan uçur, sonra cevabı işle
  Future<void> _swipeOut(bool knew) async {
    if (_isAnimating) return;
    setState(() { _isAnimating = true; _isDragging = false; });

    final screenWidth = MediaQuery.of(context).size.width;
    final target = knew ? screenWidth * 1.8 : -screenWidth * 1.8;

    // Mevcut _dragOffset'ten hedef konuma animasyon
    _swipeOffsetAnim = Tween<double>(
      begin: _dragOffset,
      end: target,
    ).animate(CurvedAnimation(
      parent: _swipeController,
      curve: Curves.easeOut,
    ));

    _swipeController.reset();

    // Animasyon sırasında _dragOffset'i güncelle
    void listener() {
      if (mounted) setState(() => _dragOffset = _swipeOffsetAnim.value);
    }
    _swipeController.addListener(listener);
    await _swipeController.forward();
    _swipeController.removeListener(listener);

    // Kart ekran dışına çıktı; state güncellemesini (Firestore yazması dahil)
    // kart hâlâ ekran dışı offsette dururken yapıyoruz ki eski kelime
    // tekrar ortada görünmesin.
    if (!mounted) return;

    if (knew) {
      await ref.read(quizProvider.notifier).answerKnown();
    } else {
      await ref.read(quizProvider.notifier).answerUnknown();
    }

    if (!mounted) return;

    _flipController.value = 0;

    final quiz = ref.read(quizProvider);
    if (quiz.isFinished) {
      context.pushReplacement('/quiz/result');
      return;
    }

    // Yeni kelime state'e zaten yüklendi; offset'i şimdi sıfırlayıp
    // yeni kartı ortada göster. Reset ve kelime değişimi aynı frame'de
    // olduğu için görünür bir sıçrama olmuyor.
    setState(() { _dragOffset = 0; _isAnimating = false; });
  }

  @override
  Widget build(BuildContext context) {
    final quiz = ref.watch(quizProvider);
    final word = quiz.currentWord;

    if (word == null || quiz.isFinished) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final total = quiz.words.length;
    final current = quiz.currentIndex + 1;
    final progress = quiz.currentIndex / total;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () {
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Quit Quiz?'),
                content: const Text('Your progress will be lost.'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Continue'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      ref.read(quizProvider.notifier).reset();
                      context.pop();
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent),
                    child: const Text('Quit'),
                  ),
                ],
              ),
            );
          },
        ),
        title: Text('$current / $total'),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: AppColors.primary.withAlpha(26),
            color: AppColors.primary,
            minHeight: 4,
          ),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),

          // Score row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _ScoreBadge(
                  icon: Icons.check_rounded,
                  count: quiz.knownWordIds.length,
                  color: AppColors.statusKnown,
                  label: 'Known',
                ),
                _ScoreBadge(
                  icon: Icons.close_rounded,
                  count: quiz.unknownWordIds.length,
                  color: AppColors.statusUnknown,
                  label: 'Unknown',
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Hint
          if (!quiz.isFlipped)
            Text(
              'Tap card to reveal',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppColors.darkTextHint
                        : AppColors.lightTextHint,
                  ),
            ).animate().fadeIn(duration: 500.ms),

          const SizedBox(height: 16),

          // Flashcard
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: GestureDetector(
                onTap: _flip,
                onHorizontalDragStart: (_) {
                  if (!quiz.isFlipped) return;
                  setState(() => _isDragging = true);
                },
                onHorizontalDragUpdate: (details) {
                  if (!quiz.isFlipped || !_isDragging) return;
                  setState(() => _dragOffset += details.delta.dx);
                },
                onHorizontalDragEnd: (details) {
                  if (!quiz.isFlipped || !_isDragging) return;
                  final threshold = MediaQuery.of(context).size.width * 0.35;
                  if (_dragOffset > threshold) {
                    _swipeOut(true);  // Known (swipe right → uçur)
                  } else if (_dragOffset < -threshold) {
                    _swipeOut(false); // Unknown (swipe left → uçur)
                  } else {
                    // Eşiğe ulaşmadı, geri snap et
                    _swipeOffsetAnim = Tween<double>(
                      begin: _dragOffset,
                      end: 0,
                    ).animate(CurvedAnimation(
                      parent: _swipeController,
                      curve: Curves.elasticOut,
                    ));
                    _swipeController.reset();
                    void snapListener() {
                      if (mounted) setState(() => _dragOffset = _swipeOffsetAnim.value);
                    }
                    _swipeController.addListener(snapListener);
                    _swipeController.forward().then((_) {
                      _swipeController.removeListener(snapListener);
                      if (mounted) setState(() { _dragOffset = 0; _isDragging = false; });
                    });
                  }
                },
                child: AnimatedBuilder(
                  animation: _flipAnimation,
                  builder: (_, _) {
                    final angle = _flipAnimation.value * pi;
                    final isFrontVisible = angle < pi / 2;

                    return Transform(
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.001)
                        ..rotateY(angle)
                        ..setEntry(0, 3, _dragOffset),
                      alignment: Alignment.center,
                      child: isFrontVisible
                          ? _CardFace(
                              word: word,
                              isBack: false,
                              dragOffset: _dragOffset,
                            )
                          : Transform(
                              transform: Matrix4.identity()..rotateY(pi),
                              alignment: Alignment.center,
                              child: _CardFace(
                                word: word,
                                isBack: true,
                                dragOffset: _dragOffset,
                              ),
                            ),
                    );
                  },
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Action buttons
          if (quiz.isFlipped)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Expanded(
                    child: _ActionButton(
                      onPressed: () => _swipeOut(false),
                      icon: Icons.close_rounded,
                      label: "Don't Know",
                      color: AppColors.statusUnknown,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _ActionButton(
                      onPressed: () => _swipeOut(true),
                      icon: Icons.check_rounded,
                      label: 'I Know',
                      color: AppColors.statusKnown,
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.5),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _CardFace extends StatelessWidget {
  final WordModel word;
  final bool isBack;
  final double dragOffset;

  const _CardFace({
    required this.word,
    required this.isBack,
    required this.dragOffset,
  });

  Color _getDragColor(BuildContext context) {
    if (dragOffset.abs() < 30) return Colors.transparent;
    if (dragOffset > 0) return AppColors.statusKnown.withAlpha(77);
    return AppColors.statusUnknown.withAlpha(77);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dragColor = _getDragColor(context);
    final rotation = (dragOffset / 500).clamp(-0.1, 0.1);

    return Transform.rotate(
      angle: rotation,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: dragOffset.abs() > 30
                ? (dragOffset > 0
                    ? AppColors.statusKnown
                    : AppColors.statusUnknown)
                : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
            width: dragOffset.abs() > 30 ? 2.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withAlpha(isDark ? 20 : 30),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Drag overlay
            if (dragOffset.abs() > 30)
              AnimatedContainer(
                duration: Duration.zero,
                decoration: BoxDecoration(
                  color: dragColor,
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Center(
                  child: Icon(
                    dragOffset > 0 ? Icons.check_rounded : Icons.close_rounded,
                    color: dragOffset > 0
                        ? AppColors.statusKnown
                        : AppColors.statusUnknown,
                    size: 60,
                  ),
                ),
              ),

            // Content
            Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Label
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: isBack
                          ? AppColors.secondary.withAlpha(26)
                          : AppColors.primary.withAlpha(26),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      isBack ? 'MEANING' : 'WORD',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.5,
                        color: isBack
                            ? AppColors.secondary
                            : AppColors.primary,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  Text(
                    isBack ? word.meaning : word.word,
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w800,
                      color: isDark ? AppColors.darkText : AppColors.lightText,
                      letterSpacing: -1,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  if (isBack && word.note != null && word.note!.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.darkBackground
                            : AppColors.lightBackground,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        word.note!,
                        style: TextStyle(
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScoreBadge extends StatelessWidget {
  final IconData icon;
  final int count;
  final Color color;
  final String label;

  const _ScoreBadge({
    required this.icon,
    required this.count,
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(77)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Text(
            '$count $label',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final String label;
  final Color color;

  const _ActionButton({
    required this.onPressed,
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 20),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle:
            const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
      ),
    );
  }
}