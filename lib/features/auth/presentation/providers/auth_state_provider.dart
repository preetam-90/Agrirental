import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/domain/usecase.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/get_current_user.dart';
import '../../domain/usecases/send_otp.dart';
import '../../domain/usecases/sign_out.dart';
import '../../domain/usecases/verify_otp.dart';
import '../../domain/usecases/sign_in_with_email.dart';
import '../../domain/usecases/sign_up_with_email.dart';
import '../../domain/usecases/sign_in_with_google.dart';
import 'auth_providers.dart';

/// Authentication state
class AuthState {
  final User? user;
  final bool isLoading;
  final String? errorMessage;
  final bool isAuthenticated;
  
  // OTP specific states
  final bool otpSent;
  final String? phoneNumber;
  
  const AuthState({
    this.user,
    this.isLoading = false,
    this.errorMessage,
    this.isAuthenticated = false,
    this.otpSent = false,
    this.phoneNumber,
  });
  
  AuthState copyWith({
    User? user,
    bool? isLoading,
    String? errorMessage,
    bool? isAuthenticated,
    bool? otpSent,
    String? phoneNumber,
    bool clearError = false,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      otpSent: otpSent ?? this.otpSent,
      phoneNumber: phoneNumber ?? this.phoneNumber,
    );
  }
}

/// Auth state notifier for managing authentication state
class AuthNotifier extends StateNotifier<AuthState> {
  final SendOTP sendOTPUseCase;
  final VerifyOTP verifyOTPUseCase;
  final GetCurrentUser getCurrentUserUseCase;
  final SignOut signOutUseCase;
  final SignInWithEmail signInWithEmailUseCase;
  final SignUpWithEmail signUpWithEmailUseCase;
  final SignInWithGoogle signInWithGoogleUseCase;
  
  AuthNotifier({
    required this.sendOTPUseCase,
    required this.verifyOTPUseCase,
    required this.getCurrentUserUseCase,
    required this.signOutUseCase,
    required this.signInWithEmailUseCase,
    required this.signUpWithEmailUseCase,
    required this.signInWithGoogleUseCase,
  }) : super(const AuthState()) {
    // Check if user is already authenticated on initialization
    _checkAuthStatus();
  }
  
  /// Check authentication status on app start
  Future<void> _checkAuthStatus() async {
    state = state.copyWith(isLoading: true);
    
    final result = await getCurrentUserUseCase(const NoParams());
    
    result.fold(
      (failure) {
        // Not authenticated or error
        state = state.copyWith(
          isLoading: false,
          isAuthenticated: false,
        );
      },
      (user) {
        // User is authenticated
        state = state.copyWith(
          user: user,
          isLoading: false,
          isAuthenticated: true,
        );
      },
    );
  }
  
