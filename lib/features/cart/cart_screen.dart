import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lets_vhandar/core/constants/color_constant.dart';
import 'package:lets_vhandar/features/cart/providers/cart_provider.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartItems = ref.watch(cartProvider);
    final totalItems = ref.watch(totalCartItemsProvider);
    final totalPrice = ref.watch(totalCartPriceProvider);
    final totalMrp = ref.watch(totalCartMrpProvider);

    return Container(
      color: const Color(0xFFF5F6F8), // Light grey background
      child: Column(
        children: [
          // Custom Header
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'My Cart',
                  style: TextStyle(
                    color: AppColor.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 20.sp,
                  ),
                ),
                if (cartItems.isNotEmpty)
                  InkWell(
                    onTap: () {
                      ref.read(cartProvider.notifier).clearCart();
                    },
                    borderRadius: BorderRadius.circular(8.r),
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: AppColor.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        'Clear Cart',
                        style: TextStyle(
                          color: AppColor.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 12.sp,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: cartItems.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.shopping_cart_outlined,
                            size: 80.sp, color: Colors.grey.shade400),
                        SizedBox(height: 16.h),
                        Text('Your cart is empty',
                            style: TextStyle(
                                fontSize: 18.sp,
                                color: AppColor.textBlack54,
                                fontWeight: FontWeight.w500)),
                      ],
                    ),
                  )
                : ListView(
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    children: [
                      // Apply Coupons Banner (Mockup)
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 16.w),
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(color: Colors.green.shade100),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.local_offer,
                                color: AppColor.primary, size: 20.sp),
                            SizedBox(width: 8.w),
                            Text('Apply Coupons & Offers',
                                style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600,
                                    color: AppColor.textBlack87)),
                            const Spacer(),
                            Icon(Icons.keyboard_arrow_right,
                                color: AppColor.textBlack54),
                          ],
                        ),
                      ),
                      SizedBox(height: 16.h),

                      // Cart Items List
                      Container(
                        color: Colors.white,
                        child: ListView.separated(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: cartItems.length,
                          separatorBuilder: (context, index) => Divider(
                              height: 1,
                              color: Colors.grey.shade200,
                              indent: 16.w,
                              endIndent: 16.w),
                          itemBuilder: (context, index) {
                            final item = cartItems[index];
                            final hasDiscount = item.product.discount != null &&
                                (item.product.discount?.value ?? 0) > 0;

                            return Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 16.w, vertical: 16.h),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Product Image
                                  Container(
                                    width: 60.w,
                                    height: 60.h,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Colors.grey.shade200),
                                      borderRadius: BorderRadius.circular(8.r),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8.r),
                                      child: item.product.images?.isNotEmpty ==
                                              true
                                          ? Image.network(
                                              item.product.images!.first.url ??
                                                  '',
                                              fit: BoxFit.cover,
                                            )
                                          : Icon(Icons.image,
                                              color: Colors.grey.shade300),
                                    ),
                                  ),
                                  SizedBox(width: 12.w),
                                  // Details
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.product.name ?? '',
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.bold,
                                            color: AppColor.textBlack87,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        SizedBox(height: 4.h),
                                        Text(
                                          '${item.product.unitValue?.toInt() ?? 1} ${item.product.unit ?? ''}',
                                          style: TextStyle(
                                            fontSize: 12.sp,
                                            color: AppColor.textMuted,
                                          ),
                                        ),
                                        SizedBox(height: 4.h),
                                        Row(
                                          children: [
                                            Text(
                                              'Rs ${item.product.actualPrice.toInt()}',
                                              style: TextStyle(
                                                fontSize: 14.sp,
                                                fontWeight: FontWeight.bold,
                                                color: AppColor.textBlack,
                                              ),
                                            ),
                                            if (hasDiscount) ...[
                                              SizedBox(width: 6.w),
                                              Text(
                                                'Rs ${item.product.pricePerUnit?.toInt()}',
                                                style: TextStyle(
                                                  fontSize: 11.sp,
                                                  color: AppColor
                                                      .textStrikeThrough,
                                                  decoration: TextDecoration
                                                      .lineThrough,
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(width: 8.w),
                                  // Quantity Selector
                                  Container(
                                    height: 32.h,
                                    decoration: BoxDecoration(
                                      color: AppColor.primary,
                                      borderRadius: BorderRadius.circular(6.r),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        GestureDetector(
                                          onTap: () => ref
                                              .read(cartProvider.notifier)
                                              .updateQuantity(item.product.id!,
                                                  item.quantity - 1),
                                          child: Container(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 8.w, vertical: 4.h),
                                            color: Colors.transparent,
                                            child: Icon(Icons.remove,
                                                color: Colors.white,
                                                size: 16.sp),
                                          ),
                                        ),
                                        Text(
                                          '${item.quantity}',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13.sp,
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () => ref
                                              .read(cartProvider.notifier)
                                              .updateQuantity(item.product.id!,
                                                  item.quantity + 1),
                                          child: Container(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 8.w, vertical: 4.h),
                                            color: Colors.transparent,
                                            child: Icon(Icons.add,
                                                color: Colors.white,
                                                size: 16.sp),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),

                      SizedBox(height: 16.h),

                      // Bill Details
                      _BillDetailsCard(
                        totalItems: totalItems,
                        totalPrice: totalPrice,
                        totalMrp: totalMrp,
                      ),
                      SizedBox(height: 16.h),

                      // Expandable Delivery Instructions
                      const _DeliveryInstructionsCard(),
                      SizedBox(height: 8.h),

                      // Expandable Partner Safety
                      const _DeliveryPartnerSafetyCard(),
                      SizedBox(height: 8.h),

                      // Cancellation Policy
                      const _CancellationPolicyCard(),
                      SizedBox(height: 8.h),

                      // Delivery To (Non-expandable)
                      _buildInfoRow(
                          Icons.location_on_outlined, 'Delivery To', null,
                          actionText: 'Choose'),

                      SizedBox(height: 32.h), // Some bottom padding
                    ],
                  ),
          ),
          // Bottom Fixed Checkout Bar
          if (cartItems.isNotEmpty)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: InkWell(
                onTap: () {},
                borderRadius: BorderRadius.circular(12.r),
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  decoration: BoxDecoration(
                    color: AppColor.primary,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Rs. ${totalPrice.toInt()}',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'TOTAL',
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w500,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            'Proceed to Pay',
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Icon(Icons.arrow_forward_ios,
                              size: 14.sp, color: Colors.white),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String title, String? subtitle,
      {String? actionText}) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColor.primary, size: 28.sp),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColor.textBlack87)),
                if (subtitle != null) ...[
                  SizedBox(height: 2.h),
                  Text(subtitle,
                      style: TextStyle(
                          fontSize: 12.sp, color: AppColor.textMuted)),
                ]
              ],
            ),
          ),
          if (actionText != null) ...[
            SizedBox(width: 8.w),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(actionText,
                  style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColor.primary)),
            )
          ] else ...[
            Icon(Icons.keyboard_arrow_right, color: Colors.grey.shade400),
          ]
        ],
      ),
    );
  }
}

