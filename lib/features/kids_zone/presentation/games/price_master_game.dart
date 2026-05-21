import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lets_vhandar/core/constants/color_constant.dart';
import 'package:lets_vhandar/features/kids_zone/providers/kids_zone_provider.dart';

class PriceMasterProduct {
  final String name;
  final String imageEmoji;
  final int actualPrice;
  final int minRange;
  final int maxRange;

  PriceMasterProduct({
    required this.name,
    required this.imageEmoji,
    required this.actualPrice,
    required this.minRange,
    required this.maxRange,
  });
}

class PriceMasterGame extends ConsumerStatefulWidget {
  const PriceMasterGame({super.key});

  @override
  ConsumerState<PriceMasterGame> createState() => _PriceMasterGameState();
}

class _PriceMasterGameState extends ConsumerState<PriceMasterGame> {
  final List<PriceMasterProduct> _allProducts = [
    PriceMasterProduct(
        name: 'Fresh Bananas (1 Dozen)',
        imageEmoji: '🍌',
        actualPrice: 120,
        minRange: 50,
        maxRange: 200),
    PriceMasterProduct(
        name: 'Organic Cow Milk (1 Litre)',
        imageEmoji: '🥛',
        actualPrice: 100,
        minRange: 40,
        maxRange: 180),
    PriceMasterProduct(
        name: 'Local Red Apples (1 kg)',
        imageEmoji: '🍎',
        actualPrice: 280,
        minRange: 150,
        maxRange: 400),
    PriceMasterProduct(
        name: 'Sliced Sandwich Bread',
        imageEmoji: '🍞',
        actualPrice: 75,
        minRange: 30,
        maxRange: 150),
    PriceMasterProduct(
        name: 'Fresh Cauliflower (1 kg)',
        imageEmoji: '🥦',
        actualPrice: 90,
        minRange: 40,
        maxRange: 160),
    PriceMasterProduct(
        name: 'Delicious Chocolate Cookies',
        imageEmoji: '🍪',
        actualPrice: 150,
        minRange: 50,
        maxRange: 300),
    PriceMasterProduct(
        name: 'Fresh Farm Eggs (10 pcs)',
        imageEmoji: '🥚',
        actualPrice: 180,
        minRange: 100,
        maxRange: 250),
  ];

  List<PriceMasterProduct> _gameProducts = [];
  int _currentIndex = 0;
  double _sliderValue = 50;
  int _totalScore = 0;
  bool _hasGuessed = false;
  String _feedbackMessage = '';
  Color _feedbackColor = Colors.green;
  bool _isGameFinished = false;
  int _coinsEarned = 0;

  @override
  void initState() {
    super.initState();
    _startNewGame();
  }

  void _startNewGame() {
    setState(() {
      final list = [..._allProducts]..shuffle();
      _gameProducts = list.take(5).toList();
      _currentIndex = 0;
      _sliderValue = _gameProducts[0].minRange.toDouble();
      _totalScore = 0;
      _hasGuessed = false;
      _feedbackMessage = '';
      _isGameFinished = false;
      _coinsEarned = 0;
    });
  }

  void _submitGuess() {
    final product = _gameProducts[_currentIndex];
    final guessedPrice = _sliderValue.toInt();
    final difference = (guessedPrice - product.actualPrice).abs();

    int points = 0;
    String feedback = '';
    Color color = Colors.orange;

    if (difference == 0) {
      points = 100;
      feedback = '🎯 PERFECT! You guessed the exact price! +100 PTS';
      color = Colors.green.shade700;
    } else if (difference <= 15) {
      points = 80;
      feedback = '🎉 AMAZING! Almost exact! Actual: Rs.${product.actualPrice}. +80 PTS';
      color = Colors.green;
    } else if (difference <= 35) {
      points = 50;
      feedback = '👍 Great guess! Actual: Rs.${product.actualPrice}. +50 PTS';
      color = Colors.blue;
    } else if (difference <= 60) {
      points = 20;
      feedback = '😅 Not bad! Actual: Rs.${product.actualPrice}. +20 PTS';
      color = Colors.orange;
    } else {
      points = 5;
      feedback = '❌ A bit far! Actual: Rs.${product.actualPrice}. +5 PTS';
      color = Colors.red;
    }

    setState(() {
      _hasGuessed = true;
      _totalScore += points;
      _feedbackMessage = feedback;
      _feedbackColor = color;
    });
  }

