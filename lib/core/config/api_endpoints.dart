class ApiUrl {
  static String baseUrl = 'https://api.vhandar.com/';

  static String login = 'login';
  static String sendOTP = 'send-otp/register';
  static String forgetPasswordSendOTP = 'forget-password';
  static String verifyOTP = 'verify-otp';
  static String resetPassword = 'reset-password';
  static String changePassword = 'change-password';
  static String register = 'customer/register';
  static String registerBusiness = 'business/register';
  static String updateProfile = 'customer/update-profile';
  static String banners = 'banners';
  static String categories = 'categories';
  static String subCategories = 'sub-categories';
  static String products = 'products';
  static String productsSearch = 'products/search';
  static String brands = 'brands';

  static String categoryByName(String name) => 'categories/name/$name';
  static String subCategoryByName(String name) => 'sub-categories/name/$name';
  static String userProfile(String id) => 'users/$id';
  static String addresses = 'addresses';
  static String userAddresses(String userId) => 'addresses/$userId';
  static String generalSettings = 'general-settings';
  static String warehouses = 'warehouses';
  static String orders = 'orders';
  static String ordersSearch = 'orders/search';
  static String orderDetail(String id) => 'orders/$id';
  static String feedbacks = 'feedbacks';
  static String faqs = 'faqs';
  static String productSuggestions = 'product-suggestions';
  static String timeSlots = 'time-slots';

  // Family Members
  static String searchUsers = 'users'; // GET ?phoneNumber=xxx
  static String familyMembers = 'family-members'; // POST
  static String familyMembersForUser(String userId) =>
      'family-members/$userId'; // GET & DELETE
  static String familyMemberRequests(String userId) =>
      'family-members/requests/$userId'; // GET pending
  static String familyMemberAccept(String requestId) =>
      'family-members/accepted/$requestId'; // PATCH

  // Shopping Lists
  static String shoppingLists = 'shopping-lists';
  static String shoppingListById(String id) => 'shopping-lists/$id';
  static String shoppingListRemoveProduct(String listId, String productId) =>
      'shopping-lists/remove/$listId/$productId';
}
