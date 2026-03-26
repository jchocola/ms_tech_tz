import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../feature/feature_paywall/data/repositories/subscription_repository_impl.dart';
import '../../feature/feature_paywall/domain/repositories/subscription_repository.dart';
import '../../feature/feature_paywall/presentation/bloc/paywall_bloc.dart';
import '../../feature/feature_mainpage/data/repositories/vpn_repository_impl.dart';
import '../../feature/feature_mainpage/domain/repositories/vpn_repository.dart';
import '../../feature/feature_mainpage/presentation/bloc/main_bloc.dart';

/// Global GetIt instance
final GetIt getIt = GetIt.instance;

/// Initialize all dependencies
Future<void> initializeDependencies() async {
  // Register SharedPreferences
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(sharedPreferences);

  // Register repositories
  getIt.registerLazySingleton<SubscriptionRepository>(
    () => SubscriptionRepositoryImpl(
      sharedPreferences: getIt<SharedPreferences>(),
    ),
  );

  getIt.registerLazySingleton<VpnRepository>(() => VpnRepositoryImpl());

  // Register BLoCs
  getIt.registerFactory<PaywallBloc>(
    () => PaywallBloc(repository: getIt<SubscriptionRepository>()),
  );

  getIt.registerFactory<MainBloc>(
    () => MainBloc(
      vpnRepository: getIt<VpnRepository>(),
      subscriptionRepository: getIt<SubscriptionRepository>(),
    ),
  );
}
