class AppConstants {
  AppConstants._();

  // Pagination
  static const int orderPageLimit = 5;
  static const int productPageLimit = 20;
  static const int searchPageLimit = 20;

  // Cart
  static const int defaultMaxCartQuantity = 99;

  // OTP
  static const int otpTimerSeconds = 30;
  static const int otpLength = 5;

  // Network
  static const int reorderFetchTimeoutSeconds = 8;
  static const int searchDebounceMs = 500;

  // CDN
  static const String cdnBaseUrl =
      'https://vhandar.sgp1.digitaloceanspaces.com';

  // Storage keys
  static const String cartStorageKey = 'vhandar_cart';
  static const String savedListsStorageKey = 'vhandar_saved_lists';
  static const String tokenStorageKey = 'apple';
  static const String userStorageKey = 'user_data';
  static const String guestModeKey = 'guest_mode';
  static const String layoutPreferenceKey = 'is_vertical_layout';
}