  /// Send OTP to phone number
  Future<bool> sendOTP(String phoneNumber) async {
    state = state.copyWith(isLoading: true, clearError: true);
    
    final result = await sendOTPUseCase(SendOTPParams(phoneNumber: phoneNumber));
    
    return result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: _mapFailureToMessage(failure),
        );
        return false;
      },
      (_) {
        state = state.copyWith(
          isLoading: false,
          otpSent: true,
          phoneNumber: phoneNumber,
        );
        return true;
      },
    );
  }
  
  /// Verify OTP and log in user
  Future<bool> verifyOTP(String otpCode) async {
    if (state.phoneNumber == null) {
      state = state.copyWith(
        errorMessage: 'Phone number not found. Please restart login.',
      );
      return false;
    }
    
    state = state.copyWith(isLoading: true, clearError: true);
    
    final result = await verifyOTPUseCase(
      VerifyOTPParams(
        phoneNumber: state.phoneNumber!,
        otpCode: otpCode,
      ),
    );
    
    return result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: _mapFailureToMessage(failure),
        );
        return false;
      },
      (user) {
        state = state.copyWith(
          user: user,
          isLoading: false,
          isAuthenticated: true,
          otpSent: false,
        );
        return true;
      },
    );
  }

  /// Sign in with Email
  Future<bool> signInWithEmail({required String email, required String password}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    
    final result = await signInWithEmailUseCase(
      SignInWithEmailParams(email: email, password: password),
    );
    
    return result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: _mapFailureToMessage(failure),
        );
        return false;
      },
      (user) {
        state = state.copyWith(
          user: user,
          isLoading: false,
          isAuthenticated: true,
        );
        return true;
      },
    );
  }

  /// Sign up with Email
  Future<bool> signUpWithEmail({
    required String email, 
    required String password, 
    required String fullName
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    
    final result = await signUpWithEmailUseCase(
      SignUpWithEmailParams(email: email, password: password, fullName: fullName),
    );
    
    return result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: _mapFailureToMessage(failure),
        );
        return false;
      },
      (user) {
        state = state.copyWith(
          user: user,
          isLoading: false,
          isAuthenticated: true,
        );
        return true;
      },
    );
  }

  /// Sign in with Google
  Future<bool> signInWithGoogle() async {
    state = state.copyWith(isLoading: true, clearError: true);
    
    final result = await signInWithGoogleUseCase(const NoParams());
    
    return result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: _mapFailureToMessage(failure),
        );
        return false;
      },
      (success) {
        // If success is true, we need to fetch the user. 
        // signInWithGoogle returns bool (success status).
        // If it's true, we assume session is created, so let's refresh user.
        if (success) {
          refreshUser(); // This will update the state with user
          return true;
        } else {
             state = state.copyWith(
              isLoading: false,
              errorMessage: "Google Sign In Failed",
            );
            return false;
        }
      },
    );
  }
  
  /// Sign out current user
  Future<void> signOut() async {
    state = state.copyWith(isLoading: true);
    
    await signOutUseCase(const NoParams());
    
    state = const AuthState(); // Reset to initial state
  }
  
  /// Refresh current user data
  Future<void> refreshUser() async {
    final result = await getCurrentUserUseCase(const NoParams());
    
    result.fold(
      (failure) {
        // Handle refresh failure silently or show error
        state = state.copyWith(isLoading: false);
      },
      (user) {
        state = state.copyWith(
          user: user,
          isLoading: false,
          isAuthenticated: true
        );
      },
    );
  }
  
  /// Clear error message
  void clearError() {
    state = state.copyWith(clearError: true);
  }
  
  /// Reset OTP sent state (for resend functionality)
  void resetOTPState() {
    state = state.copyWith(otpSent: false);
  }
  
  /// Map failure to user-friendly message
  String _mapFailureToMessage(Failure failure) {
    if (failure is NetworkFailure) {
      return 'No internet connection. Please check your network.';
    } else if (failure is InvalidOTPFailure) {
      return 'Invalid or expired OTP. Please try again.';
    } else if (failure is UnauthorizedFailure) {
      return 'Unauthorized. Please login again.';
    } else if (failure is ServerFailure) {
      return 'Server error: ${failure.message}';
    } else if (failure is AuthFailure) {
      return failure.message;
    } else {
      return 'An unexpected error occurred. Please try again.';
    }
  }
}

/// Auth state provider
final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    sendOTPUseCase: ref.watch(sendOTPUseCaseProvider),
    verifyOTPUseCase: ref.watch(verifyOTPUseCaseProvider),
    getCurrentUserUseCase: ref.watch(getCurrentUserUseCaseProvider),
    signOutUseCase: ref.watch(signOutUseCaseProvider),
    signInWithEmailUseCase: ref.watch(signInWithEmailUseCaseProvider),
    signUpWithEmailUseCase: ref.watch(signUpWithEmailUseCaseProvider),
    signInWithGoogleUseCase: ref.watch(signInWithGoogleUseCaseProvider),
  );
});

/// Convenience provider to check if user is authenticated
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authNotifierProvider).isAuthenticated;
});

/// Convenience provider to get current user
final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authNotifierProvider).user;
});
