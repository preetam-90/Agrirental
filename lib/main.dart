import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/onboarding_page.dart';
import 'features/equipment/presentation/pages/farmer_dashboard.dart';
import 'features/equipment/presentation/pages/provider_dashboard.dart';
// Providers and user role
import 'features/auth/presentation/providers/auth_state_provider.dart';
import 'features/auth/domain/entities/user.dart';

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
    // Watch authentication and profile state
    final isAuthenticated = ref.watch(isAuthenticatedProvider);
    final isProfileComplete = ref.watch(isProfileCompleteProvider);
    
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
      
      // Routing logic
      home: !isAuthenticated 
          ? const LoginPage() 
          : !isProfileComplete 
              ? const OnboardingPage() 
              : const HomePage(),
    );
  }
}

/// Home page that switches between Farmer and Provider dashboards
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeRole = ref.watch(userRoleProvider);
    
    if (activeRole == UserRole.provider) {
      return const ProviderDashboard();
    }
    
    return const FarmerDashboard();
  }
}