  void _nextProduct() {
    if (_currentIndex < 4) {
      setState(() {
        _currentIndex++;
        _sliderValue = _gameProducts[_currentIndex].minRange.toDouble();
        _hasGuessed = false;
        _feedbackMessage = '';
      });
    } else {
      setState(() {
        _isGameFinished = true;
        _coinsEarned = _totalScore ~/ 10;
      });

      if (_coinsEarned > 0) {
        ref.read(kidsZoneProvider.notifier).addCoins(_coinsEarned);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_gameProducts.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final product = _gameProducts[_currentIndex];

    return Scaffold(
      backgroundColor: const Color(0xFFE3F2FD), // Playful blue child theme
      appBar: AppBar(
        title: const Text('Vhandar Price Master 💰'),
        centerTitle: true,
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
          child: Column(
            children: [
              // --- Score Tracker ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Item ${_currentIndex + 1} of 5',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade800,
                    ),
                  ),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Text(
                      'Score: $_totalScore',
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade900,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.h),

              if (!_isGameFinished) ...[
                // --- Product card display ---
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 24.h),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withValues(alpha: 0.1),
                        blurRadius: 16,
                      )
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        product.imageEmoji,
                        style: TextStyle(fontSize: 72.sp),
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        product.name,
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w800,
                          color: AppColor.textBlack,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'Estimate the price per unit:',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColor.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24.h),

                // --- Slider / Price guessing control ---
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(color: Colors.blue.shade100),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Rs. ${product.minRange}',
                            style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 16.w, vertical: 8.h),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            child: Text(
                              'Rs. ${_sliderValue.toInt()}',
                              style: TextStyle(
                                fontSize: 20.sp,
                                fontWeight: FontWeight.w900,
                                color: Colors.blue.shade900,
                              ),
                            ),
                          ),
                          Text(
                            'Rs. ${product.maxRange}',
                            style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey),
                          ),
                        ],
                      ),
                      SizedBox(height: 16.h),
                      Slider(
                        value: _sliderValue,
                        min: product.minRange.toDouble(),
                        max: product.maxRange.toDouble(),
                        activeColor: Colors.blue.shade700,
                        inactiveColor: Colors.blue.shade100,
                        onChanged: _hasGuessed
                            ? null
                            : (value) => setState(() => _sliderValue = value),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24.h),

                // --- Feedback Message Banner ---
                if (_hasGuessed)
                  Container(
                    width: double.infinity,
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                    decoration: BoxDecoration(
                      color: _feedbackColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                          color: _feedbackColor.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      _feedbackMessage,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: _feedbackColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                SizedBox(height: 24.h),

                // --- CTA Submit/Next Button ---
                SizedBox(
                  width: double.infinity,
                  height: 52.h,
                  child: ElevatedButton(
                    onPressed: _hasGuessed ? _nextProduct : _submitGuess,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade700,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                    ),
                    child: Text(
                      _hasGuessed ? 'Next Item ➡️' : 'Submit Guess 🎯',
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ] else ...[
                // --- Final Game Over Summary ---
                Container(
                  width: double.infinity,
                  padding:
                      EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 20,
                      )
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Great Job, Price Master! 👑',
                        style: TextStyle(
                          fontSize: 22.sp,
                          fontWeight: FontWeight.w900,
                          color: Colors.blue.shade900,
                        ),
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'Total Score achieved:',
                        style: TextStyle(
                            fontSize: 14.sp, color: AppColor.textMuted),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        '$_totalScore Points',
                        style: TextStyle(
                          fontSize: 28.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
                        ),
                      ),
                      SizedBox(height: 20.h),
                      if (_coinsEarned > 0) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.monetization_on,
                                color: Colors.orange, size: 24.sp),
                            SizedBox(width: 8.w),
                            Text(
                              '+$_coinsEarned Kids Coins!',
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange.shade800,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 6.h),
                        Text(
                          'Coins are added to your parent balance!',
                          style: TextStyle(
                              fontSize: 11.sp, color: Colors.grey.shade500),
                        ),
                      ] else
                        Text(
                          'Guess closer to earn coins next time!',
                          style: TextStyle(
                              fontSize: 12.sp, color: Colors.grey.shade500),
                        ),
                      SizedBox(height: 28.h),
                      ElevatedButton(
                        onPressed: _startNewGame,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade700,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                              horizontal: 32.w, vertical: 14.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                        ),
                        child: const Text('Play Again 🔄'),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
