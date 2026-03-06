class ApiUrl {
  static String baseUrl = 'https://api.vhandar.com/';

  static String login = 'login';
  static String sendOTP = 'send-otp/register';
  static String register = 'customer/register';
  static String banners = 'banners';
  static String categories = 'categories';
  static String subCategories = 'sub-categories';
  static String products = 'products';

  static String categoryByName(String name) => 'categories/name/$name';
}
