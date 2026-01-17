import 'package:supabase_flutter/supabase_flutter.dart' hide AuthException;
import 'package:supabase_flutter/supabase_flutter.dart' as sb show AuthException;
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../../../core/error/exceptions.dart';
import '../models/user_model.dart';

/// Remote data source for authentication using Supabase
abstract class AuthRemoteDataSource {
  /// Send OTP to phone number
  Future<void> sendOTP(String phoneNumber);
  
  /// Verify OTP and create session
  Future<UserModel> verifyOTP({
    required String phoneNumber,
    required String otpCode,
  });

  /// Sign in with Email and Password
  Future<UserModel> signInWithEmail({
    required String email,
    required String password,
  });

  /// Sign up with Email and Password
  Future<UserModel> signUpWithEmail({
    required String email,
    required String password,
    required String fullName,
  });

  /// Sign in with Google
  Future<bool> signInWithGoogle();
  
  /// Get current authenticated user
  Future<UserModel> getCurrentUser();
  
  /// Sign out current user
  Future<void> signOut();
  
  /// Check if user is authenticated
  Future<bool> isAuthenticated();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final SupabaseClient supabaseClient;
  
  AuthRemoteDataSourceImpl({required this.supabaseClient});
  
  @override
  Future<void> sendOTP(String phoneNumber) async {
    try {
      // Format phone number with country code if not present
      final formattedPhone = phoneNumber.startsWith('+') 
        ? phoneNumber 
        : '+91$phoneNumber';
      
      // Send OTP via Supabase Auth
      await supabaseClient.auth.signInWithOtp(
        phone: formattedPhone,
      );
    } on sb.AuthException catch (e) {
      throw AuthException(
        e.message,
        e.statusCode,
      );
    } catch (e) {
      throw ServerException('Failed to send OTP: ${e.toString()}');
    }
  }
  
  @override
  Future<UserModel> verifyOTP({
    required String phoneNumber,
    required String otpCode,
  }) async {
    try {
      // Format phone number
      final formattedPhone = phoneNumber.startsWith('+') 
        ? phoneNumber 
        : '+91$phoneNumber';
      
      // Verify OTP with Supabase
      final response = await supabaseClient.auth.verifyOTP(
        phone: formattedPhone,
        token: otpCode,
        type: OtpType.sms,
      );
      
      if (response.user == null) {
        throw AuthException('OTP verification failed', '401');
      }
      
      return await _getOrCreateUserProfile(response.user!.id, phone: formattedPhone);
    } on sb.AuthException catch (e) {
      throw AuthException(e.message, e.statusCode);
    } catch (e) {
      throw ServerException('OTP verification failed: ${e.toString()}');
    }
  }

  @override
  Future<UserModel> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await supabaseClient.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw AuthException('Login failed', '401');
      }

      return await _getOrCreateUserProfile(response.user!.id, email: email);
    } on sb.AuthException catch (e) {
      throw AuthException(e.message, e.statusCode);
    } catch (e) {
      throw ServerException('Login failed: ${e.toString()}');
    }
  }

  @override
  Future<UserModel> signUpWithEmail({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      final response = await supabaseClient.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': fullName},
      );

      if (response.user == null) {
        throw AuthException('Sign up failed', '400');
      }
      
      // If email confirmation is enabled, user might not be logged in yet
      // But we can try to create the profile
      return await _getOrCreateUserProfile(response.user!.id, email: email, fullName: fullName);
    } on sb.AuthException catch (e) {
      throw AuthException(e.message, e.statusCode);
    } catch (e) {
      throw ServerException('Sign up failed: ${e.toString()}');
    }
  }

  @override
  Future<bool> signInWithGoogle() async {
    try {
      final bool result = await supabaseClient.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: kIsWeb ? 'http://localhost:8080' : 'io.supabase.agriflutter://login-callback/',
      );
      return result;
    } on sb.AuthException catch (e) {
      throw AuthException(e.message, e.statusCode);
    } catch (e) {
      throw ServerException('Google sign in failed: ${e.toString()}');
    }
  }

  Future<UserModel> _getOrCreateUserProfile(String userId, {String? phone, String? email, String? fullName}) async {
    // Fetch or create user profile from user_profiles table
      final profileResponse = await supabaseClient
          .from('user_profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();
      
      if (profileResponse == null) {
        // First-time user - create profile
        final newProfile = {
          'id': userId,
          if (phone != null) 'phone_number': phone,
          if (email != null) 'email': email,
          'full_name': fullName ?? email ?? phone ?? 'User', 
          'active_role': 'farmer',
          'enabled_roles': ['farmer'],
          'preferred_language': 'en',
        };
        
        await supabaseClient
            .from('user_profiles')
            .insert(newProfile);
        
        return UserModel.fromJson({
          ...newProfile,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });
      }
      
      return UserModel.fromJson(profileResponse);
  }
  
  @override
  Future<UserModel> getCurrentUser() async {
    try {
      final session = supabaseClient.auth.currentSession;
      
      if (session == null) {
        throw AuthException('No active session', '401');
      }
      
      // Use _getOrCreateUserProfile to ensure profile exists
      // We can grab email/phone from session.user to populate if creating new
      return await _getOrCreateUserProfile(
        session.user.id,
        email: session.user.email,
        phone: session.user.phone,
        fullName: session.user.userMetadata?['full_name'] as String?,
      );
    } on sb.AuthException catch (e) {
      throw AuthException(e.message, e.statusCode);
    } on PostgrestException catch (e) {
      throw ServerException('Failed to fetch user profile: ${e.message}', e.code != null ? int.tryParse(e.code!) : null);
    } catch (e) {
      throw ServerException('Failed to get current user: ${e.toString()}');
    }
  }
  
  @override
  Future<void> signOut() async {
    try {
      await supabaseClient.auth.signOut();
    } on sb.AuthException catch (e) {
      throw AuthException(e.message, e.statusCode);
    } catch (e) {
      throw ServerException('Failed to sign out: ${e.toString()}');
    }
  }
  
  @override
  Future<bool> isAuthenticated() async {
    try {
      final session = supabaseClient.auth.currentSession;
      return session != null;
    } catch (e) {
      return false;
    }
  }
}
