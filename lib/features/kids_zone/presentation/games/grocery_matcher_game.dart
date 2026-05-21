import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lets_vhandar/core/constants/color_constant.dart';
import 'package:lets_vhandar/features/kids_zone/providers/kids_zone_provider.dart';

class MemoryCard {
  final int id;
  final String emoji;
  bool isFlipped;
  bool isMatched;

  MemoryCard({
    required this.id,
    required this.emoji,
    this.isFlipped = false,
    this.isMatched = false,
  });
}

class GroceryMatcherGame extends ConsumerStatefulWidget {
  const GroceryMatcherGame({super.key});

  @override
  ConsumerState<GroceryMatcherGame> createState() => _GroceryMatcherGameState();
}

class _GroceryMatcherGameState extends ConsumerState<GroceryMatcherGame> {
  final List<String> _emojis = ['🍎', '🥛', '🍪', '🍌', '🥕', '🍞', '🍩', '🍉'];
  List<MemoryCard> _cards = [];
  List<int> _selectedIndices = [];
  int _flips = 0;
  int _matchesCount = 0;
  bool _isBusy = false;
  bool _isFinished = false;
  int _coinsEarned = 0;

  @override
  void initState() {
    super.initState();
    _startNewGame();
  }

  void _startNewGame() {
    setState(() {
      final doubleEmojis = [..._emojis, ..._emojis]..shuffle();
      _cards = List.generate(doubleEmojis.length, (index) {
        return MemoryCard(id: index, emoji: doubleEmojis[index]);
      });
      _selectedIndices.clear();
      _flips = 0;
      _matchesCount = 0;
      _isBusy = false;
      _isFinished = false;
      _coinsEarned = 0;
    });
  }

  void _onCardTap(int index) {
    if (_isBusy || _cards[index].isFlipped || _cards[index].isMatched) return;

    setState(() {
      _cards[index].isFlipped = true;
      _selectedIndices.add(index);
    });

    if (_selectedIndices.length == 2) {
      _flips++;
      _isBusy = true;

      final firstIdx = _selectedIndices[0];
      final secondIdx = _selectedIndices[1];

      if (_cards[firstIdx].emoji == _cards[secondIdx].emoji) {
        // Match!
        setState(() {
          _cards[firstIdx].isMatched = true;
          _cards[secondIdx].isMatched = true;
          _selectedIndices.clear();
          _matchesCount++;
          _isBusy = false;
        });

        _checkVictory();
      } else {
        // No match, flip back after a small delay
        Timer(const Duration(milliseconds: 900), () {
          setState(() {
            _cards[firstIdx].isFlipped = false;
            _cards[secondIdx].isFlipped = false;
            _selectedIndices.clear();
            _isBusy = false;
          });
        });
      }
    }
  }

  void _checkVictory() {
    if (_matchesCount == _emojis.length) {
      int coins = 10;
      if (_flips <= 18) {
        coins = 40;
      } else if (_flips <= 26) {
        coins = 25;
      }

      setState(() {
        _isFinished = true;
        _coinsEarned = coins;
      });

      ref.read(kidsZoneProvider.notifier).addCoins(coins);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3E5F5), // Playful purple child theme
      appBar: AppBar(
        title: const Text('Grocery Card Match 🧩'),
        centerTitle: true,
        backgroundColor: Colors.purple.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
        child: Column(
          children: [
            // --- Info Bar ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Flips: $_flips',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple.shade800,
                  ),
                ),
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: Colors.purple.shade200),
                  ),
                  child: Text(
                    'Matches: $_matchesCount / 8',
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple.shade900,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.h),

            if (!_isFinished)
              // --- 4x4 Card Matching Grid ---
              Expanded(
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 10.w,
                    mainAxisSpacing: 10.h,
                  ),
                  itemCount: _cards.length,
                  itemBuilder: (context, index) {
                    final card = _cards[index];
                    final isFaceUp = card.isFlipped || card.isMatched;

                    return GestureDetector(
                      onTap: () => _onCardTap(index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        decoration: BoxDecoration(
                          color: isFaceUp ? Colors.white : Colors.purple.shade400,
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            color: isFaceUp
                                ? Colors.purple.shade200
                                : Colors.transparent,
                            width: 2.w,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.purple.withValues(alpha: 0.15),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            isFaceUp ? card.emoji : '❓',
                            style: TextStyle(
                              fontSize: isFaceUp ? 28.sp : 22.sp,
                              color: isFaceUp ? null : Colors.white,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              )
            else
              // --- Victory Screen ---
              Expanded(
                child: Center(
                  child: Container(
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
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'You Won! 🏆',
                          style: TextStyle(
                            fontSize: 24.sp,
                            fontWeight: FontWeight.w900,
                            color: Colors.purple.shade800,
                          ),
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          'Completed in only:',
                          style: TextStyle(
                              fontSize: 14.sp, color: AppColor.textMuted),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          '$_flips Flips',
                          style: TextStyle(
                            fontSize: 28.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.purple.shade700,
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
                            'Coins added to your parent balance!',
                            style: TextStyle(
                                fontSize: 11.sp, color: Colors.grey.shade500),
                          ),
                        ],
                        SizedBox(height: 28.h),
                        ElevatedButton(
                          onPressed: _startNewGame,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple.shade700,
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
                ),
              ),
          ],
        ),
      ),
    );
  }
}
