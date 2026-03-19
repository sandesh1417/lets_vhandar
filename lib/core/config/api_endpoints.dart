class ApiUrl {
  static String baseUrl = 'https://api.vhandar.com/';

  static String login = 'login';
  static String sendOTP = 'send-otp/register';
  static String register = 'customer/register';
  static String banners = 'banners';
  static String categories = 'categories';
  static String subCategories = 'sub-categories';
  static String products = 'products';
  static String brands = 'brands';

  static String categoryByName(String name) => 'categories/name/$name';
  static String userProfile(String id) => 'users/$id';
  static String addresses = 'addresses';
  static String userAddresses(String userId) => 'addresses/$userId';
  static String generalSettings = 'general-settings';
  static String warehouses = 'warehouses';
}

// https://api.vhandar.com/general-settings?page=1&limit=1000
// {
//     "data": [
//         {
//             "_id": "67097d75d5813df41562bb79",
//             "deliveryCharge": 100,
//             "vat": null,
//             "tax": null,
//             "handlingCharge": 0,
//             "deliveryThreshold": 10000,
//             "packingTime": 20,
//             "businessDeliveryCharge": 10,
//             "createdAt": "2024-10-11T19:33:09.295Z",
//             "updatedAt": "2026-03-10T14:31:57.308Z",
//             "showMainBanners": true,
//             "showSliderBanners": true
//         }
//     ],
//     "status": "SUCCESS"
// }


// https://api.vhandar.com/warehouses?page=1&limit=20
// {
//     "data": {
//         "data": [
//             {
//                 "_id": "67050db54bc89befe81bb79c",
//                 "name": "Warhouse_001",
//                 "lat": 27.699114390991124,
//                 "long": 85.31821161793495,
//                 "description": "Welcome To Vhandar",
//                 "deliveryRadius": 8,
//                 "startTime": "10:00",
//                 "endTime": "10:10",
//                 "status": "active",
//                 "createdAt": "2024-10-08T10:47:17.646Z",
//                 "updatedAt": "2026-03-11T09:01:57.703Z"
//             }
//         ],
//         "pagination": {
//             "total": 1,
//             "page": "1",
//             "limit": "20",
//             "firstPage": true,
//             "isLastPage": true
//         }
//     },
//     "status": "SUCCESS"
// }

