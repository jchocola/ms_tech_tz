import 'package:flutter/material.dart';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'config/di/di.dart';
import 'config/router/router.dart';
import 'config/theme/light_theme.dart';
import 'config/theme/dark_theme.dart';
import 'feature/feature_paywall/presentation/bloc/paywall_bloc.dart';
import 'feature/feature_mainpage/presentation/bloc/main_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize dependencies
  await initializeDependencies();

  runApp(const SecureVpnApp());
}

/// Main application widget
class SecureVpnApp extends StatelessWidget {
  const SecureVpnApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AdaptiveTheme(
      light: lightTheme,
      dark: darkTheme,
      initial: AdaptiveThemeMode.light,
      builder: (theme, darkTheme) => MultiBlocProvider(
        providers: [
          BlocProvider<PaywallBloc>(create: (_) => getIt<PaywallBloc>()),
          BlocProvider<MainBloc>(create: (_) => getIt<MainBloc>()),
        ],
        child: MaterialApp.router(
          title: 'SecureVPN',
          debugShowCheckedModeBanner: false,
          theme: theme,
          darkTheme: darkTheme,
          routerConfig: router,
        ),
      ),
    );
  }
}
