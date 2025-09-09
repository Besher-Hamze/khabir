class AppConstants {
  // App Info
  static const String appName = 'Khabir User';
  static const String appVersion = '1.0.0';

  // API Base URLs - Updated to match Postman collection
  static const String baseUrl = 'http://192.168.74.2:3069/api';
  static const String baseUrlImage = 'http://192.168.74.2:3069';
  static const String socketUrl = 'ws://192.168.74.2:3069/location-tracking';

  // API Endpoints
  static const String authLogin = '/auth/login';
  static const String authPhoneLogin = '/auth/phone/login';
  static const String authRegisterInitiate = '/auth/register/initiate';
  static const String authRegisterComplete = '/auth/register/complete';
  static const String authPasswordResetSendOTP =
      '/auth/phone/password-reset/send-otp';
  static const String authPasswordReset = '/auth/phone/password-reset';
  static const String authCheckStatus = '/auth/check-status';

  // User Endpoints
  static const String userProfile = '/users/profile';
  static const String userLocations = '/users/locations';
  static const String userLocationById = '/users/locations/{id}';
  static const String setDefaultLocation = '/users/locations/{id}/set-default';
  static const String updateUserProfile = '/users/{userId}';

  // Orders Endpoints
  static const String orders = '/orders';
  static const String orderHistory = '/orders/history';

  // Invoices Endpoints
  static const String invoices = '/invoices';
  static const String invoiceMarkPaid = '/invoices/{id}/mark-paid';
  static const String invoicePaymentStatus = '/invoices/{id}/payment-status';
  static const String invoiceMarkFailed = '/invoices/{id}/mark-failed';
  static const String invoiceRefund = '/invoices/{id}/refund';

  // Search Endpoints
  static const String searchServices = '/search/services';
  static const String searchProviders = '/search/providers';
  static const String searchServicesPaginated = '/search/services/paginated';
  static const String searchTrending = '/search/trending';
  static const String searchSuggestions = '/search/suggestions';

  // Provider Ratings Endpoints
  static const String providerRatings = '/provider-ratings';
  static const String providerRatingsMy = '/provider-ratings/my-ratings';
  static const String providerRatingsTopRated = '/provider-ratings/top-rated';

  // Offers Endpoints
  static const String offers = '/offers';
  static const String offersActive = '/offers/active';
  static const String availableOffers = '/offers/available';
  static const String adBanners = '/ad-banners';

  // Categories & Services Endpoints
  static const String categories = '/categories';
  static const String services = '/services';
  static const String servicesByCategory = '/services/category/{id}';

  // Provider Endpoints
  static const String providersByService = '/providers/service/{id}';
  static const String providerServices =
      '/providers/{providerId}/categories/{categoryId}/services';
  static const String createServiceRequest = '/orders/multiple-services';
  static const String topProviders = '/providers/top/comprehensive';
  static const String providerById = '/providers/{id}';
  // Orders Endpoints
  static const String getUserOrders = '/orders';

  // Location Tracking Endpoints
  static const String locationTrackingHealth = '/location-tracking/health';
  static const String locationTrackingCurrentLocation =
      '/location-tracking/order/{orderId}/current-location';
  static const String locationTrackingHistory =
      '/location-tracking/order/{orderId}/location-history';
  static const String locationTrackingEstimatedArrival =
      '/location-tracking/order/{orderId}/estimated-arrival';
  static const String locationTrackingStatus =
      '/location-tracking/order/{orderId}/tracking-status';
  static const String locationTrackingUserOrders =
      '/location-tracking/user/{userId}/orders';
  static const String locationTrackingStart = '/location-tracking/start';
  static const String locationTrackingStop = '/location-tracking/stop';

  // Storage Keys
  static const String keyToken = 'token';
  static const String keyUser = 'user';
  static const String keyLanguage = 'language';
  static const String keyOnboarding = 'onboarding_completed';
  static const String keyTheme = 'theme_mode';
  static const String keyLocation = 'user_location';
  static const String keyAddresses = 'saved_addresses';

  // Default Values
  static const String defaultLanguage = 'ar';
  static const int defaultTimeout = 30000;
  static const int otpLength = 6;
  static const int maxImageSize = 5 * 1024 * 1024; // 5MB

  // Pagination
  static const int pageSize = 10;
  static const int maxPageSize = 50;

  // Validation
  static const int minPasswordLength = 6;
  static const int maxPasswordLength = 20;
  static const int minUsernameLength = 3;
  static const int maxUsernameLength = 30;

  // Animation Durations
  static const Duration shortAnimationDuration = Duration(milliseconds: 200);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 300);
  static const Duration longAnimationDuration = Duration(milliseconds: 500);

  // UI Constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double defaultRadius = 12.0;
  static const double smallRadius = 8.0;
  static const double largeRadius = 16.0;

  // Map Constants
  static const double defaultZoom = 14.0;
  static const double defaultLatitude = 24.7136;
  static const double defaultLongitude = 46.6753; // Riyadh coordinates

  // Rating
  static const double maxRating = 5.0;
  static const double minRating = 1.0;

  // WhatsApp Support
  static const String supportWhatsApp = '+966500000000';
  static const String whatsAppUrl = 'https://wa.me/';

  // Social Media
  static const String instagramUrl = 'https://instagram.com/khabir_app';
  static const String snapchatUrl = 'https://snapchat.com/add/khabir_app';
  static const String tiktokUrl = 'https://tiktok.com/@khabir_app';

  // Google Play Store
  static const String providerAppId =
      'com.akwan.khabirkhadmat_new.khabir_provider';
  static const String playStoreUrl =
      'https://play.google.com/store/apps/details?id=';

  // Error Messages Keys
  static const String networkError = 'network_error';
  static const String serverError = 'server_error';
  static const String unknownError = 'unknown_error';
  static const String validationError = 'validation_error';

  // Success Messages Keys
  static const String loginSuccess = 'login_success';
  static const String signupSuccess = 'signup_success';
  static const String passwordResetSuccess = 'password_reset_success';

  // Image Paths
  static const String imagesPath = 'assets/images/';
  static const String iconsPath = 'assets/icons/';
  static const String lottiePath = 'assets/lottie/';

  // Common Image Names
  static const String logo = 'logo.png';
  static const String logoWhite = 'logo_white.png';
  static const String splash = 'splash.png';
  static const String onboarding1 = 'onboarding_1.png';
  static const String onboarding2 = 'onboarding_2.png';
  static const String onboarding3 = 'onboarding_3.png';
  static const String placeholder = 'placeholder.png';
  static const String noData = 'no_data.png';
  static const String noInternet = 'no_internet.png';

  // Service Status
  static const String statusPending = 'pending';
  static const String statusAccepted = 'accepted';
  static const String statusRejected = 'rejected';
  static const String statusInProgress = 'in_progress';
  static const String statusCompleted = 'completed';
  static const String statusCancelled = 'cancelled';

  // Provider Status
  static const String providerOnline = 'online';
  static const String providerOffline = 'offline';
  static const String providerBusy = 'busy';

  // Time Options
  static const String timeNow = 'now';
  static const String timeTomorrow = 'tomorrow';
  static const String timeCustom = 'custom';

  static const List<Map<String, String>> OMAN_GOVERNORATES = [
    {"value": "Muscat", "label": "Muscat - مسقط"},
    {"value": "Dhofar", "label": "Dhofar - ظفار"},
    {"value": "Musandam", "label": "Musandam - مسندم"},
    {"value": "Buraimi", "label": "Buraimi - البريمي"},
    {"value": "Dakhiliyah", "label": "Dakhiliyah - الداخلية"},
    {"value": "North Al Batinah", "label": "North Al Batinah - شمال الباطنة"},
    {"value": "South Al Batinah", "label": "South Al Batinah - جنوب الباطنة"},
    {
      "value": "North Al Sharqiyah",
      "label": "North Al Sharqiyah - شمال الشرقية",
    },
    {
      "value": "South Al Sharqiyah",
      "label": "South Al Sharqiyah - جنوب الشرقية",
    },
    {"value": "Al Wusta", "label": "Al Wusta - الوسطى"},
  ];
}
