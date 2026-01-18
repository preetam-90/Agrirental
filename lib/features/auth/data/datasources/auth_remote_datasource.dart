import 'package:supabase_flutter/supabase_flutter.dart' hide AuthException;
import 'package:supabase_flutter/supabase_flutter.dart' as sb show AuthException;
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/user.dart';
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
  
  /// Update user profile
  Future<void> updateProfile({
    required String fullName,
    required String addressText,
    required double latitude,
    required double longitude,
  });
  
  /// Update user current role
  Future<void> updateProfileRole(UserRole role);
  
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
      // Determine the redirect URL based on platform
      final redirectUrl = kIsWeb 
        ? Uri.base.toString().replaceAll(RegExp(r'/+$'), '') // Remove trailing slash
        : 'io.supabase.agriflutter://login-callback/';
      
      final bool result = await supabaseClient.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: redirectUrl,
      );
      return result;
    } on sb.AuthException catch (e) {
      throw AuthException(e.message, e.statusCode);
    } catch (e) {
      throw ServerException('Google sign in failed: ${e.toString()}');
    }
  }

  Future<UserModel> _getOrCreateUserProfile(String userId, {String? phone, String? email, String? fullName}) async {
    // Fetch user profile from user_profiles table
    // Use ST_AsGeoJSON to get location as proper GeoJSON
    final profileResponse = await supabaseClient
        .from('user_profiles')
        .select('*, location:location::geometry')
        .eq('id', userId)
        .maybeSingle();
    
    print('DEBUG PROFILE FETCH: Profile response: $profileResponse');
    
    if (profileResponse == null) {
      // Create a new profile in the database
      try {
        final newProfile = {
          'id': userId,
          'phone_number': phone,
          'full_name': fullName ?? 'User',
          'active_role': 'farmer',
          'enabled_roles': ['farmer'],
          'preferred_language': 'en',
          'is_profile_complete': false,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        };
        
        await supabaseClient.from('user_profiles').insert(newProfile);
        
        // Return the newly created profile
        return UserModel(
          id: userId,
          phoneNumber: phone,
          email: email,
          fullName: fullName ?? 'User',
          activeRole: UserRole.farmer,
          isVerified: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
      } catch (e) {
        // If profile creation fails, still return a minimal user for the UI to handle
        return UserModel(
          id: userId,
          phoneNumber: phone,
          email: email,
          fullName: fullName ?? 'User',
          activeRole: UserRole.farmer,
          isVerified: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
      }
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
  Future<void> updateProfile({
    required String fullName,
    required String addressText,
    required double latitude,
    required double longitude,
  }) async {
    try {
      final userId = supabaseClient.auth.currentUser?.id;
      if (userId == null) throw AuthException('Not authenticated', '401');

      // PostGIS expects WKT (Well-Known Text) format
      final locationGeoJson = 'POINT($longitude $latitude)';

      final profileData = {
        'full_name': fullName,
        'address_text': addressText,
        'location': locationGeoJson,
        'is_profile_complete': true,
        'updated_at': DateTime.now().toIso8601String(),
      };

      print('DEBUG DATASOURCE: Updating profile with data: $profileData');
      // Use update() instead of upsert() since profile already exists
      final response = await supabaseClient
          .from('user_profiles')
          .update(profileData)
          .eq('id', userId)
          .select();
      print('DEBUG DATASOURCE: Update response: $response');
    } on PostgrestException catch (e) {
      print('DEBUG DATASOURCE: PostgrestException: ${e.message}, code: ${e.code}');
      throw ServerException('Failed to update profile: ${e.message}', 
        e.code != null ? int.tryParse(e.code!) : null);
    } catch (e) {
      print('DEBUG DATASOURCE: Exception: $e');
      throw ServerException('Failed to update profile: ${e.toString()}');
    }
  }

  @override
  Future<void> updateProfileRole(UserRole role) async {
    try {
      final userId = supabaseClient.auth.currentUser?.id;
      if (userId == null) throw AuthException('Not authenticated', '401');

      await supabaseClient.from('user_profiles').update({
        'active_role': role == UserRole.farmer ? 'farmer' : 'equipment_provider',
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', userId);
    } on PostgrestException catch (e) {
      throw ServerException('Failed to update role: ${e.message}', 
        e.code != null ? int.tryParse(e.code!) : null);
    } catch (e) {
      throw ServerException('Failed to update role: ${e.toString()}');
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
