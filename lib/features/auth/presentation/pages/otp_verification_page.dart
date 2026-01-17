import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/validators.dart';
import '../providers/auth_state_provider.dart';

/// OTP verification page
class OTPVerificationPage extends ConsumerStatefulWidget {
  const OTPVerificationPage({super.key});

  @override
  ConsumerState<OTPVerificationPage> createState() => _OTPVerificationPageState();
}

class _OTPVerificationPageState extends ConsumerState<OTPVerificationPage> {
  final _formKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();
  
  // Resend OTP timer
  Timer? _resendTimer;
  int _resendCountdown = AppConstants.otpResendCooldownSeconds;
  bool _canResend = false;
  
  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }
  
  @override
  void dispose() {
    _otpController.dispose();
    _resendTimer?.cancel();
    super.dispose();
  }
  
  void _startResendTimer() {
    _canResend = false;
    _resendCountdown = AppConstants.otpResendCooldownSeconds;
    
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_resendCountdown > 0) {
          _resendCountdown--;
        } else {
          _canResend = true;
          timer.cancel();
        }
      });
    });
  }
  
  Future<void> _handleVerifyOTP() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    FocusScope.of(context).unfocus();
    
    final otpCode = _otpController.text.trim();
    final authNotifier = ref.read(authNotifierProvider.notifier);
    
    final success = await authNotifier.verifyOTP(otpCode);
    
    if (success && mounted) {
      // Navigate to home (will be handled by GoRouter in full implementation)
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }
  
  Future<void> _handleResendOTP() async {
    final authState = ref.read(authNotifierProvider);
    if (authState.phoneNumber == null) return;
    
    final authNotifier = ref.read(authNotifierProvider.notifier);
    authNotifier.resetOTPState();
    
    final success = await authNotifier.sendOTP(authState.phoneNumber!);
    
    if (success && mounted) {
      _startResendTimer();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.get('otp_sent', 'en')),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final theme = Theme.of(context);
    
    const languageCode = 'en';
    
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.get('verify_otp', languageCode)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                
                // Icon
                Icon(
                  Icons.sms_outlined,
                  size: 80,
                  color: theme.colorScheme.primary,
                ),
                
                const SizedBox(height: 24),
                
                // Instructions
                Text(
                  AppStrings.get('enter_otp', languageCode),
                  style: theme.textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 8),
                
                // Phone number display
                if (authState.phoneNumber != null)
                  Text(
                    'Sent to ${AppConstants.defaultCountryCode} ${authState.phoneNumber}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                
                const SizedBox(height: 40),
                
                // OTP input field
                TextFormField(
                  controller: _otpController,
                  enabled: !authState.isLoading,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineMedium,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(AppConstants.otpLength),
                  ],
                  decoration: InputDecoration(
                    hintText: '000000',
                    counterText: '',
                    prefixIcon: const Icon(Icons.lock_outline),
                  ),
                  maxLength: AppConstants.otpLength,
                  validator: Validators.validateOTP,
                  onFieldSubmitted: (_) => _handleVerifyOTP(),
                ),
                
                const SizedBox(height: 16),
                
                // Error message
                if (authState.errorMessage != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: theme.colorScheme.error,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            authState.errorMessage!,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.error,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                
                const SizedBox(height: 32),
                
                // Verify button
                ElevatedButton(
                  onPressed: authState.isLoading ? null : _handleVerifyOTP,
                  child: authState.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(AppStrings.get('verify_otp', languageCode)),
                ),
                
                const SizedBox(height: 24),
                
                // Resend OTP section
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Didn't receive the code? ",
                      style: theme.textTheme.bodyMedium,
                    ),
                    if (_canResend && !authState.isLoading)
                      TextButton(
                        onPressed: _handleResendOTP,
                        child: Text(AppStrings.get('resend_otp', languageCode)),
                      )
                    else
                      Text(
                        'Resend in ${_resendCountdown}s',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
