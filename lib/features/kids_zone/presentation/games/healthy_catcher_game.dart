import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lets_vhandar/core/constants/color_constant.dart';
import 'package:lets_vhandar/features/kids_zone/providers/kids_zone_provider.dart';
import 'package:lets_vhandar/widgets/custom_button.dart';

class FallingItem {
  double x;
  double y;
  final String label;
  final bool isHealthy;
  final Color color;

  FallingItem({
    required this.x,
    required this.y,
    required this.label,
    required this.isHealthy,
    required this.color,
  });
}

class HealthyCatcherGame extends ConsumerStatefulWidget {
  const HealthyCatcherGame({super.key});

  @override
  ConsumerState<HealthyCatcherGame> createState() => _HealthyCatcherGameState();
}

class _HealthyCatcherGameState extends ConsumerState<HealthyCatcherGame> {
  // Game states
  bool _isPlaying = false;
  bool _isGameOver = false;
  int _score = 0;
  int _lives = 3;
  int _coinsEarned = 0;

  // Screen/Canvas dimensions
  double _canvasWidth = 300.0;
  double _canvasHeight = 500.0;

  // Player basket
  double _basketX = 120.0;
  final double _basketWidth = 130.0;
  final double _basketHeight = 50.0;

  // Fall lists
  final List<FallingItem> _items = [];
  Timer? _gameTimer;
  Timer? _spawnTimer;
  final Random _random = Random();

  final List<Map<String, dynamic>> _healthyFood = [
    {'label': '🍎', 'isHealthy': true, 'color': Colors.red},
    {'label': ' Broccoli', 'isHealthy': true, 'color': Colors.green}, // Wait, let's keep it simple emoji
    {'label': '🥦', 'isHealthy': true, 'color': Colors.green},
    {'label': '🥛', 'isHealthy': true, 'color': Colors.blue},
    {'label': '🍌', 'isHealthy': true, 'color': Colors.yellow},
    {'label': '🥕', 'isHealthy': true, 'color': Colors.orange},
    {'label': '🍞', 'isHealthy': true, 'color': Colors.brown},
  ];

  final List<Map<String, dynamic>> _unhealthyFood = [
    {'label': '🥤', 'isHealthy': false, 'color': Colors.redAccent},
    {'label': '🍬', 'isHealthy': false, 'color': Colors.pinkAccent},
    {'label': '🍩', 'isHealthy': false, 'color': Colors.deepOrangeAccent},
    {'label': '🍟', 'isHealthy': false, 'color': Colors.yellowAccent},
    {'label': '🍭', 'isHealthy': false, 'color': Colors.purpleAccent},
  ];

  @override
  void dispose() {
    _stopGame();
    super.dispose();
  }

