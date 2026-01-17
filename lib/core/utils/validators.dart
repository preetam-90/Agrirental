/// Input validators for forms
class Validators {
  /// Validate Indian phone number (+91)
  static String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter phone number';
    }
    
    // Remove spaces and special characters
    final cleaned = value.replaceAll(RegExp(r'[^\d]'), '');
    
    // Check if it's 10 digits (Indian mobile number)
    if (cleaned.length != 10) {
      return 'Phone number must be 10 digits';
    }
    
    // Check if it starts with valid digits (6-9)
    if (!cleaned.startsWith(RegExp(r'[6-9]'))) {
      return 'Invalid phone number';
    }
    
    return null;
  }
  
  /// Validate OTP (6 digits)
  static String? validateOTP(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter OTP';
    }
    
    if (value.length != 6) {
      return 'OTP must be 6 digits';
    }
    
    if (!RegExp(r'^\d{6}$').hasMatch(value)) {
      return 'OTP must contain only numbers';
    }
    
    return null;
  }
  
  /// Validate name (non-empty, alphabets and spaces only)
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter name';
    }
    
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }
    
    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
      return 'Name can only contain letters';
    }
    
    return null;
  }
  
  /// Validate price (positive number)
  static String? validatePrice(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter price';
    }
    
    final price = double.tryParse(value);
    if (price == null) {
      return 'Invalid price';
    }
    
    if (price <= 0) {
      return 'Price must be greater than 0';
    }
    
    return null;
  }
  
  /// Validate required field
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter $fieldName';
    }
    return null;
  }
  
  /// Validate service radius (5-100 km)
  static String? validateServiceRadius(double? value) {
    if (value == null) {
      return 'Please set service radius';
    }
    
    if (value < 5 || value > 100) {
      return 'Service radius must be between 5-100 km';
    }
    
    return null;
  }
  
  /// Validate year (1900-current year)
  static String? validateYear(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Optional field
    }
    
    final year = int.tryParse(value);
    if (year == null) {
      return 'Invalid year';
    }
    
    final currentYear = DateTime.now().year;
    if (year < 1900 || year > currentYear) {
      return 'Year must be between 1900-$currentYear';
    }
    
    return null;
  }
  /// Validate email address
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter email';
    }
    
    // Basic email validation regex
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    
    return null;
  }

  /// Validate password (at least 6 characters)
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter password';
    }
    
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    
    return null;
  }
}
