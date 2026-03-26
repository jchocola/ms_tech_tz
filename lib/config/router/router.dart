import 'package:go_router/go_router.dart';
import '../../feature/feature_onboarding/presentation/onboarding.dart';
import '../../feature/feature_paywall/presentation/paywall_page.dart';
import '../../feature/feature_mainpage/presentation/main_page.dart';
import '../di/di.dart';
import '../../feature/feature_paywall/domain/repositories/subscription_repository.dart';

/// Router configuration
final SubscriptionRepository _subscriptionRepository =
    getIt<SubscriptionRepository>();

final GoRouter router = GoRouter(
  initialLocation: '/onboarding',
  routes: [
    // Onboarding route
    GoRoute(
      path: '/onboarding',
      name: 'onboarding',
      builder: (context, state) => const OnboardingPage(),
    ),
    // Paywall route
    GoRoute(
      path: '/paywall',
      name: 'paywall',
      builder: (context, state) => const PaywallPage(),
    ),
    // Main page route
    GoRoute(
      path: '/main',
      name: 'main',
      builder: (context, state) => const MainPage(),
    ),
  ],
  redirect: (context, state) async {
    // Check subscription status
    final isSubscribed = await _subscriptionRepository.isSubscribed();
    final location = state.matchedLocation;

    // If not subscribed and trying to access main page, redirect to paywall
    if (!isSubscribed && location == '/main') {
      return '/paywall';
    }

    // If already subscribed and on onboarding or paywall, redirect to main
    if (isSubscribed && (location == '/onboarding' || location == '/paywall')) {
      return '/main';
    }

    return null; // No redirect
  },
);