  void _startGame() {
    setState(() {
      _isPlaying = true;
      _isGameOver = false;
      _score = 0;
      _lives = 3;
      _coinsEarned = 0;
      _items.clear();
      _basketX = _canvasWidth / 2 - _basketWidth / 2;
    });

    // Main tick loop
    _gameTimer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      _tick();
    });

    // Spawning timer
    _spawnTimer = Timer.periodic(const Duration(milliseconds: 1000), (timer) {
      _spawnItem();
    });
  }

  void _stopGame() {
    _gameTimer?.cancel();
    _spawnTimer?.cancel();
  }

  void _spawnItem() {
    if (!_isPlaying) return;
    final isHealthy = _random.nextDouble() > 0.35; // 65% healthy, 35% unhealthy
    final pool = isHealthy ? _healthyFood : _unhealthyFood;
    final template = pool[_random.nextInt(pool.length)];

    final newItem = FallingItem(
      x: _random.nextDouble() * (_canvasWidth - 55.0),
      y: 0.0,
      label: template['label'],
      isHealthy: template['isHealthy'],
      color: template['color'],
    );

    setState(() {
      _items.add(newItem);
    });
  }

  void _tick() {
    if (!_isPlaying) return;

    setState(() {
      final basketTop = _canvasHeight - 25.0 - _basketHeight;
      final basketBottom = _canvasHeight - 25.0;

      for (var i = 0; i < _items.length; i++) {
        final item = _items[i];
        // Move item down
        item.y += 4.5 + (_score ~/ 120); // Speed scales up slightly with score

        // Check basket collision
        if (item.y + 45.0 >= basketTop && item.y <= basketBottom) {
          final itemCenterX = item.x + 22.5;
          if (itemCenterX >= _basketX &&
              itemCenterX <= _basketX + _basketWidth) {
            // Caught!
            _items.removeAt(i);
            i--;

            if (item.isHealthy) {
              _score += 15;
            } else {
              _score = max(0, _score - 10);
              _lives--;
              if (_lives <= 0) {
                _triggerGameOver();
              }
            }
            continue;
          }
        }

        // Check ground boundary
        if (item.y > basketBottom) {
          _items.removeAt(i);
          i--;
          if (item.isHealthy) {
            // Missed a healthy item
            _lives--;
            if (_lives <= 0) {
              _triggerGameOver();
            }
          }
        }
      }
    });
  }

  void _triggerGameOver() {
    _stopGame();
    setState(() {
      _isPlaying = false;
      _isGameOver = true;
      _coinsEarned = _score ~/ 8; // Conversion rate: score / 8
    });

    if (_coinsEarned > 0) {
      ref.read(kidsZoneProvider.notifier).addCoins(_coinsEarned);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F5E9),
      appBar: AppBar(
        title: const Text('Healthy Food Catcher 🍎'),
        centerTitle: true,
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          _canvasWidth = constraints.maxWidth;
          _canvasHeight = constraints.maxHeight;

          return Stack(
            children: [
              // --- Sky/Meadow Background Gradient ---
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.lightBlue.shade100, const Color(0xFFE8F5E9)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ),

              // --- Grass at the bottom ---
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                height: 80.h,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.green.shade600, Colors.green.shade800],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24.r),
                      topRight: Radius.circular(24.r),
                    ),
                  ),
                ),
              ),

              // --- Score & Lives Bar ---
              Positioned(
                top: 16.h,
                left: 16.w,
                right: 16.w,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(color: Colors.green.shade300, width: 2.w),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 8,
                          )
                        ],
                      ),
                      child: Text(
                        'Score: $_score',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade800,
                        ),
                      ),
                    ),
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(color: Colors.red.shade200, width: 2.w),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 8,
                          )
                        ],
                      ),
                      child: Row(
                        children: List.generate(3, (index) {
                          return Icon(
                            Icons.favorite,
                            color: index < _lives ? Colors.red : Colors.grey.shade400,
                            size: 20.sp,
                          );
                        }),
                      ),
                    ),
                  ],
                ),
              ),

              // --- Play Area (Active game elements) ---
              if (_isPlaying) ...[
                // Falling Items wrapped in premium bubble containers
                ..._items.map((item) {
                  return Positioned(
                    left: item.x,
                    top: item.y,
                    child: Container(
                      width: 45.w,
                      height: 45.h,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: item.color.withValues(alpha: 0.3),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          )
                        ],
                        border: Border.all(
                          color: item.color.withValues(alpha: 0.6),
                          width: 2.5,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          item.label,
                          style: TextStyle(fontSize: 24.sp),
                        ),
                      ),
                    ),
                  );
                }),

                // Basket (Moveable using drag or tap gestures)
                Positioned(
                  left: _basketX,
                  bottom: 25.0,
                  child: Container(
                    width: _basketWidth,
                    height: _basketHeight,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF8D6E63), Color(0xFF5D4037)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(color: const Color(0xFFD7CCC8), width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('🧺', style: TextStyle(fontSize: 22.sp)),
                          SizedBox(width: 6.w),
                          Text(
                            'My Basket',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                              shadows: const [
                                Shadow(
                                  color: Colors.black45,
                                  offset: Offset(1, 1),
                                  blurRadius: 2,
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Top layer OPAQUE GestureDetector for maximum horizontal drag smoothness
                Positioned.fill(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onHorizontalDragUpdate: (details) {
                      setState(() {
                        _basketX = max(
                          0.0,
                          min(
                            _canvasWidth - _basketWidth,
                            _basketX + details.delta.dx,
                          ),
                        );
                      });
                    },
                  ),
                ),
              ],

              // --- Game Over Screen ---
              if (_isGameOver)
                Center(
                  child: Container(
                    margin: EdgeInsets.all(24.w),
                    padding:
                        EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 20,
                        )
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Game Over! 🏁',
                          style: TextStyle(
                            fontSize: 24.sp,
                            fontWeight: FontWeight.w900,
                            color: Colors.red,
                          ),
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          'You caught healthy food & scored:',
                          style: TextStyle(
                              fontSize: 14.sp, color: AppColor.textMuted),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          '$_score Points',
                          style: TextStyle(
                            fontSize: 28.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade700,
                          ),
                        ),
                        SizedBox(height: 16.h),
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
                            'Earned coins added to your parent balance!',
                            style: TextStyle(
                                fontSize: 11.sp, color: Colors.grey.shade500),
                          ),
                        ] else
                          Text(
                            'Catch more healthy fruits to earn coins!',
                            style: TextStyle(
                                fontSize: 12.sp, color: Colors.grey.shade500),
                          ),
                        SizedBox(height: 24.h),
                        CustomElevatedButton(
                          onPressed: _startGame,
                          backgroundColor: Colors.green.shade700,
                          foregroundColor: Colors.white,
                          text: 'Play Again 🔄',
                        ),
                      ],
                    ),
                  ),
                ),

              // --- Welcome Screen ---
              if (!_isPlaying && !_isGameOver)
                Center(
                  child: Container(
                    margin: EdgeInsets.all(24.w),
                    padding:
                        EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 20,
                        )
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'How to Play? 🎮',
                          style: TextStyle(
                            fontSize: 22.sp,
                            fontWeight: FontWeight.w900,
                            color: Colors.green.shade700,
                          ),
                        ),
                        SizedBox(height: 16.h),
                        _buildInstructionRow('🍎 🥦 🥛', 'Catch healthy items for +15 points.'),
                        SizedBox(height: 12.h),
                        _buildInstructionRow('🥤 🍩 🍭', 'Avoid unhealthy items (-10 points, lose 1 life).'),
                        SizedBox(height: 12.h),
                        _buildInstructionRow('👈 Swipe 👉', 'Drag your finger anywhere to slide the basket left & right.'),
                        SizedBox(height: 24.h),
                        CustomElevatedButton(
                          onPressed: _startGame,
                          backgroundColor: Colors.green.shade700,
                          foregroundColor: Colors.white,
                          text: 'Start Catching! 🚀',
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildInstructionRow(String icon, String text) {
    return Row(
      children: [
        Text(icon, style: TextStyle(fontSize: 24.sp)),
        SizedBox(width: 16.w),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13.sp,
              color: AppColor.textBlack87,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
