import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lexi/features/auth/providers/auth_provider.dart';
import 'package:lexi/features/auth/screens/splash_screen.dart';
import 'package:lexi/features/auth/screens/login_screen.dart';
import 'package:lexi/features/auth/screens/register_screen.dart';
import 'package:lexi/features/languages/screens/home_screen.dart';
import 'package:lexi/features/words/screens/word_list_screen.dart';
import 'package:lexi/features/words/screens/add_edit_word_screen.dart';
import 'package:lexi/features/words/screens/word_detail_screen.dart';
import 'package:lexi/features/quiz/screens/quiz_setup_screen.dart';
import 'package:lexi/features/quiz/screens/flashcard_screen.dart';
import 'package:lexi/features/quiz/screens/quiz_result_screen.dart';
import 'package:lexi/features/stats/screens/stats_screen.dart';
import 'package:lexi/features/settings/screens/settings_screen.dart';
import 'package:lexi/core/models/word_model.dart';

final routerProvider = Provider<GoRouter>((ref) {
  // GoRouter bir kez oluşturulur, asla rebuild edilmez
  final router = GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        builder: (_, _) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (_, _) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (_, _) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (_, _) => const HomeScreen(),
      ),
      GoRoute(
        path: '/language/:id/words',
        builder: (_, state) {
          final languageId = state.pathParameters['id']!;
          final languageName = state.uri.queryParameters['name'] ?? '';
          return WordListScreen(
            languageId: languageId,
            languageName: languageName,
          );
        },
        routes: [
          GoRoute(
            path: 'add',
            builder: (_, state) {
              final languageId = state.pathParameters['id']!;
              return AddEditWordScreen(languageId: languageId);
            },
          ),
          GoRoute(
            path: 'edit',
            builder: (_, state) {
              final word = state.extra as WordModel;
              return AddEditWordScreen(
                languageId: word.languageId,
                wordToEdit: word,
              );
            },
          ),
          GoRoute(
            path: 'detail',
            builder: (_, state) {
              final word = state.extra as WordModel;
              return WordDetailScreen(initialWord: word);
            },
          ),
          GoRoute(
            path: 'quiz',
            builder: (_, state) {
              final languageId = state.pathParameters['id']!;
              final languageName = state.uri.queryParameters['name'] ?? '';
              return QuizSetupScreen(
                languageId: languageId,
                languageName: languageName,
              );
            },
          ),
          GoRoute(
            path: 'stats',
            builder: (_, state) {
              final languageId = state.pathParameters['id']!;
              final languageName = state.uri.queryParameters['name'] ?? '';
              return StatsScreen(
                languageId: languageId,
                languageName: languageName,
              );
            },
          ),
        ],
      ),
      GoRoute(
        path: '/quiz/flashcard',
        builder: (_, _) => const FlashcardScreen(),
      ),
      GoRoute(
        path: '/quiz/result',
        builder: (_, _) => const QuizResultScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (_, _) => const SettingsScreen(),
      ),
    ],
  );

  // Auth state'i dinle → değişince doğrudan router.go() ile navige et
  ref.listen(authStateProvider, (_, next) {
    if (next.isLoading) return; // Henüz hazır değil, bekle
    if (next.value != null) {
      router.go('/home');
    } else {
      router.go('/login');
    }
  });

  // Uygulama açılırken auth zaten hazırsa (örn. önceki oturumdan)
  // microtask ile bir sonraki frame'de navige et
  final initial = ref.read(authStateProvider);
  if (!initial.isLoading) {
    Future.microtask(() {
      if (initial.value != null) {
        router.go('/home');
      } else {
        router.go('/login');
      }
    });
  }

  ref.onDispose(router.dispose);
  return router;
});
