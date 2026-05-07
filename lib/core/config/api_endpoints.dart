class ApiUrl {
  static String baseUrl = 'https://api.vhandar.com/';

  static String login = 'login';
  static String sendOTP = 'send-otp/register';
  static String forgetPasswordSendOTP = 'forget-password';
  static String verifyOTP = 'verify-otp';
  static String resetPassword = 'reset-password';
  static String register = 'customer/register';
  static String banners = 'banners';
  static String categories = 'categories';
  static String subCategories = 'sub-categories';
  static String products = 'products';
  static String productsSearch = 'products/search';
  static String brands = 'brands';

  static String categoryByName(String name) => 'categories/name/$name';
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
}

// https://api.vhandar.com/orders

// {
//     "totalAmount": 20,
//     "totalDiscount": 0,
//     "totalVatAmount": 2.6,
//     "totalPayableAmount": 120,
//     "handlingCharge": 0,
//     "deliveryCharge": 100,
//     "paymentStatus": "pending",
//     "userId": "67baf2ff5d58f3aca9733828",
//     "appliedCouponCode": "",
//     "dueAmount": 0,
//     "cartId": "69b10db95745204005c896cd",
//     "products": [
//         {
//             "parentId": null,
//             "name": "Wai Wai Quick Chicken Pizza (60gm)",
//             "unit": "pcs",
//             "unitValue": 1,
//             "brandId": "6708c2f66de5c6cb419f571c",
//             "tags": [],
//             "sortOrder": null,
//             "description": "<p>Enjoy the Quicks range of ready-to-eat noodles in the Wai Wai Quick Chicken Pizza. Get the taste of pizza in a packet of noodles now with Wai Wai.</p>",
//             "quantity": 991,
//             "categoryIds": [
//                 "6707f5006de5c6cb419f353b"
//             ],
//             "subCategoryIds": [
//                 "6707f5106de5c6cb419f354f"
//             ],
//             "isVegeterian": false,
//             "pricePerUnit": 20,
//             "businessPricePerUnit": 20,
//             "type": "Instant Noodle",
//             "popularity": "",
//             "flavor": "Chicken Pizza",
//             "ingredients": "\n WHEAT Flour, Edible Vegetable Oil (Palm), WHEAT Gluten, Iodized Salt, Flavor Enhancers, Soy Sauce, Acidity Regulators, Onion, Thickener, Black Pepper, Artificial Chicken Flavor [Caramel, Water, Starch, Flavor Enhancers, Dextrose, Emulsifier ].",
//             "keyFeatures": "",
//             "shelfLife": "12 Months",
//             "manufacturerDetails": "A.CG Foods (Nepal) Pvt. Ltd.",
//             "countryOfOrigin": "Nepal",
//             "fssaiLicense": "",
//             "keyword": "",
//             "customerCareDetails": "Email: info@vhandar.com",
//             "returnPolicy": "This Item is non-returnable. For a damaged, defective, incorrect or expired item, you can request a replacement within 72 hours of delivery. In case of an incorrect item, you may raise a replacement or return request only if the item is sealed/ unopened/ unused and in original condition. ",
//             "expiryDate": "",
//             "seller": "",
//             "sellerFssai": "",
//             "disclaimer": "Every effort is made to maintain accuracy of all information. However, actual product packaging and materials may contain more and/or different information. It is recommended not to solely rely on the information presented.",
//             "discount": null,
//             "sku": "8901741003027",
//             "productShownToNormalCustomer": true,
//             "images": [
//                 "/media/product/vhandar_product_001__10__1728784898189.jpg"
//             ],
//             "warehouseIds": [
//                 "67050db54bc89befe81bb79c"
//             ],
//             "packs": null,
//             "productShownToBusinessCustomer": true,
//             "productCode": "#PDT_QHESFT",
//             "permalink": "",
//             "packagingtype": "",
//             "storageTips": "",
//             "nutrientValue": "",
//             "storageTemperature": "",
//             "marketedBy": "",
//             "quantityAlert": 100,
//             "status": "active",
//             "businessDiscount": null,
//             "maximumQuantityOrder": null,
//             "minimumQuantityOrder": null,
//             "businessMaximumQuantityOrder": null,
//             "businessMinimumQuantityOrder": null,
//             "isVatAdded": true,
//             "isFeatured": false,
//             "featuredImages": null,
//             "relatedProducts": [],
//             "_id": "670b2a2cd5813df41562d106",
//             "totalPrice": 20,
//             "netPrice": 20,
//             "count": 1,
//             "createdAt": "2024-10-13T02:02:20.391Z",
//             "updatedAt": "2024-10-13T02:02:20.391Z"
//         }
//     ],
//     "deliveryTime": "",
//     "paymentMethod": "cashOnDelivery",
//     "totalSavedAmount": 0,
//     "couponDiscount": 0,
//     "deliveryTimeSlot": null,
//     "location": {
//         "lat": 27.6931052,
//         "long": 85.28065389999999,
//         "userId": "67baf2ff5d58f3aca9733828",
//         "name": "123",
//         "description": "Kalanki, Kathmandu, Nepal",
//         "addressType": "home",
//         "landMark": null,
//         "locality": null,
//         "phoneNumber": "123",
//         "houseNumber": null,
//         "floor": null
//     }
// }

