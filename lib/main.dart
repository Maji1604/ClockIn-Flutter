import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/core.dart';
import 'core/dependency_injection/service_locator.dart';
import 'features/auth/presentation/pages/role_selection_page.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: ".env");

  // Initialize theme manager
  await ThemeManager().initialize();

  // Initialize dependencies
  await initializeDependencies();

  // Setup service locator for BLoC
  ServiceLocator.setup();

  runApp(const ClockInApp());
}

class ClockInApp extends StatelessWidget {
  const ClockInApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => ServiceLocator.authBloc..add(CheckAuthStatus()),
        ),
        BlocProvider(create: (context) => ServiceLocator.leaveBloc),
        BlocProvider(create: (context) => ServiceLocator.attendanceBloc),
      ],
      child: MaterialApp(
        title: AppEnvironment.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        themeMode: ThemeMode.light,
        home: const RoleSelectionPage(),
      ),
    );
  }
}
