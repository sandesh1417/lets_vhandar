class ApiUrl {
  static String baseUrl = 'https://api.neuralevo.com/api/v1/';

  // static String baseUrl = 'https://events.kodiary.com';
  static String loginUrl = 'auth/login/';
  static String register = 'auth/register/';
  static String me = 'auth/me/';
  static String update = 'auth/update/';
  static String delete = 'auth/delete/';
  static String refresh = 'auth/refresh/';
  static String changePassword = 'auth/change-password/';
  static String passwordResetComplete = 'auth/password-reset/complete/';
  static String resetPassword = 'auth/reset-password/';
  static String reAccVerification = 'auth/resend-account-verification/';
  static String accVerification = 'auth/account-verification/{token}';
  static String verification = 'auth/verification/{token}';
  static String verifyOTP = 'auth/verify_otp/';
  static String chatCompletion = 'chat/chatCompletion/';
  static String horoscopeChat = 'astrology/horoscope_chat/';
  static String horoscopeResponse = 'astrology/horoscope_respone/';
  static String natalChart = 'astrology/natal_chart/';
  static String googleLogin = 'auth/continue-google/';
  static String userBirthDesc = 'user/';
  static String placeApi =
      'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=balaju&key=$googleApiKey';
}

const String googleApiKey = 'AIzaSyCCzABCABWmn8dFiXBXNIqQ3UFLnx8kdXA';