// Below are the extracted private widgets to keep the code clean.

class _BillDetailsCard extends StatelessWidget {
  final int totalItems;
  final double totalPrice;
  final double totalMrp;

  const _BillDetailsCard({
    required this.totalItems,
    required this.totalPrice,
    required this.totalMrp,
  });

  @override
  Widget build(BuildContext context) {
    final double savings = totalMrp - totalPrice;
    final bool hasSavings = savings > 0;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bill details',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColor.greenTxtColor,
                  ),
                ),
                SizedBox(height: 16.h),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.receipt_long,
                            size: 16.sp, color: AppColor.textMuted),
                        SizedBox(width: 8.w),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Items total',
                                style: TextStyle(
                                    fontSize: 13.sp,
                                    color: AppColor.textBlack87)),
                            if (hasSavings) ...[
                              SizedBox(height: 4.h),
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 6.w, vertical: 2.h),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFBE4B9),
                                  borderRadius: BorderRadius.circular(4.r),
                                ),
                                child: Text('Saved Rs.${savings.toInt()}',
                                    style: TextStyle(
                                        fontSize: 10.sp,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF8D5B18))),
                              ),
                            ]
                          ],
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (hasSavings)
                          Text('Rs. ${totalMrp.toInt()}',
                              style: TextStyle(
                                  fontSize: 13.sp,
                                  color: AppColor.textStrikeThrough,
                                  decoration: TextDecoration.lineThrough)),
                        Text('Rs. ${totalPrice.toInt()}',
                            style: TextStyle(
                                fontSize: 13.sp, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.delivery_dining,
                            size: 16.sp, color: AppColor.textMuted),
                        SizedBox(width: 8.w),
                        Text('Delivery charge',
                            style: TextStyle(
                                fontSize: 13.sp, color: AppColor.textBlack87)),
                        SizedBox(width: 4.w),
                        Icon(Icons.info_outline,
                            size: 14.sp, color: AppColor.textMuted),
                      ],
                    ),
                    Row(
                      children: [
                        Text('Rs.100',
                            style: TextStyle(
                                fontSize: 13.sp,
                                color: AppColor.textStrikeThrough,
                                decoration: TextDecoration.lineThrough)),
                        SizedBox(width: 6.w),
                        Text('FREE',
                            style: TextStyle(
                                fontSize: 13.sp,
                                color: AppColor.secondary,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.shopping_bag_outlined,
                            size: 16.sp, color: AppColor.textMuted),
                        SizedBox(width: 8.w),
                        Text('Handling Charge',
                            style: TextStyle(
                                fontSize: 13.sp, color: AppColor.textBlack87)),
                        SizedBox(width: 4.w),
                        Icon(Icons.info_outline,
                            size: 14.sp, color: AppColor.textMuted),
                      ],
                    ),
                    Text('Rs.0',
                        style: TextStyle(
                            fontSize: 13.sp, fontWeight: FontWeight.bold)),
                  ],
                ),
                SizedBox(height: 16.h),
                Divider(color: Colors.grey.shade200, height: 1),
                SizedBox(height: 16.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Grand total',
                            style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.bold,
                                color: AppColor.greenTxtColor)),
                        SizedBox(height: 2.h),
                        Text('Incl. all taxes and charges',
                            style: TextStyle(
                                fontSize: 11.sp, color: AppColor.textMuted)),
                      ],
                    ),
                    Text('Rs. ${totalPrice.toInt()}',
                        style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColor.primary)),
                  ],
                ),
              ],
            ),
          ),
          // Saved Banner bottom part
          if (hasSavings)
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 8.h),
              decoration: BoxDecoration(
                color: const Color(0xFFFBE4B9),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(12.r),
                  bottomRight: Radius.circular(12.r),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.local_offer,
                      size: 14.sp, color: const Color(0xFF8D5B18)),
                  SizedBox(width: 6.w),
                  RichText(
                    text: TextSpan(
                      style: TextStyle(
                          fontSize: 11.sp, color: const Color(0xFF8D5B18)),
                      children: [
                        TextSpan(
                            text: 'Rs. ${savings.toInt()} ',
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        const TextSpan(text: 'Saved! Free Delivery!'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _DeliveryInstructionsCard extends StatefulWidget {
  const _DeliveryInstructionsCard();

  @override
  State<_DeliveryInstructionsCard> createState() =>
      _DeliveryInstructionsCardState();
}

class _DeliveryInstructionsCardState extends State<_DeliveryInstructionsCard> {
  int _selectedIndex = -1;

  final List<Map<String, dynamic>> _options = [
    {
      'icon': Icons.notifications_off_outlined,
      'title': 'Not Ring The Bell',
      'subtitle': 'Partner will not ring the bell'
    },
    {
      'icon': Icons.door_back_door_outlined,
      'title': 'No Contact Delivery',
      'subtitle': 'Partner will leave your order at your door'
    },
    {
      'icon': Icons.pets_outlined,
      'title': 'Beware Of Pets',
      'subtitle': 'Partner will be informed'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
          leading: Icon(Icons.markunread_mailbox_outlined,
              color: AppColor.primary, size: 28.sp),
          title: Text(
            'Delivery Instructions',
            style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.bold,
                color: AppColor.textBlack87),
          ),
          subtitle: Text(
            'Delivery partner will be notified',
            style: TextStyle(fontSize: 12.sp, color: AppColor.textMuted),
          ),
          children: [
            Padding(
              padding: EdgeInsets.only(left: 16.w, right: 16.w, bottom: 16.h),
              child: SizedBox(
                height: 100.h,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _options.length,
                  itemBuilder: (context, index) {
                    final isSelected = _selectedIndex == index;
                    final opt = _options[index];
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedIndex = isSelected ? -1 : index;
                        });
                      },
                      child: Container(
                        width: 140.w,
                        margin: EdgeInsets.only(right: 12.w),
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.green.shade50
                              : Colors.transparent,
                          border: Border.all(
                              color: isSelected
                                  ? AppColor.primary
                                  : Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(opt['icon'],
                                color: isSelected
                                    ? AppColor.primary
                                    : AppColor.textBlack54,
                                size: 24.sp),
                            SizedBox(height: 8.h),
                            Text(
                              opt['title'],
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected
                                      ? AppColor.primary
                                      : AppColor.textBlack87),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              opt['subtitle'],
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              style: TextStyle(
                                  fontSize: 9.sp, color: AppColor.textMuted),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DeliveryPartnerSafetyCard extends StatelessWidget {
  const _DeliveryPartnerSafetyCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
          leading: Icon(Icons.two_wheeler_outlined,
              color: AppColor.primary, size: 28.sp),
          title: Text(
            'Delivery Partner\'s Safety',
            style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.bold,
                color: AppColor.textBlack87),
          ),
          subtitle: Text(
            'Learn more about how we ensure their safety',
            style: TextStyle(fontSize: 12.sp, color: AppColor.textMuted),
          ),
          children: [
            Padding(
              padding: EdgeInsets.only(left: 16.w, right: 16.w, bottom: 16.h),
              child: Column(
                children: [
                  Icon(Icons.shield_outlined,
                      size: 60.sp, color: Colors.green.shade200),
                  SizedBox(height: 12.h),
                  Text(
                    'Here\'s How We Do It',
                    style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColor.textBlack),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'At Vhandar, Rider\'s safety is our responsibility',
                    style:
                        TextStyle(fontSize: 12.sp, color: AppColor.textMuted),
                  ),
                  SizedBox(height: 16.h),
                  _buildSafetyPoint(Icons.speed,
                      'Delivery partners ride safely at an average speed of 15kmph per delivery'),
                  SizedBox(height: 8.h),
                  _buildSafetyPoint(Icons.timer_off_outlined,
                      'No penalties for late deliveries & no incentives for on-time deliveries'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSafetyPoint(IconData icon, String text) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColor.primary, size: 20.sp),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                  fontSize: 11.sp,
                  color: AppColor.greenTxtColor,
                  fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}

class _CancellationPolicyCard extends StatelessWidget {
  const _CancellationPolicyCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Cancellation Policy',
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.bold,
              color: AppColor.greenTxtColor,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Orders cannot be cancelled once packed for delivery. In case of unexpected delays, a refund will be provided, if applicable.',
            style: TextStyle(
              fontSize: 12.sp,
              color: AppColor.textMuted,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
