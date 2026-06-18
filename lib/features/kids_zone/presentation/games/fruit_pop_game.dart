import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show HapticFeedback;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lets_vhandar/features/kids_zone/providers/kids_zone_provider.dart';
import 'package:lets_vhandar/widgets/custom_button.dart';

class FloatingFruit {
  double x;
  double y;
  final String emoji;
  final double speed;
  final double size;
  final bool isGolden;
  final bool isRotten;
  bool isPopped;

  FloatingFruit({
    required this.x,
    required this.y,
    required this.emoji,
    required this.speed,
    required this.size,
    this.isGolden = false,
    this.isRotten = false,
    this.isPopped = false,
  });
}

class PopParticle {
  double x;
  double y;
  double opacity;
  double scale;
  final String emoji;

  PopParticle({
    required this.x,
    required this.y,
    required this.emoji,
    this.opacity = 1.0,
    this.scale = 1.0,
  });
}

class FruitPopGame extends ConsumerStatefulWidget {
  const FruitPopGame({super.key});

  @override
  ConsumerState<FruitPopGame> createState() => _FruitPopGameState();
}

class _FruitPopGameState extends ConsumerState<FruitPopGame>
    with SingleTickerProviderStateMixin {
  bool _isPlaying = false;
  bool _isGameOver = false;
  int _score = 0;
  int _combo = 0;
  int _bestCombo = 0;
  int _lives = 5;
  int _coinsEarned = 0;
  int _timeLeft = 45;
  int _totalPopped = 0;
  // ignore: unused_field
  int _missedThisLevel = 0;
  int _poppedThisLevel = 0;
  int _level = 1;

  final List<FloatingFruit> _fruits = [];
  final List<PopParticle> _particles = [];
  Timer? _gameTimer;
  Timer? _updateTimer;
  double _spawnAccumulator = 0;
  double _spawnInterval = 1.2;
  // ignore: unused_field
  int _prevSecond = 0;
  final Random _random = Random();

  final List<String> _fruitEmojis = [
    '🍎', '🍊', '🍋', '🍇', '🍓',
    '🫐', '🥝', '🍑', '🍒', '🍉',
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    _updateTimer?.cancel();
    super.dispose();
  }

  void _startGame() {
    setState(() {
      _isPlaying = true;
      _isGameOver = false;
      _score = 0;
      _combo = 0;
      _bestCombo = 0;
      _lives = 5;
      _coinsEarned = 0;
      _timeLeft = 45;
      _totalPopped = 0;
      _missedThisLevel = 0;
      _poppedThisLevel = 0;
      _level = 1;
      _spawnAccumulator = 0;
      _spawnInterval = 1.2;
      _prevSecond = 0;
      _fruits.clear();
      _particles.clear();
    });

    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() => _timeLeft--);
      if (_timeLeft <= 0 || _lives <= 0) _endGame();
    });

    _updateTimer = Timer.periodic(const Duration(milliseconds: 33), (_) {
      if (!_isPlaying || !mounted) return;
      setState(() {
        final elapsed = 45 - _timeLeft;
        final difficulty = (elapsed / 45).clamp(0.0, 1.0);

        // Progressive spawn interval: 1.2s → 0.3s
        _spawnInterval = 1.2 - difficulty * 0.9;
        _spawnAccumulator += 0.033;
        while (_spawnAccumulator >= _spawnInterval) {
          _spawnAccumulator -= _spawnInterval;
          _spawnFruit(difficulty);
        }

        // Move fruits upward
        for (final fruit in _fruits) {
          fruit.y -= fruit.speed;
        }

        // Escaped fruits cost lives
        final escaped = _fruits.where(
          (f) => f.y < -80 && !f.isPopped && !f.isRotten,
        ).length;
        if (escaped > 0) {
          _lives = max(0, _lives - escaped);
          _missedThisLevel += escaped;
        }
        _fruits.removeWhere((f) => f.y < -80 || f.isPopped);

        // Particles fade
        for (final p in _particles) {
          p.opacity -= 0.04;
          p.scale = max(0, p.scale - 0.02);
        }
        _particles.removeWhere((p) => p.opacity <= 0);

        // Level progression — every 10 popped fruits
        final newLevel = 1 + (_totalPopped ~/ 10);
        if (newLevel != _level) {
          _level = newLevel;
          _missedThisLevel = 0;
          _poppedThisLevel = 0;
        }

        if (_lives <= 0 && _isPlaying) {
          Future.microtask(_endGame);
        }
      });
    });
  }

  void _spawnFruit(double difficulty) {
    if (!mounted) return;
    final size = MediaQuery.of(context).size;
    final isGolden = _random.nextDouble() < 0.12;
    final isRotten = !isGolden && _random.nextDouble() < 0.18;

    final fruitSize = 36.0 + _random.nextDouble() * 20.0;
    final isFast = difficulty > 0.3 && _random.nextDouble() < difficulty * 0.25;

    String emoji;
    if (isGolden) {
      emoji = '⭐';
    } else if (isRotten) {
      emoji = '🤢';
    } else if (isFast) {
      emoji = '🔥';
    } else {
      emoji = _fruitEmojis[_random.nextInt(_fruitEmojis.length)];
    }

    final baseSpeed = 2.5 + difficulty * 3.0;
    final speed = isFast
        ? (baseSpeed + 1.0) + _random.nextDouble() * 2.0
        : baseSpeed + _random.nextDouble() * 1.5;

    setState(() {
      _fruits.add(FloatingFruit(
        x: _random.nextDouble() * (size.width - 60) + 20,
        y: size.height + 20,
        emoji: emoji,
        speed: speed,
        size: isFast ? fruitSize * 0.75 : fruitSize,
        isGolden: isGolden,
        isRotten: isRotten,
      ));
    });
  }

  void _onTapFruit(FloatingFruit fruit) {
    if (!_isPlaying || fruit.isPopped) return;
    setState(() {
      fruit.isPopped = true;
      if (fruit.isRotten) {
        _combo = 0;
        _score = max(0, _score - 10);
        _particles.add(PopParticle(x: fruit.x, y: fruit.y, emoji: '💨'));
      } else {
        final points = fruit.isGolden ? 50 : (10 + _combo * 2);
        _score += points;
        _combo++;
        _totalPopped++;
        _poppedThisLevel++;
        if (_combo > _bestCombo) _bestCombo = _combo;
        _particles.add(PopParticle(
          x: fruit.x,
          y: fruit.y,
          emoji: fruit.isGolden ? '✨' : '💥',
        ));
      }
    });
  }

  void _endGame() {
    if (!_isPlaying) return;
    _isPlaying = false;
    _isGameOver = true;
    _gameTimer?.cancel();
    _updateTimer?.cancel();

    final coins = max(1, _score ~/ 15);
    _coinsEarned = coins;
    ref.read(kidsZoneProvider.notifier).addCoins(coins);
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final screenWidth = mq.size.width;
    final screenHeight = mq.size.height;
    final topPadding = mq.padding.top;

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1A1A2E), Color(0xFF16213E), Color(0xFF0F3460)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // Background stars (no .w/.h, use plain doubles)
          ...List.generate(20, (i) {
            final starX = _random.nextDouble() * screenWidth;
            final starY = _random.nextDouble() * screenHeight * 0.6;
            final starSize = 6.0 + _random.nextDouble() * 8.0;
            return Positioned(
              left: starX,
              top: starY,
              child: Opacity(
                opacity: 0.3 + _random.nextDouble() * 0.4,
                child: Text('✦', style: TextStyle(fontSize: starSize, color: Colors.white)),
              ),
            );
          }),

          // Fruits
          ..._fruits.reversed.map((fruit) => Positioned(
                left: fruit.x,
                top: fruit.y,
                child: GestureDetector(
                  onTap: () => _onTapFruit(fruit),
                  child: Text(fruit.emoji, style: TextStyle(fontSize: fruit.size)),
                ),
              )),

          // Pop particles
          ..._particles.map((p) => Positioned(
                left: p.x,
                top: p.y,
                child: Opacity(
                  opacity: p.opacity.clamp(0.0, 1.0),
                  child: Transform.scale(
                    scale: p.scale.clamp(0.0, 2.0),
                    child: Text(p.emoji, style: const TextStyle(fontSize: 28)),
                  ),
                ),
              )),

          // HUD — top row: timer | score | combo
          if (_isPlaying || _isGameOver)
            Positioned(
              top: topPadding + 44,
              left: 12,
              right: 12,
              child: Row(
                children: [
                  Expanded(child: _buildHudItem(Icons.timer_outlined, '${_timeLeft}s', Colors.white)),
                  const SizedBox(width: 8),
                  Expanded(child: _buildHudItem(Icons.stars_rounded, '$_score', Colors.amberAccent)),
                  const SizedBox(width: 8),
                  Expanded(child: _buildHudItem(Icons.whatshot, 'x$_combo', Colors.deepOrangeAccent)),
                ],
              ),
            ),

          // Level badge + lives
          if (_isPlaying) ...[
            Positioned(
              top: topPadding + 96,
              left: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: _level >= 8
                        ? [Colors.redAccent, Colors.deepOrangeAccent]
                        : _level >= 5
                            ? [Colors.orangeAccent, Colors.amberAccent]
                            : [Colors.cyanAccent, Colors.lightBlueAccent],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Lv.$_level',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Positioned(
              top: topPadding + 96,
              right: 12,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(
                  5,
                  (i) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Icon(
                      i < _lives ? Icons.favorite : Icons.favorite_border,
                      color: i < _lives ? Colors.redAccent : Colors.white24,
                      size: 18,
                    ),
                  ),
                ),
              ),
            ),
            // Difficulty progress bar
            Positioned(
              top: topPadding + 130,
              left: 12,
              right: 12,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: (_poppedThisLevel / 10.0).clamp(0.0, 1.0),
                  backgroundColor: Colors.white10,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _level >= 8 ? Colors.redAccent : Colors.cyanAccent,
                  ),
                  minHeight: 4,
                ),
              ),
            ),
          ],

          // Welcome screen
          if (!_isPlaying && !_isGameOver) _buildWelcomeScreen(),

          // Game Over screen
          if (_isGameOver) _buildGameOverScreen(),

          // Back button
          SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.only(top: 4, left: 4),
                child: IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Colors.black26,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 22),
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

  Widget _buildWelcomeScreen() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 36),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF2D2D44), Color(0xFF1A1A2E)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.white12, width: 0.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🍑', style: TextStyle(fontSize: 64)),
              const SizedBox(height: 8),
              const Text(
                'Fruit Pop',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Pop fruits, earn coins!',
                style: TextStyle(fontSize: 13, color: Colors.white54),
              ),
              const SizedBox(height: 4),
              const Text(
                'Difficulty increases every 10 pops',
                style: TextStyle(fontSize: 11, color: Colors.white38),
              ),
              const SizedBox(height: 24),
              _buildInstruction('👆', 'Tap fruits to pop them for points!'),
              const SizedBox(height: 8),
              _buildInstruction('⭐', 'Golden fruits give 50 bonus points!'),
              const SizedBox(height: 8),
              _buildInstruction('🤢', 'Avoid rotten items or lose 10 points!'),
              const SizedBox(height: 8),
              _buildInstruction('🔥', 'Fast fruits appear at higher levels!'),
              const SizedBox(height: 8),
              _buildInstruction('❤️', 'Don\'t miss 5 fruits or game ends!'),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: CustomElevatedButton(
                  onPressed: _startGame,
                  backgroundColor: const Color(0xFFE94560),
                  foregroundColor: Colors.white,
                  text: 'Start Popping! 🚀',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGameOverScreen() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 36),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _lives <= 0 ? 'Game Over! 😵' : 'Time\'s Up! ⏰',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: _lives <= 0 ? Colors.red : Colors.orange,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '$_score pts',
                style: const TextStyle(
                  fontSize: 44,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0F3460),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Lv.$_level reached  •  Best Combo: x$_bestCombo  •  $_totalPopped popped',
                style: const TextStyle(fontSize: 13, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.monetization_on, color: Colors.orange, size: 24),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        '+$_coinsEarned Kids Coins!',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange.shade800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Coins added to your parent balance!',
                style: TextStyle(fontSize: 11, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
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
    );
  }

  Widget _buildHudItem(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12, width: 0.5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 15),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              text,
              style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              textAlign: TextAlign.center,
            ),
          ),
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
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.white70,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
