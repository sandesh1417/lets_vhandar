import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:lets_vhandar/features/kids_zone/providers/kids_zone_provider.dart';
import 'package:lets_vhandar/widgets/custom_button.dart';

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

  SortBin copyWith({Color? color, double? scale}) {
    return SortBin(
      category: category,
      label: label,
      emoji: emoji,
      color: color ?? this.color,
      scale: scale ?? this.scale,
    );
  }
}

class FloatText {
  double x;
  double y;
  final String text;
  final Color color;
  double opacity;
  double offset;

  FloatText({
    required this.x,
    required this.y,
    required this.text,
    required this.color,
    this.opacity = 1.0,
    this.offset = 0,
  });
}

class SortItOutGame extends ConsumerStatefulWidget {
  const SortItOutGame({super.key});

  @override
  ConsumerState<SortItOutGame> createState() => _SortItOutGameState();
}

class _SortItOutGameState extends ConsumerState<SortItOutGame>
    with TickerProviderStateMixin {
  bool _isPlaying = false;
  bool _isGameOver = false;
  int _score = 0;
  int _streak = 0;
  int _bestStreak = 0;
  int _timeLeft = 60;
  int _coinsEarned = 0;
  int _correctCount = 0;
  int _totalCount = 0;
  int _level = 1;
  bool _inBonus = false;
  int _bonusTimeLeft = 0;

  SortItem? _currentItem;
  final List<SortItem> _allItems = [];
  late List<SortBin> _bins;
  int _itemIndex = 0;

  Timer? _gameTimer;
  Timer? _skipTimer;
  late AnimationController _wrongShakeController;
  late Animation<double> _wrongShakeAnimation;
  late AnimationController _cardEnterController;
  late Animation<Offset> _cardSlideAnimation;
  late Animation<double> _cardFadeAnimation;
  final List<FloatText> _floatTexts = [];
  Timer? _floatTimer;

  static const _allFoodItems = [
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
    SortItem(emoji: '😋', name: 'Yogurt', category: FoodCategory.dairy),
    SortItem(emoji: '🍞', name: 'Bread', category: FoodCategory.grains),
    SortItem(emoji: '🥐', name: 'Croissant', category: FoodCategory.grains),
    SortItem(emoji: '🍚', name: 'Rice', category: FoodCategory.grains),
    SortItem(emoji: '🍝', name: 'Pasta', category: FoodCategory.grains),
    SortItem(emoji: '🍪', name: 'Cookie', category: FoodCategory.snacks),
    SortItem(emoji: '🍩', name: 'Donut', category: FoodCategory.snacks),
    SortItem(emoji: '🍿', name: 'Popcorn', category: FoodCategory.snacks),
    SortItem(emoji: '🍫', name: 'Chocolate', category: FoodCategory.snacks),
  ];

  @override
  void initState() {
    super.initState();
    _wrongShakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _wrongShakeAnimation = _wrongShakeController.drive(
      TweenSequence<double>([
        TweenSequenceItem(tween: Tween(begin: 0.0, end: 14.0), weight: 1),
        TweenSequenceItem(tween: Tween(begin: 14.0, end: -12.0), weight: 1),
        TweenSequenceItem(tween: Tween(begin: -12.0, end: 8.0), weight: 1),
        TweenSequenceItem(tween: Tween(begin: 8.0, end: -6.0), weight: 1),
        TweenSequenceItem(tween: Tween(begin: -6.0, end: 0.0), weight: 1),
      ]),
    );

    _cardEnterController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _cardSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _cardEnterController, curve: Curves.easeOut));
    _cardFadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(
        CurvedAnimation(parent: _cardEnterController, curve: Curves.easeOut));

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
    _skipTimer?.cancel();
    _floatTimer?.cancel();
    _wrongShakeController.dispose();
    _cardEnterController.dispose();
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
      _level = 1;
      _inBonus = false;
      _bonusTimeLeft = 0;
      _itemIndex = 0;
      _allItems.clear();
      _allItems.addAll(_allFoodItems);
      _allItems.shuffle();
      _currentItem = _allItems.first;
      _floatTexts.clear();
      _bins = _bins.map((b) => b.copyWith()).toList();
    });
    _cardEnterController.forward(from: 0);

    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        _timeLeft--;
        if (_inBonus) {
          _bonusTimeLeft--;
          if (_bonusTimeLeft <= 0) _inBonus = false;
        }
      });
      if (_timeLeft <= 0) _endGame();
    });

    _skipTimer = Timer.periodic(const Duration(seconds: 8), (_) {
      if (!_isPlaying || !mounted || _currentItem == null) return;
      setState(() {
        _totalCount++;
        _streak = 0;
      });
      _nextItem();
    });

    _floatTimer = Timer.periodic(const Duration(milliseconds: 33), (_) {
      if (!mounted) return;
      setState(() {
        for (final ft in _floatTexts) {
          ft.offset -= 1.5;
          ft.opacity -= 0.025;
        }
        _floatTexts.removeWhere((ft) => ft.opacity <= 0);
      });
    });
  }

  void _onDrop(FoodCategory category) {
    if (!_isPlaying || _currentItem == null) return;

    final isCorrect = _currentItem!.category == category;
    final mq = MediaQuery.of(context);
    final centerX = mq.size.width / 2;
    final centerY = mq.size.height / 2;

    setState(() {
      if (isCorrect) {
        final bonus = _inBonus ? 2 : 1;
        final points = (10 + _streak * 2) * bonus;
        _score += points;
        _streak++;
        _correctCount++;
        if (_streak > _bestStreak) _bestStreak = _streak;
        _totalCount++;

        _timeLeft = min(_timeLeft + 3, 99);

        _floatTexts.add(FloatText(
          x: centerX - 30,
          y: centerY - 40,
          text: '+$points',
          color: Colors.greenAccent,
        ));

        _bins = _bins.map((b) {
          return b.category == category
              ? b.copyWith(color: Colors.greenAccent, scale: 1.1)
              : b;
        }).toList();

        // Bonus round every 10 correct
        if (_correctCount % 10 == 0) {
          _inBonus = true;
          _bonusTimeLeft = 10;
        }

        // Level up every 8 correct
        final newLevel = 1 + (_correctCount ~/ 8);
        if (newLevel != _level) {
          _level = newLevel;
        }

        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) {
            setState(() {
              _bins = _bins.map((b) => b.copyWith()).toList();
            });
            _nextItem();
          }
        });
      } else {
        _streak = 0;
        _totalCount++;
        _score = max(0, _score - 5);
        _wrongShakeController.forward(from: 0);

        _floatTexts.add(FloatText(
          x: centerX - 30,
          y: centerY - 40,
          text: '-5',
          color: Colors.redAccent,
        ));

        _bins = _bins.map((b) {
          return b.category == category
              ? b.copyWith(color: Colors.redAccent, scale: 0.95)
              : b;
        }).toList();

        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            setState(() {
              _bins = _bins.map((b) => b.copyWith()).toList();
            });
          }
        });

        HapticFeedback.heavyImpact();
      }
    });
  }

  void _nextItem() {
    _itemIndex++;
    if (_itemIndex >= _allItems.length) {
      _allItems.shuffle();
      _itemIndex = 0;
    }
    setState(() {
      _currentItem = _allItems[_itemIndex];
    });
    _cardEnterController.forward(from: 0);
  }

  void _endGame() {
    if (!_isPlaying) return;
    _isPlaying = false;
    _isGameOver = true;
    _gameTimer?.cancel();
    _skipTimer?.cancel();
    _floatTimer?.cancel();

    final coins = max(1, _score ~/ 20);
    _coinsEarned = coins;
    ref.read(kidsZoneProvider.notifier).addCoins(coins);
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final sw = mq.size.width;
    final topPad = mq.padding.top;

    return Scaffold(
      backgroundColor: const Color(0xFF2E1A47),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF2E1A47),
                  Color(0xFF6B2FA0),
                  Color(0xFF9B59B6)
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // Sparkles
          ...List.generate(15, (i) {
            final r = Random(i * 7);
            return Positioned(
              left: r.nextDouble() * sw,
              top: r.nextDouble() * mq.size.height * 0.5,
              child: Opacity(
                opacity: 0.15 + r.nextDouble() * 0.2,
                child: Text('✦',
                    style: TextStyle(
                        fontSize: 8 + r.nextDouble() * 12,
                        color: Colors.white)),
              ),
            );
          }),

          // HUD
          if (_isPlaying || _isGameOver)
            Positioned(
              top: topPad + 12,
              left: 12,
              right: 12,
              child: Row(
                children: [
                  _buildHudChip(Icons.timer_outlined, '${_timeLeft}s',
                      _timeLeft <= 10 ? Colors.redAccent : Colors.white70),
                  const SizedBox(width: 6),
                  _buildHudChip(
                      Icons.stars_rounded, '$_score', Colors.amberAccent),
                  const SizedBox(width: 6),
                  _buildHudChip(
                      _inBonus ? Icons.bolt : Icons.whatshot,
                      _inBonus ? 'x2' : 'x$_streak',
                      _inBonus ? Colors.yellowAccent : Colors.orangeAccent),
                  const Spacer(),
                  _buildLevelBadge(),
                ],
              ),
            ),

          // Content
          if (_isPlaying && _currentItem != null)
            Column(
              children: [
                SizedBox(height: topPad + 70),
                // Accuracy bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: _totalCount > 0
                          ? _correctCount / max(1, _totalCount)
                          : 0,
                      backgroundColor: Colors.white10,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _inBonus ? Colors.yellowAccent : Colors.greenAccent,
                      ),
                      minHeight: 5,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _inBonus
                      ? '⚡ BONUS ROUND — 2x points! ($_bonusTimeLeft s)'
                      : '$_correctCount / $_totalCount correct  •  Lv.$_level',
                  style: TextStyle(
                    fontSize: 12,
                    color: _inBonus ? Colors.yellowAccent : Colors.white60,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 16),

                // Item card — draggable
                Expanded(
                  child: Center(
                    child: LongPressDraggable<SortItem>(
                      data: _currentItem,
                      dragAnchorStrategy: pointerDragAnchorStrategy,
                      feedback: Material(
                        color: Colors.transparent,
                        child: Container(
                          width: 110,
                          height: 130,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: const [
                              BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 16,
                                  offset: Offset(0, 8)),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(_currentItem!.emoji,
                                  style: const TextStyle(fontSize: 42)),
                              const SizedBox(height: 4),
                              Text(
                                _currentItem!.name,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      childWhenDragging: Opacity(
                        opacity: 0.25,
                        child: _buildItemCard(),
                      ),
                      onDragStarted: () => HapticFeedback.mediumImpact(),
                      onDraggableCanceled: (_, __) =>
                          HapticFeedback.selectionClick(),
                      child: _buildItemCard(),
                    ),
                  ),
                ),

                const SizedBox(height: 8),
                Text(
                  'Long-press & drag to the right bin!',
                  style: TextStyle(
                      fontSize: 12, color: Colors.white.withValues(alpha: 0.5)),
                ),
                const SizedBox(height: 12),

                // Bins
                SizedBox(
                  height: 150,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      children: _bins.map((bin) {
                        return Expanded(
                          child: DragTarget<SortItem>(
                            onAcceptWithDetails: (_) => _onDrop(bin.category),
                            builder: (context, candidates, rejected) {
                              final isHovering = candidates.isNotEmpty;
                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 3),
                                decoration: BoxDecoration(
                                  color: isHovering
                                      ? bin.color == Colors.greenAccent
                                          ? Colors.greenAccent.withValues(alpha: 0.35)
                                          : bin.color == Colors.redAccent
                                              ? Colors.redAccent
                                                  .withValues(alpha: 0.35)
                                              : Colors.white.withValues(alpha: 0.2)
                                      : bin.color.withValues(alpha: 
                                          bin.color == Colors.white24
                                              ? 0.12
                                              : 0.3),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isHovering
                                        ? Colors.white
                                        : bin.color.withValues(alpha: 0.5),
                                    width: isHovering ? 2 : 1,
                                  ),
                                ),
                                child: Transform.scale(
                                  scale: bin.scale,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(bin.emoji,
                                          style: const TextStyle(fontSize: 26)),
                                      const SizedBox(height: 2),
                                      Text(
                                        bin.label,
                                        style: const TextStyle(
                                          fontSize: 10,
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
                ),
                const SizedBox(height: 24),
              ],
            ),

          // Floating score texts
          ..._floatTexts.map((ft) => Positioned(
                left: ft.x,
                top: ft.y + ft.offset,
                child: Opacity(
                  opacity: ft.opacity.clamp(0, 1),
                  child: Text(
                    ft.text,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: ft.color,
                      shadows: const [
                        Shadow(color: Colors.black45, blurRadius: 4)
                      ],
                    ),
                  ),
                ),
              )),

          // Welcome
          if (!_isPlaying && !_isGameOver)
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Container(
                  margin: const EdgeInsets.all(24),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 28, vertical: 36),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF3D1E6D), Color(0xFF2E1A47)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: Colors.white12, width: 0.5),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withValues(alpha: 0.4),
                          blurRadius: 30,
                          offset: const Offset(0, 10)),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('🗂️', style: TextStyle(fontSize: 64)),
                      const SizedBox(height: 8),
                      const Text('Sort It Out!',
                          style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 1.2)),
                      const SizedBox(height: 4),
                      const Text('Drag food into the correct bin!',
                          style:
                              TextStyle(fontSize: 13, color: Colors.white54)),
                      const SizedBox(height: 24),
                      _buildInstruction(
                          '👆', 'Long-press the food card & drag it'),
                      const SizedBox(height: 8),
                      _buildInstruction(
                          '⭐', '+3s time bonus for each correct answer!'),
                      const SizedBox(height: 8),
                      _buildInstruction(
                          '🔥', 'Build streaks for higher points!'),
                      const SizedBox(height: 8),
                      _buildInstruction(
                          '⚡', 'Every 10 correct = 2x Bonus Round!'),
                      const SizedBox(height: 8),
                      _buildInstruction(
                          '⏱️', 'Items auto-skip after 8 seconds!'),
                      const SizedBox(height: 28),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: CustomElevatedButton(
                          onPressed: _startGame,
                          backgroundColor: const Color(0xFFE94560),
                          foregroundColor: Colors.white,
                          text: 'Start Sorting! 🚀',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Game Over
          if (_isGameOver)
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Container(
                  margin: const EdgeInsets.all(24),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 28, vertical: 36),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 30,
                          offset: const Offset(0, 10)),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('⏰', style: TextStyle(fontSize: 48)),
                      const SizedBox(height: 8),
                      const Text('Time\'s Up!',
                          style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              color: Colors.black87)),
                      const SizedBox(height: 16),
                      Text('$_score pts',
                          style: const TextStyle(
                              fontSize: 44,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF6B2FA0))),
                      const SizedBox(height: 6),
                      Text(
                        'Lv.$_level reached  •  $_correctCount / $_totalCount correct  •  Best streak: $_bestStreak',
                        style:
                            const TextStyle(fontSize: 13, color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.monetization_on,
                                color: Colors.orange, size: 24),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                '+$_coinsEarned Kids Coins!',
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange.shade800),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text('Coins added to your parent balance!',
                          style: TextStyle(fontSize: 11, color: Colors.grey)),
                      const SizedBox(height: 28),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: CustomElevatedButton(
                          onPressed: _startGame,
                          backgroundColor: const Color(0xFFE94560),
                          foregroundColor: Colors.white,
                          text: 'Play Again 🔄',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Back
          SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.only(top: 4, left: 4),
                child: IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                        color: Colors.black26, shape: BoxShape.circle),
                    child: const Icon(Icons.arrow_back_rounded,
                        color: Colors.white, size: 22),
                  ),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    Navigator.pop(context);
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemCard() {
    return SlideTransition(
      position: _cardSlideAnimation,
      child: FadeTransition(
        opacity: _cardFadeAnimation,
        child: Container(
          width: 150,
          height: 170,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedBuilder(
                animation: _wrongShakeController,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(_wrongShakeAnimation.value, 0),
                    child: child,
                  );
                },
                child: Text(_currentItem!.emoji,
                    style: const TextStyle(fontSize: 56)),
              ),
              const SizedBox(height: 8),
              Text(
                _currentItem!.name,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Colors.black87),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLevelBadge() {
    Color bg;
    if (_level >= 6) {
      bg = Colors.redAccent;
    } else if (_level >= 4) {
      bg = Colors.orangeAccent;
    } else {
      bg = Colors.cyanAccent;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: bg.withValues(alpha: 0.6), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.auto_awesome, color: bg, size: 14),
          const SizedBox(width: 4),
          Text('Lv.$_level',
              style: TextStyle(
                  color: bg, fontSize: 11, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildHudChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white12, width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 3),
          Text(text,
              style: TextStyle(
                  color: color, fontSize: 13, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildInstruction(String icon, String text) {
    return Row(
      children: [
        Text(icon, style: const TextStyle(fontSize: 22)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(text,
              style: const TextStyle(
                  fontSize: 13,
                  color: Colors.white70,
                  fontWeight: FontWeight.w500)),
        ),
      ],
    );
  }
}
