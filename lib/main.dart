import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/providers/auth_state_provider.dart';

void main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive for local storage
  await Hive.initFlutter();
  
  // Open Hive box for user data (must be opened before using in providers)
  await Hive.openBox('user_box');
  
  // Initialize Supabase
  await Supabase.initialize(
    url: AppConstants.supabaseUrl,
    anonKey: AppConstants.supabaseAnonKey,
  );
  
  // Run app
  runApp(
    // Wrap with ProviderScope for Riverpod state management
    const ProviderScope(
      child: AgriServeApp(),
    ),
  );
}

/// Root application widget
class AgriServeApp extends ConsumerWidget {
  const AgriServeApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch authentication state
    final isAuthenticated = ref.watch(isAuthenticatedProvider);
    
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      
      // Material 3 Theme
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      
      // Localization support (Hindi/English)
      supportedLocales: const [
        Locale('en', ''), // English
        Locale('hi', ''), // Hindi
      ],
      
      // Simple routing (will be replaced with GoRouter)
      home: isAuthenticated ? const HomePage() : const LoginPage(),
    );
  }
}

/// Placeholder home page
/// TODO: Implement proper home page with role-based UI
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final authNotifier = ref.read(authNotifierProvider.notifier);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('AgriServe'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authNotifier.signOut();
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 100,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 24),
            Text(
              'Welcome ${user?.fullName ?? "User"}!',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            if (user?.email != null)
              Text(
                'Email: ${user!.email}',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            if (user?.phoneNumber != null)
              Text(
                'Phone: ${user!.phoneNumber}',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            const SizedBox(height: 8),
            Text(
              'Role: ${user?.activeRole.displayName ?? ""}',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 32),
            const Text(
              'Authentication System Working! ✅',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
