/// Core application constants
class AppConstants {
  // API Configuration
  // Note: For Flutter web, environment variables must be hardcoded or passed via --dart-define
  static const String supabaseUrl = 'https://ckprtgafbamrmdwflzlf.supabase.co';
  
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNrcHJ0Z2FmYmFtcm1kd2ZsemxmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njg2NTU5MDYsImV4cCI6MjA4NDIzMTkwNn0._df9E77e_OFNxUU0AV4OojVjxchdso-7CJPOwwJ5Xrk';
  
  // Razorpay Configuration
  static const String razorpayKeyId = String.fromEnvironment(
    'RAZORPAY_KEY_ID',
    defaultValue: '',
  );
  
  // Cloudinary Configuration
  static const String cloudinaryCloudName = String.fromEnvironment(
    'CLOUDINARY_CLOUD_NAME',
    defaultValue: '',
  );
  
  static const String cloudinaryUploadPreset = String.fromEnvironment(
    'CLOUDINARY_UPLOAD_PRESET',
    defaultValue: 'agriflutter_preset',
  );
  
  // App Configuration
  static const String appName = 'AgriServe';
  static const String appVersion = '1.0.0';
  
  // Default Values
  static const String defaultLanguage = 'en';
  static const String defaultCurrency = 'INR';
  static const String defaultCountryCode = '+91';
  
  // Geolocation
  static const double defaultServiceRadiusKm = 20.0;
  static const double minServiceRadiusKm = 5.0;
  static const double maxServiceRadiusKm = 100.0;
  static const double searchRadiusKm = 50.0;
  
  // OTP Configuration
  static const int otpLength = 6;
  static const int otpExpiryMinutes = 10;
  static const int otpResendCooldownSeconds = 60;
  
  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
  
  // Image Upload
  static const int maxImageSizeMB = 5;
  static const int maxImagesPerListing = 6;
  static const List<String> allowedImageExtensions = ['jpg', 'jpeg', 'png', 'webp'];
  
  // Rating
  static const int minRating = 1;
  static const int maxRating = 5;
  
  // Timeout Durations
  static const Duration networkTimeout = Duration(seconds: 30);
  static const Duration cacheValidity = Duration(hours: 24);
  
  // Local Storage Keys
  static const String userProfileKey = 'user_profile';
  static const String authTokenKey = 'auth_token';
  static const String activeRoleKey = 'active_role';
  static const String selectedLanguageKey = 'selected_language';
  static const String recentSearchesKey = 'recent_searches';
  
  // Routes
  static const String splashRoute = '/';
  static const String loginRoute = '/login';
  static const String otpVerificationRoute = '/otp-verification';
  static const String homeRoute = '/home';
  static const String searchRoute = '/search';
  static const String equipmentDetailsRoute = '/equipment/:id';
  static const String labourDetailsRoute = '/labour/:id';
  static const String bookingRoute = '/booking';
  static const String bookingDetailsRoute = '/booking/:id';
  static const String profileRoute = '/profile';
  static const String editProfileRoute = '/profile/edit';
  static const String myEquipmentRoute = '/my-equipment';
  static const String addEquipmentRoute = '/add-equipment';
  
  // Error Messages
  static const String genericErrorMessage = 'Something went wrong. Please try again.';
  static const String networkErrorMessage = 'No internet connection. Please check your network.';
  static const String locationErrorMessage = 'Unable to get your location. Please enable location services.';
  static const String authErrorMessage = 'Authentication failed. Please login again.';
}
