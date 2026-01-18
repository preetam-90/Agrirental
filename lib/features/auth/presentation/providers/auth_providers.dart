import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/network_info.dart';
import '../../data/datasources/auth_local_datasource.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/get_current_user.dart';
import '../../domain/usecases/send_otp.dart';
import '../../domain/usecases/sign_out.dart';
import '../../domain/usecases/verify_otp.dart';
import '../../domain/usecases/sign_in_with_email.dart';
import '../../domain/usecases/sign_up_with_email.dart';
import '../../domain/usecases/sign_in_with_google.dart';
import '../../domain/usecases/update_profile.dart';

// ============================================================================
// Infrastructure Providers
// ============================================================================
final signInWithEmailUseCaseProvider = Provider<SignInWithEmail>((ref) {
  return SignInWithEmail(ref.watch(authRepositoryProvider));
});

/// Sign up with Email use case provider
final signUpWithEmailUseCaseProvider = Provider<SignUpWithEmail>((ref) {
  return SignUpWithEmail(ref.watch(authRepositoryProvider));
});

/// Sign in with Google use case provider
final signInWithGoogleUseCaseProvider = Provider<SignInWithGoogle>((ref) {
  return SignInWithGoogle(ref.watch(authRepositoryProvider));
});

/// Supabase client provider
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

/// Hive box provider for user cache
final userBoxProvider = Provider<Box>((ref) {
  return Hive.box('user_box');
});

/// Connectivity provider
final connectivityProvider = Provider<Connectivity>((ref) {
  return Connectivity();
});

/// Network info provider
final networkInfoProvider = Provider<NetworkInfo>((ref) {
  return NetworkInfoImpl(ref.watch(connectivityProvider));
});

// ============================================================================
// Data Source Providers
// ============================================================================

/// Remote data source provider
final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSourceImpl(
    supabaseClient: ref.watch(supabaseClientProvider),
  );
});

/// Local data source provider
final authLocalDataSourceProvider = Provider<AuthLocalDataSource>((ref) {
  return AuthLocalDataSourceImpl(
    userBox: ref.watch(userBoxProvider),
  );
});

// ============================================================================
// Repository Provider
// ============================================================================

/// Auth repository provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    remoteDataSource: ref.watch(authRemoteDataSourceProvider),
    localDataSource: ref.watch(authLocalDataSourceProvider),
    networkInfo: ref.watch(networkInfoProvider),
  );
});

// ============================================================================
// Use Case Providers
// ============================================================================

/// Send OTP use case provider
final sendOTPUseCaseProvider = Provider<SendOTP>((ref) {
  return SendOTP(ref.watch(authRepositoryProvider));
});

/// Verify OTP use case provider
final verifyOTPUseCaseProvider = Provider<VerifyOTP>((ref) {
  return VerifyOTP(ref.watch(authRepositoryProvider));
});

/// Get current user use case provider
final getCurrentUserUseCaseProvider = Provider<GetCurrentUser>((ref) {
  return GetCurrentUser(ref.watch(authRepositoryProvider));
});

/// Sign out use case provider
final signOutUseCaseProvider = Provider<SignOut>((ref) {
  return SignOut(ref.watch(authRepositoryProvider));
});

/// Update profile use case provider
final updateProfileUseCaseProvider = Provider<UpdateProfile>((ref) {
  return UpdateProfile(ref.watch(authRepositoryProvider));
});
