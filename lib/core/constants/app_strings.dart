/// Bilingual string resources for AgriServe
/// Supports English (en) and Hindi (hi)
class AppStrings {
  static const Map<String, Map<String, String>> _localizedValues = {
    // App Name & Branding
    'app_name': {
      'en': 'AgriServe',
      'hi': 'एग्रीसर्व',
    },
    'app_tagline': {
      'en': 'Your Agriculture Partner',
      'hi': 'आपका कृषि साथी',
    },
    
    // Authentication
    'login': {
      'en': 'Login',
      'hi': 'लॉग इन करें',
    },
    'enter_phone_number': {
      'en': 'Enter your mobile number',
      'hi': 'अपना मोबाइल नंबर दर्ज करें',
    },
    'phone_number': {
      'en': 'Phone Number',
      'hi': 'फ़ोन नंबर',
    },
    'send_otp': {
      'en': 'Send OTP',
      'hi': 'OTP भेजें',
    },
    'verify_otp': {
      'en': 'Verify OTP',
      'hi': 'OTP सत्यापित करें',
    },
    'enter_otp': {
      'en': 'Enter 6-digit OTP',
      'hi': '6 अंकों का OTP दर्ज करें',
    },
    'resend_otp': {
      'en': 'Resend OTP',
      'hi': 'OTP पुनः भेजें',
    },
    'logout': {
      'en': 'Logout',
      'hi': 'लॉग आउट',
    },
    
    // Roles
    'farmer': {
      'en': 'Farmer',
      'hi': 'किसान',
    },
    'equipment_provider': {
      'en': 'Equipment Provider',
      'hi': 'उपकरण प्रदाता',
    },
    'labour_provider': {
      'en': 'Labour Provider',
      'hi': 'श्रमिक प्रदाता',
    },
    'switch_to_farmer': {
      'en': 'Switch to Farmer Mode',
      'hi': 'किसान मोड पर स्विच करें',
    },
    'switch_to_provider': {
      'en': 'Switch to Provider Mode',
      'hi': 'प्रदाता मोड पर स्विच करें',
    },
    
    // Navigation
    'home': {
      'en': 'Home',
      'hi': 'होम',
    },
    'search': {
      'en': 'Search',
      'hi': 'खोजें',
    },
    'bookings': {
      'en': 'Bookings',
      'hi': 'बुकिंग',
    },
    'profile': {
      'en': 'Profile',
      'hi': 'प्रोफ़ाइल',
    },
    
    // Search & Discovery
    'search_equipment': {
      'en': 'Search Equipment',
      'hi': 'उपकरण खोजें',
    },
    'search_labour': {
      'en': 'Search Workers',
      'hi': 'श्रमिक खोजें',
    },
    'equipment_type': {
      'en': 'Equipment Type',
      'hi': 'उपकरण का प्रकार',
    },
    'skill_type': {
      'en': 'Skill Type',
      'hi': 'कौशल प्रकार',
    },
    'distance': {
      'en': 'Distance',
      'hi': 'दूरी',
    },
    'km_away': {
      'en': 'km away',
      'hi': 'किमी दूर',
    },
    'rating': {
      'en': 'Rating',
      'hi': 'रेटिंग',
    },
    'price_range': {
      'en': 'Price Range',
      'hi': 'मूल्य सीमा',
    },
    'filters': {
      'en': 'Filters',
      'hi': 'फ़िल्टर',
    },
    'apply_filters': {
      'en': 'Apply Filters',
      'hi': 'फ़िल्टर लागू करें',
    },
    'clear_filters': {
      'en': 'Clear Filters',
      'hi': 'फ़िल्टर हटाएं',
    },
    'no_results_found': {
      'en': 'No results found nearby',
      'hi': 'आस-पास कोई परिणाम नहीं मिला',
    },
    'voice_search': {
      'en': 'Voice Search',
      'hi': 'आवाज़ से खोजें',
    },
    
    // Equipment Types
    'tractor': {
      'en': 'Tractor',
      'hi': 'ट्रैक्टर',
    },
    'harvester': {
      'en': 'Harvester',
      'hi': 'हार्वेस्टर',
    },
    'seeder': {
      'en': 'Seeder',
      'hi': 'बीज बोने की मशीन',
    },
    'plough': {
      'en': 'Plough',
      'hi': 'हल',
    },
    'sprayer': {
      'en': 'Sprayer',
      'hi': 'छिड़काव यंत्र',
    },
    
    // Booking
    'book_now': {
      'en': 'Book Now',
      'hi': 'अभी बुक करें',
    },
    'request_booking': {
      'en': 'Request Booking',
      'hi': 'बुकिंग अनुरोध करें',
    },
    'accept_booking': {
      'en': 'Accept Booking',
      'hi': 'बुकिंग स्वीकार करें',
    },
    'reject_booking': {
      'en': 'Reject Booking',
      'hi': 'बुकिंग अस्वीकार करें',
    },
    'cancel_booking': {
      'en': 'Cancel Booking',
      'hi': 'बुकिंग रद्द करें',
    },
    'start_job': {
      'en': 'Start Job',
      'hi': 'काम शुरू करें',
    },
    'complete_job': {
      'en': 'Complete Job',
      'hi': 'काम पूरा करें',
    },
    'booking_pending': {
      'en': 'Pending Approval',
      'hi': 'स्वीकृति लंबित',
    },
    'booking_accepted': {
      'en': 'Accepted',
      'hi': 'स्वीकृत',
    },
    'booking_in_progress': {
      'en': 'In Progress',
      'hi': 'प्रगति में',
    },
    'booking_completed': {
      'en': 'Completed',
      'hi': 'पूर्ण',
    },
    'booking_rejected': {
      'en': 'Rejected',
      'hi': 'अस्वीकृत',
    },
    'booking_cancelled': {
      'en': 'Cancelled',
      'hi': 'रद्द',
    },
    
    // OTP Verification
    'enter_start_otp': {
      'en': 'Enter OTP to start job',
      'hi': 'काम शुरू करने के लिए OTP दर्ज करें',
    },
    'enter_completion_otp': {
      'en': 'Enter OTP to complete job',
      'hi': 'काम पूरा करने के लिए OTP दर्ज करें',
    },
    'otp_sent': {
      'en': 'OTP sent successfully',
      'hi': 'OTP सफलतापूर्वक भेजा गया',
    },
    'otp_verified': {
      'en': 'OTP verified successfully',
      'hi': 'OTP सफलतापूर्वक सत्यापित',
    },
    'invalid_otp': {
      'en': 'Invalid OTP',
      'hi': 'गलत OTP',
    },
    
    // Payment
    'pay_now': {
      'en': 'Pay Now',
      'hi': 'अभी भुगतान करें',
    },
    'payment_pending': {
      'en': 'Payment Pending',
      'hi': 'भुगतान लंबित',
    },
    'payment_held': {
      'en': 'Payment Held in Escrow',
      'hi': 'भुगतान सुरक्षित रखा गया',
    },
    'payment_released': {
      'en': 'Payment Released',
      'hi': 'भुगतान जारी',
    },
    'payment_failed': {
      'en': 'Payment Failed',
      'hi': 'भुगतान विफल',
    },
    'total_amount': {
      'en': 'Total Amount',
      'hi': 'कुल राशि',
    },
    'hourly_rate': {
      'en': 'Hourly Rate',
      'hi': 'प्रति घंटे दर',
    },
    'daily_rate': {
      'en': 'Daily Rate',
      'hi': 'दैनिक दर',
    },
    
    // Service Radius
    'service_radius': {
      'en': 'Service Radius',
      'hi': 'सेवा क्षेत्र',
    },
    'willing_to_travel': {
      'en': 'Willing to travel up to',
      'hi': 'यात्रा करने को तैयार',
    },
    
    // Reviews
    'rate_this_service': {
      'en': 'Rate This Service',
      'hi': 'इस सेवा को रेट करें',
    },
    'write_review': {
      'en': 'Write a Review',
      'hi': 'समीक्षा लिखें',
    },
    'submit_review': {
      'en': 'Submit Review',
      'hi': 'समीक्षा सबमिट करें',
    },
    'punctuality': {
      'en': 'Punctuality',
      'hi': 'समय की पाबंदी',
    },
    'quality': {
      'en': 'Quality',
      'hi': 'गुणवत्ता',
    },
    'communication': {
      'en': 'Communication',
      'hi': 'संचार',
    },
    
    // Profile
    'edit_profile': {
      'en': 'Edit Profile',
      'hi': 'प्रोफ़ाइल संपादित करें',
    },
    'full_name': {
      'en': 'Full Name',
      'hi': 'पूरा नाम',
    },
    'address': {
      'en': 'Address',
      'hi': 'पता',
    },
    'my_equipment': {
      'en': 'My Equipment',
      'hi': 'मेरे उपकरण',
    },
    'add_equipment': {
      'en': 'Add Equipment',
      'hi': 'उपकरण जोड़ें',
    },
    'equipment_title': {
      'en': 'Equipment Title',
      'hi': 'उपकरण का शीर्षक',
    },
    'description': {
      'en': 'Description',
      'hi': 'विवरण',
    },
    'brand': {
      'en': 'Brand',
      'hi': 'ब्रांड',
    },
    'model': {
      'en': 'Model',
      'hi': 'मॉडल',
    },
    'year': {
      'en': 'Manufacturing Year',
      'hi': 'निर्माण वर्ष',
    },
    'upload_images': {
      'en': 'Upload Images',
      'hi': 'छवियां अपलोड करें',
    },
    
    // Common Actions
    'save': {
      'en': 'Save',
      'hi': 'सहेजें',
    },
    'cancel': {
      'en': 'Cancel',
      'hi': 'रद्द करें',
    },
    'confirm': {
      'en': 'Confirm',
      'hi': 'पुष्टि करें',
    },
    'submit': {
      'en': 'Submit',
      'hi': 'जमा करें',
    },
    'yes': {
      'en': 'Yes',
      'hi': 'हाँ',
    },
    'no': {
      'en': 'No',
      'hi': 'नहीं',
    },
    'ok': {
      'en': 'OK',
      'hi': 'ठीक है',
    },
    'close': {
      'en': 'Close',
      'hi': 'बंद करें',
    },
    
    // Messages & Errors
    'loading': {
      'en': 'Loading...',
      'hi': 'लोड हो रहा है...',
    },
    'error_occurred': {
      'en': 'An error occurred',
      'hi': 'एक त्रुटि हुई',
    },
    'no_internet_connection': {
      'en': 'No internet connection',
      'hi': 'इंटरनेट कनेक्शन नहीं है',
    },
    'offline_mode': {
      'en': 'Offline Mode - Showing cached data',
      'hi': 'ऑफ़लाइन मोड - संचित डेटा दिखाया जा रहा है',
    },
    'success': {
      'en': 'Success',
      'hi': 'सफलता',
    },
    'location_permission_required': {
      'en': 'Location permission required to find nearby services',
      'hi': 'निकटवर्ती सेवाएं खोजने के लिए स्थान अनुमति आवश्यक है',
    },
    'enable_location': {
      'en': 'Enable Location',
      'hi': 'स्थान सक्षम करें',
    },
  };
  
  /// Get localized string by key and language code
  static String get(String key, String languageCode) {
    return _localizedValues[key]?[languageCode] ?? key;
  }
}

/// Extension to make string fetching easier
extension StringLocalization on String {
  String tr(String languageCode) {
    return AppStrings.get(this, languageCode);
  }
}