// {
//     "data": {
//         "orderId": "#OID_7SO3C",
//         "totalAmount": 20,
//         "totalDiscount": 0,
//         "totalVatAmount": 2.6,
//         "paymentStatus": "pending",
//         "totalPayableAmount": 120,
//         "deliveryCharge": 100,
//         "handlingCharge": 0,
//         "userId": "67baf2ff5d58f3aca9733828",
//         "appliedCouponCode": "",
//         "dueAmount": 0,
//         "deliveryTimeSlot": null,
//         "cartId": "69b10db95745204005c896cd",
//         "location": {
//             "lat": 27.6931052,
//             "long": 85.28065389999999,
//             "userId": "67baf2ff5d58f3aca9733828",
//             "name": "123",
//             "description": "Kalanki, Kathmandu, Nepal",
//             "addressType": "home",
//             "landMark": null,
//             "locality": null,
//             "phoneNumber": "123",
//             "houseNumber": null,
//             "floor": null,
//             "createdAt": null,
//             "updatedAt": null
//         },
//         "products": [
//             {
//                 "parentId": null,
//                 "name": "Wai Wai Quick Chicken Pizza (60gm)",
//                 "unit": "pcs",
//                 "unitValue": 1,
//                 "brandId": "6708c2f66de5c6cb419f571c",
//                 "tags": [],
//                 "sortOrder": null,
//                 "description": "<p>Enjoy the Quicks range of ready-to-eat noodles in the Wai Wai Quick Chicken Pizza. Get the taste of pizza in a packet of noodles now with Wai Wai.</p>",
//                 "quantity": 991,
//                 "categoryIds": [
//                     "6707f5006de5c6cb419f353b"
//                 ],
//                 "subCategoryIds": [
//                     "6707f5106de5c6cb419f354f"
//                 ],
//                 "isVegeterian": false,
//                 "pricePerUnit": 20,
//                 "businessPricePerUnit": 20,
//                 "type": "Instant Noodle",
//                 "popularity": "",
//                 "flavor": "Chicken Pizza",
//                 "ingredients": "\n WHEAT Flour, Edible Vegetable Oil (Palm), WHEAT Gluten, Iodized Salt, Flavor Enhancers, Soy Sauce, Acidity Regulators, Onion, Thickener, Black Pepper, Artificial Chicken Flavor [Caramel, Water, Starch, Flavor Enhancers, Dextrose, Emulsifier ].",
//                 "keyFeatures": "",
//                 "shelfLife": "12 Months",
//                 "manufacturerDetails": "A.CG Foods (Nepal) Pvt. Ltd.",
//                 "countryOfOrigin": "Nepal",
//                 "fssaiLicense": "",
//                 "keyword": "",
//                 "customerCareDetails": "Email: info@vhandar.com",
//                 "returnPolicy": "This Item is non-returnable. For a damaged, defective, incorrect or expired item, you can request a replacement within 72 hours of delivery. In case of an incorrect item, you may raise a replacement or return request only if the item is sealed/ unopened/ unused and in original condition. ",
//                 "expiryDate": "",
//                 "seller": "",
//                 "sellerFssai": "",
//                 "disclaimer": "Every effort is made to maintain accuracy of all information. However, actual product packaging and materials may contain more and/or different information. It is recommended not to solely rely on the information presented.",
//                 "discount": null,
//                 "sku": "8901741003027",
//                 "productShownToNormalCustomer": true,
//                 "images": [
//                     "/media/product/vhandar_product_001__10__1728784898189.jpg"
//                 ],
//                 "warehouseIds": [
//                     "67050db54bc89befe81bb79c"
//                 ],
//                 "packs": null,
//                 "productShownToBusinessCustomer": true,
//                 "productCode": "#PDT_QHESFT",
//                 "permalink": "",
//                 "packagingtype": "",
//                 "storageTips": "",
//                 "nutrientValue": "",
//                 "storageTemperature": "",
//                 "marketedBy": "",
//                 "quantityAlert": 100,
//                 "status": "active",
//                 "businessDiscount": null,
//                 "maximumQuantityOrder": null,
//                 "minimumQuantityOrder": null,
//                 "businessMaximumQuantityOrder": null,
//                 "businessMinimumQuantityOrder": null,
//                 "isVatAdded": true,
//                 "isFeatured": false,
//                 "featuredImages": null,
//                 "relatedProducts": [],
//                 "_id": "670b2a2cd5813df41562d106",
//                 "totalPrice": 20,
//                 "netPrice": 20,
//                 "count": 1,
//                 "createdAt": "2024-10-13T02:02:20.391Z",
//                 "updatedAt": "2024-10-13T02:02:20.391Z"
//             }
//         ],
//         "status": "pending",
//         "deliveryTime": "",
//         "totalSavedAmount": 0,
//         "couponDiscount": 0,
//         "paymentMethod": "cashOnDelivery",
//         "_id": "69bbea195745204005d21aac",
//         "createdAt": "2026-03-19T12:20:41.861Z",
//         "updatedAt": "2026-03-19T12:20:41.861Z"
//     },
//     "status": "SUCCESS"
// }



