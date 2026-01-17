import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/validators.dart';
import '../providers/auth_state_provider.dart';
import 'otp_verification_page.dart';

/// Phone number input page for OTP login
class PhoneInputPage extends ConsumerStatefulWidget {
  const PhoneInputPage({super.key});

  @override
  ConsumerState<PhoneInputPage> createState() => _PhoneInputPageState();
}

class _PhoneInputPageState extends ConsumerState<PhoneInputPage> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  
  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }
  
  Future<void> _handleSendOTP() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    // Remove focus from text field
    FocusScope.of(context).unfocus();
    
    final phoneNumber = _phoneController.text.trim();
    final authNotifier = ref.read(authNotifierProvider.notifier);
    
    final success = await authNotifier.sendOTP(phoneNumber);
    
    if (success && mounted) {
      // Navigate to OTP verification page
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const OTPVerificationPage(),
        ),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final theme = Theme.of(context);
    
    // Get language preference (default to English for now)
    const languageCode = 'en';
    
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 60),
                
                // Logo/Icon
                Icon(
                  Icons.agriculture,
                  size: 100,
                  color: theme.colorScheme.primary,
                ),
                
                const SizedBox(height: 24),
                
                // App Name
                Text(
                  AppStrings.get('app_name', languageCode),
                  style: theme.textTheme.displaySmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 8),
                
                // Tagline
                Text(
                  AppStrings.get('app_tagline', languageCode),
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 60),
                
                // Instructions
                Text(
                  AppStrings.get('enter_phone_number', languageCode),
                  style: theme.textTheme.titleLarge,
                ),
                
                const SizedBox(height: 24),
                
                // Phone number input
                TextFormField(
                  controller: _phoneController,
                  enabled: !authState.isLoading,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                  ],
                  decoration: InputDecoration(
                    labelText: AppStrings.get('phone_number', languageCode),
                    hintText: '9876543210',
                    prefixIcon: const Icon(Icons.phone),
                    prefixText: AppConstants.defaultCountryCode + ' ',
                  ),
                  validator: Validators.validatePhoneNumber,
                  onFieldSubmitted: (_) => _handleSendOTP(),
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
                
                // Send OTP button
                ElevatedButton(
                  onPressed: authState.isLoading ? null : _handleSendOTP,
                  child: authState.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(AppStrings.get('send_otp', languageCode)),
                ),
                
                const SizedBox(height: 24),
                
                // Info text
                Text(
                  'We will send you a 6-digit OTP via SMS',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
