import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';
import 'package:lets_vhandar/core/constants/color_constant.dart';
import 'package:lets_vhandar/features/kids_zone/providers/kids_zone_provider.dart';

enum FoodCategory { fruits, vegetables, dairy, grains, snacks }

class SortItem {
  final String emoji;
  final String name;
  final FoodCategory category;

  const SortItem({
    required this.emoji,
    required this.name,
    required this.category,
  });
}

class SortBin {
  final FoodCategory category;
  final String label;
  final String emoji;
  Color color;
  double scale;

  SortBin({
    required this.category,
    required this.label,
    required this.emoji,
    this.color = Colors.white24,
    this.scale = 1.0,
  });
}

class SortItOutGame extends ConsumerStatefulWidget {
  const SortItOutGame({super.key});

  @override
  ConsumerState<SortItOutGame> createState() => _SortItOutGameState();
}

class _SortItOutGameState extends ConsumerState<SortItOutGame>
    with SingleTickerProviderStateMixin {
  bool _isPlaying = false;
  bool _isGameOver = false;
  int _score = 0;
  int _streak = 0;
  int _bestStreak = 0;
  int _timeLeft = 60;
  int _coinsEarned = 0;
  int _correctCount = 0;
  int _totalCount = 0;

  SortItem? _currentItem;
  final List<SortItem> _allItems = [];
  late List<SortBin> _bins;
  int _itemIndex = 0;

  Timer? _gameTimer;
  Timer? _streakTimer;
  late AnimationController _wrongShakeController;
  late Animation<double> _wrongShakeAnimation;

  final _allFoodItems = const [
    SortItem(emoji: '🍎', name: 'Apple', category: FoodCategory.fruits),
    SortItem(emoji: '🍌', name: 'Banana', category: FoodCategory.fruits),
    SortItem(emoji: '🍊', name: 'Orange', category: FoodCategory.fruits),
    SortItem(emoji: '🍇', name: 'Grapes', category: FoodCategory.fruits),
    SortItem(emoji: '🍓', name: 'Strawberry', category: FoodCategory.fruits),
    SortItem(emoji: '🥝', name: 'Kiwi', category: FoodCategory.fruits),
    SortItem(emoji: '🍑', name: 'Peach', category: FoodCategory.fruits),
    SortItem(emoji: '🍉', name: 'Watermelon', category: FoodCategory.fruits),
    SortItem(emoji: '🥦', name: 'Broccoli', category: FoodCategory.vegetables),
    SortItem(emoji: '🥕', name: 'Carrot', category: FoodCategory.vegetables),
    SortItem(emoji: '🥬', name: 'Lettuce', category: FoodCategory.vegetables),
    SortItem(emoji: '🍅', name: 'Tomato', category: FoodCategory.vegetables),
    SortItem(emoji: '🥒', name: 'Cucumber', category: FoodCategory.vegetables),
    SortItem(emoji: '🌽', name: 'Corn', category: FoodCategory.vegetables),
    SortItem(emoji: '🥔', name: 'Potato', category: FoodCategory.vegetables),
    SortItem(emoji: '🥛', name: 'Milk', category: FoodCategory.dairy),
    SortItem(emoji: '🧀', name: 'Cheese', category: FoodCategory.dairy),
    SortItem(emoji: '🧈', name: 'Butter', category: FoodCategory.dairy),
    SortItem(emoji: '🍞', name: 'Bread', category: FoodCategory.grains),
    SortItem(emoji: '🥐', name: 'Croissant', category: FoodCategory.grains),
    SortItem(emoji: '🍪', name: 'Cookie', category: FoodCategory.snacks),
    SortItem(emoji: '🍩', name: 'Donut', category: FoodCategory.snacks),
    SortItem(emoji: '🍿', name: 'Popcorn', category: FoodCategory.snacks),
  ];

  @override
  void initState() {
    super.initState();
    _wrongShakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _wrongShakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 12.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 12.0, end: -12.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -12.0, end: 8.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 8.0, end: -6.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -6.0, end: 4.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 4.0, end: -2.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -2.0, end: 0.0), weight: 1),
    ]).animate(_wrongShakeController);

    _bins = [
      SortBin(category: FoodCategory.fruits, label: 'Fruits', emoji: '🍎'),
      SortBin(category: FoodCategory.vegetables, label: 'Veggies', emoji: '🥦'),
      SortBin(category: FoodCategory.dairy, label: 'Dairy', emoji: '🥛'),
      SortBin(category: FoodCategory.grains, label: 'Grains', emoji: '🍞'),
      SortBin(category: FoodCategory.snacks, label: 'Snacks', emoji: '🍪'),
    ];
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    _streakTimer?.cancel();
    _wrongShakeController.dispose();
    super.dispose();
  }

  void _startGame() {
    setState(() {
      _isPlaying = true;
      _isGameOver = false;
      _score = 0;
      _streak = 0;
      _bestStreak = 0;
      _timeLeft = 60;
      _coinsEarned = 0;
      _correctCount = 0;
      _totalCount = 0;
      _itemIndex = 0;
      _allItems.clear();
      _allItems.addAll(_allFoodItems);
      _allItems.shuffle();
      _currentItem = _allItems.first;
      _bins = _bins.map((b) => SortBin(
        category: b.category,
        label: b.label,
        emoji: b.emoji,
      )).toList();
    });

    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() => _timeLeft--);
      if (_timeLeft <= 0) _endGame();
    });
  }

  void _onDrop(FoodCategory category) {
    if (!_isPlaying || _currentItem == null) return;

    setState(() {
      if (_currentItem!.category == category) {
        _score += 10 + _streak * 2;
        _streak++;
        _correctCount++;
        if (_streak > _bestStreak) _bestStreak = _streak;
        _totalCount++;
        _bins = _bins.map((b) {
          if (b.category == category) {
            return SortBin(
              category: b.category,
              label: b.label,
              emoji: b.emoji,
              color: Colors.greenAccent,
              scale: 1.08,
            );
          }
          return b;
        }).toList();

        Future.delayed(const Duration(milliseconds: 250), () {
          if (mounted) {
            setState(() {
              _bins = _bins.map((b) => SortBin(
                category: b.category,
                label: b.label,
                emoji: b.emoji,
              )).toList();
              _nextItem();
            });
          }
        });
      } else {
        _streak = 0;
        _totalCount++;
        _wrongShakeController.forward(from: 0.0);

        final bin = _bins.firstWhere((b) => b.category == category);
        bin.color = Colors.redAccent;

        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            setState(() {
              bin.color = Colors.white24;
            });
          }
        });
      }
    });
  }

  void _nextItem() {
    _itemIndex++;
    if (_itemIndex >= _allItems.length) {
      _allItems.shuffle();
      _itemIndex = 0;
    }
    _currentItem = _allItems[_itemIndex];
  }

  void _endGame() {
    _isPlaying = false;
    _isGameOver = true;
    _gameTimer?.cancel();

    final coins = max(1, _score ~/ 20);
    _coinsEarned = coins;
    ref.read(kidsZoneProvider.notifier).addCoins(coins);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF2E1A47), Color(0xFF6B2FA0), Color(0xFF9B59B6)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Stack(
          children: [
            // Background sparkles
            ...List.generate(15, (i) {
              final random = Random(i * 7);
              return Positioned(
                left: random.nextDouble() * MediaQuery.of(context).size.width,
                top: random.nextDouble() * MediaQuery.of(context).size.height * 0.5,
                child: Opacity(
                  opacity: 0.15 + random.nextDouble() * 0.2,
                  child: Text('✦', style: TextStyle(fontSize: 8.sp + random.nextDouble() * 12.sp, color: Colors.white)),
                ),
              );
            }),

            // HUD
            if (_isPlaying || _isGameOver)
              Positioned(
                top: MediaQuery.of(context).padding.top + 12.h,
                left: 0,
                right: 0,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildHudChip(Icons.timer_outlined, '${_timeLeft}s', Colors.white70),
                      _buildHudChip(Icons.stars_rounded, '$_score', Colors.amberAccent),
                      _buildHudChip(Icons.whatshot, 'x$_streak', Colors.orangeAccent),
                    ],
                  ),
                ),
              ),

            // Main content
            if (_isPlaying && _currentItem != null)
              Column(
                children: [
                  SizedBox(height: MediaQuery.of(context).padding.top + 70.h),
                  // Progress indicator
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6.r),
                      child: LinearProgressIndicator(
                        value: _totalCount > 0 ? _correctCount / max(1, _totalCount) : 0,
                        backgroundColor: Colors.white12,
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.greenAccent),
                        minHeight: 6.h,
                      ),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    '$_correctCount / $_totalCount correct',
                    style: TextStyle(fontSize: 12.sp, color: Colors.white60, fontWeight: FontWeight.w500),
                  ),
                  SizedBox(height: 20.h),

                  // Current item card - large display
                  Expanded(
                    child: Center(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: AnimatedBuilder(
                          animation: _wrongShakeAnimation,
                          builder: (context, child) {
                            return Transform.translate(
                              offset: Offset(_wrongShakeAnimation.value, 0),
                              child: child,
                            );
                          },
                          child: Container(
                            key: ValueKey('${_currentItem!.emoji}-$_itemIndex'),
                            width: 160.w,
                            height: 160.w,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(28.r),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(_currentItem!.emoji, style: TextStyle(fontSize: 52.sp)),
                                SizedBox(height: 8.h),
                                Text(
                                  _currentItem!.name,
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w800,
                                    color: AppColor.textBlack,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 8.h),
                  Text(
                    'Drag me to the right bin!',
                    style: TextStyle(fontSize: 13.sp, color: Colors.white60, fontWeight: FontWeight.w500),
                  ),
                  SizedBox(height: 12.h),

                  // Bins row
                  Container(
                    height: 160.h,
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                    child: Row(
                      children: _bins.map((bin) {
                        return Expanded(
                          child: DragTarget<SortItem>(
                            onAcceptWithDetails: (_) => _onDrop(bin.category),
                            builder: (context, candidateData, rejectedData) {
                              final isHovering = candidateData.isNotEmpty;
                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                margin: EdgeInsets.symmetric(horizontal: 4.w),
                                decoration: BoxDecoration(
                                  color: isHovering
                                      ? bin.color == Colors.greenAccent
                                          ? Colors.greenAccent.withOpacity(0.4)
                                          : Colors.white.withOpacity(0.2)
                                      : bin.color.withOpacity(bin.color == Colors.white24 ? 0.15 : 0.3),
                                  borderRadius: BorderRadius.circular(20.r),
                                  border: Border.all(
                                    color: isHovering ? Colors.white54 : Colors.white12,
                                    width: isHovering ? 2 : 1,
                                  ),
                                ),
                                child: Transform.scale(
                                  scale: bin.scale,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(bin.emoji, style: TextStyle(fontSize: 26.sp)),
                                      SizedBox(height: 4.h),
                                      Text(
                                        bin.label,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 10.sp,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  SizedBox(height: 24.h),
                ],
              ),

            // Draggable item overlay
            if (_isPlaying && _currentItem != null)
              Positioned.fill(
                child: LongPressDraggable<SortItem>(
                  data: _currentItem,
                  feedback: Material(
                    color: Colors.transparent,
                    child: Container(
                      width: 100.w,
                      height: 100.w,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 15,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(_currentItem!.emoji, style: TextStyle(fontSize: 36.sp)),
                          Text(_currentItem!.name, style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColor.textBlack,
                          )),
                        ],
                      ),
                    ),
                  ),
                  childWhenDragging: Container(
                    width: 160.w,
                    height: 160.w,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(28.r),
                    ),
                    child: Center(
                      child: Text(_currentItem!.emoji, style: TextStyle(fontSize: 40.sp)),
                    ),
                  ),
                  onDragStarted: () {
                    HapticFeedback.mediumImpact();
                  },
                  child: const SizedBox.shrink(),
                ),
              ),

            // Welcome screen
            if (!_isPlaying && !_isGameOver)
              Center(
                child: SingleChildScrollView(
                  child: Container(
                    margin: EdgeInsets.all(24.w),
                    padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 36.h),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF3D1E6D), Color(0xFF2E1A47)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(28.r),
                      border: Border.all(color: Colors.white12, width: 0.5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.4),
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('🗂️', style: TextStyle(fontSize: 64.sp)),
                        SizedBox(height: 12.h),
                        Text(
                          'Sort It Out!',
                          style: TextStyle(
                            fontSize: 28.sp,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 1.2,
                          ),
                        ),
                        SizedBox(height: 24.h),
                        _buildInstruction('🍎🥦🥛', 'Drag each food into the correct category!'),
                        SizedBox(height: 10.h),
                        _buildInstruction('⭐', 'Streak bonus: +2 extra points per streak!'),
                        SizedBox(height: 10.h),
                        _buildInstruction('🔥', 'Keep a streak going for big scores!'),
                        SizedBox(height: 10.h),
                        _buildInstruction('⏱️', 'Race the clock — 60 seconds!'),
                        SizedBox(height: 28.h),
                        Container(
                          width: double.infinity,
                          height: 52.h,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFE94560), Color(0xFF9B59B6)],
                            ),
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                          child: ElevatedButton(
                            onPressed: _startGame,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16.r),
                              ),
                            ),
                            child: Text(
                              'Start Sorting! 🚀',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // Game Over screen
            if (_isGameOver)
              Center(
                child: SingleChildScrollView(
                  child: Container(
                    margin: EdgeInsets.all(24.w),
                    padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 36.h),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('⏰', style: TextStyle(fontSize: 48.sp)),
                        SizedBox(height: 12.h),
                        Text(
                          'Time\'s Up!',
                          style: TextStyle(
                            fontSize: 24.sp,
                            fontWeight: FontWeight.w900,
                            color: Colors.purple.shade700,
                          ),
                        ),
                        SizedBox(height: 20.h),
                        Text(
                          '$_score Points',
                          style: TextStyle(
                            fontSize: 36.sp,
                            fontWeight: FontWeight.w900,
                            color: AppColor.textBlack,
                          ),
                        ),
                        SizedBox(height: 6.h),
                        Text(
                          '$_correctCount / $_totalCount correct  •  Best Streak: $_bestStreak',
                          style: TextStyle(fontSize: 13.sp, color: AppColor.textMuted),
                        ),
                        SizedBox(height: 20.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.monetization_on, color: Colors.orange, size: 24.sp),
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
                          'Coins added to your parent balance!',
                          style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade500),
                        ),
                        SizedBox(height: 28.h),
                        Container(
                          width: double.infinity,
                          height: 52.h,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFE94560), Color(0xFF9B59B6)],
                            ),
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                          child: ElevatedButton(
                            onPressed: _startGame,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16.r),
                              ),
                            ),
                            child: Text(
                              'Play Again 🔄',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // Back button
            SafeArea(
              child: Padding(
                padding: EdgeInsets.only(top: 4.h),
                child: IconButton(
                  icon: Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 22),
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHudChip(IconData icon, String text, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.white12, width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16.sp),
          SizedBox(width: 4.w),
          Text(
            text,
            style: TextStyle(color: color, fontSize: 14.sp, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildInstruction(String icon, String text) {
    return Row(
      children: [
        Text(icon, style: TextStyle(fontSize: 22.sp)),
        SizedBox(width: 12.w),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 13.sp, color: Colors.white70, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }
}