// https://api.vhandar.com/orders/search?page=1&limit=5&userId=67baf2ff5d58f3aca9733828{
//     "data": {
//         "data": [
//             {
//                 "_id": "69bbea195745204005d21aac",
//                 "orderId": "#OID_7SO3C",
//                 "totalAmount": 20,
//                 "totalDiscount": 0,
//                 "totalVatAmount": 2.6,
//                 "paymentStatus": "pending",
//                 "totalPayableAmount": 120,
//                 "deliveryCharge": 100,
//                 "handlingCharge": 0,
//                 "userId": "67baf2ff5d58f3aca9733828",
//                 "appliedCouponCode": "",
//                 "dueAmount": 0,
//                 "deliveryTimeSlot": null,
//                 "cartId": "69b10db95745204005c896cd",
//                 "location": {
//                     "lat": 27.6931052,
//                     "long": 85.28065389999999,
//                     "userId": "67baf2ff5d58f3aca9733828",
//                     "name": "123",
//                     "description": "Kalanki, Kathmandu, Nepal",
//                     "addressType": "home",
//                     "landMark": null,
//                     "locality": null,
//                     "phoneNumber": "123",
//                     "houseNumber": null,
//                     "floor": null,
//                     "createdAt": null,
//                     "updatedAt": null
//                 },
//                 "products": [
//                     {
//                         "parentId": null,
//                         "name": "Wai Wai Quick Chicken Pizza (60gm)",
//                         "unit": "pcs",
//                         "unitValue": 1,
//                         "brandId": "6708c2f66de5c6cb419f571c",
//                         "tags": [],
//                         "sortOrder": null,
//                         "description": "<p>Enjoy the Quicks range of ready-to-eat noodles in the Wai Wai Quick Chicken Pizza. Get the taste of pizza in a packet of noodles now with Wai Wai.</p>",
//                         "quantity": 991,
//                         "categoryIds": [
//                             "6707f5006de5c6cb419f353b"
//                         ],
//                         "subCategoryIds": [
//                             "6707f5106de5c6cb419f354f"
//                         ],
//                         "isVegeterian": false,
//                         "pricePerUnit": 20,
//                         "businessPricePerUnit": 20,
//                         "type": "Instant Noodle",
//                         "popularity": "",
//                         "flavor": "Chicken Pizza",
//                         "ingredients": "\n WHEAT Flour, Edible Vegetable Oil (Palm), WHEAT Gluten, Iodized Salt, Flavor Enhancers, Soy Sauce, Acidity Regulators, Onion, Thickener, Black Pepper, Artificial Chicken Flavor [Caramel, Water, Starch, Flavor Enhancers, Dextrose, Emulsifier ].",
//                         "keyFeatures": "",
//                         "shelfLife": "12 Months",
//                         "manufacturerDetails": "A.CG Foods (Nepal) Pvt. Ltd.",
//                         "countryOfOrigin": "Nepal",
//                         "fssaiLicense": "",
//                         "keyword": "",
//                         "customerCareDetails": "Email: info@vhandar.com",
//                         "returnPolicy": "This Item is non-returnable. For a damaged, defective, incorrect or expired item, you can request a replacement within 72 hours of delivery. In case of an incorrect item, you may raise a replacement or return request only if the item is sealed/ unopened/ unused and in original condition. ",
//                         "expiryDate": "",
//                         "seller": "",
//                         "sellerFssai": "",
//                         "disclaimer": "Every effort is made to maintain accuracy of all information. However, actual product packaging and materials may contain more and/or different information. It is recommended not to solely rely on the information presented.",
//                         "discount": null,
//                         "sku": "8901741003027",
//                         "productShownToNormalCustomer": true,
//                         "images": [
//                             {
//                                 "url": "https://vhandar.sgp1.digitaloceanspaces.com//media/product/vhandar_product_001__10__1728784898189.jpg",
//                                 "path": "/media/product/vhandar_product_001__10__1728784898189.jpg"
//                             }
//                         ],
//                         "warehouseIds": [
//                             "67050db54bc89befe81bb79c"
//                         ],
//                         "packs": null,
//                         "productShownToBusinessCustomer": true,
//                         "productCode": "#PDT_QHESFT",
//                         "permalink": "",
//                         "packagingtype": "",
//                         "storageTips": "",
//                         "nutrientValue": "",
//                         "storageTemperature": "",
//                         "marketedBy": "",
//                         "quantityAlert": 100,
//                         "status": "active",
//                         "businessDiscount": null,
//                         "maximumQuantityOrder": null,
//                         "minimumQuantityOrder": null,
//                         "businessMaximumQuantityOrder": null,
//                         "businessMinimumQuantityOrder": null,
//                         "isVatAdded": true,
//                         "isFeatured": false,
//                         "featuredImages": null,
//                         "relatedProducts": [],
//                         "_id": "670b2a2cd5813df41562d106",
//                         "totalPrice": 20,
//                         "netPrice": 20,
//                         "count": 1,
//                         "createdAt": "2024-10-13T02:02:20.391Z",
//                         "updatedAt": "2024-10-13T02:02:20.391Z"
//                     }
//                 ],
//                 "status": "pending",
//                 "deliveryTime": "",
//                 "totalSavedAmount": 0,
//                 "couponDiscount": 0,
//                 "paymentMethod": "cashOnDelivery",
//                 "createdAt": "2026-03-19T12:20:41.861Z",
//                 "updatedAt": "2026-03-19T12:20:41.861Z"
//             }
//         ],
//         "pagination": {
//             "total": 1,
//             "page": 1,
//             "limit": 5,
//             "firstPage": true,
//             "isLastPage": true
//         }
//     },
//     "status": "SUCCESS"
// }