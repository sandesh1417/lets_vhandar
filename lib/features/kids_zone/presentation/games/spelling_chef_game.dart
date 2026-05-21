import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lets_vhandar/core/constants/color_constant.dart';
import 'package:lets_vhandar/features/kids_zone/providers/kids_zone_provider.dart';

class SpellingWord {
  final String displayEmoji;
  final String word; // e.g. "APPLE"
  final int blankIndex; // e.g. 2 for P in "APPLE"
  final List<String> options; // e.g. ["P", "T", "G"]

  SpellingWord({
    required this.displayEmoji,
    required this.word,
    required this.blankIndex,
    required this.options,
  });
}

class SpellingChefGame extends ConsumerStatefulWidget {
  const SpellingChefGame({super.key});

  @override
  ConsumerState<SpellingChefGame> createState() => _SpellingChefGameState();
}

class _SpellingChefGameState extends ConsumerState<SpellingChefGame> {
  final List<SpellingWord> _allWords = [
    SpellingWord(
        displayEmoji: '🍎',
        word: 'APPLE',
        blankIndex: 2,
        options: ['P', 'B', 'M']),
    SpellingWord(
        displayEmoji: '🥛',
        word: 'MILK',
        blankIndex: 1,
        options: ['I', 'E', 'O']),
    SpellingWord(
        displayEmoji: '🍞',
        word: 'BREAD',
        blankIndex: 2,
        options: ['E', 'A', 'U']),
    SpellingWord(
        displayEmoji: '🍌',
        word: 'BANANA',
        blankIndex: 3,
        options: ['A', 'E', 'O']),
    SpellingWord(
        displayEmoji: '🥕',
        word: 'CARROT',
        blankIndex: 4,
        options: ['O', 'E', 'I']),
    SpellingWord(
        displayEmoji: '🧀',
        word: 'CHEESE',
        blankIndex: 3,
        options: ['E', 'A', 'I']),
    SpellingWord(
        displayEmoji: '🍯',
        word: 'HONEY',
        blankIndex: 2,
        options: ['N', 'M', 'H']),
  ];

  List<SpellingWord> _gameWords = [];
  int _currentIndex = 0;
  String? _selectedLetter;
  bool _isAnswerCorrect = false;
  bool _hasAnswered = false;
  int _score = 0;
  int _coinsEarned = 0;
  bool _isFinished = false;

  @override
  void initState() {
    super.initState();
    _startNewGame();
  }

  void _startNewGame() {
    setState(() {
      final list = [..._allWords]..shuffle();
      _gameWords = list.take(5).toList();
      _currentIndex = 0;
      _selectedLetter = null;
      _hasAnswered = false;
      _isAnswerCorrect = false;
      _score = 0;
      _coinsEarned = 0;
      _isFinished = false;
    });
  }

  void _checkAnswer(String letter) {
    if (_hasAnswered) return;

    final currentWord = _gameWords[_currentIndex];
    final correctLetter = currentWord.word[currentWord.blankIndex];
    final isCorrect = letter == correctLetter;

    setState(() {
      _selectedLetter = letter;
      _hasAnswered = true;
      _isAnswerCorrect = isCorrect;
      if (isCorrect) {
        _score += 20;
      }
    });
  }

  void _nextQuestion() {
    if (_currentIndex < 4) {
      setState(() {
        _currentIndex++;
        _selectedLetter = null;
        _hasAnswered = false;
        _isAnswerCorrect = false;
      });
    } else {
      setState(() {
        _isFinished = true;
        _coinsEarned = _score ~/ 5; // e.g. max 100 score -> 20 coins
      });
      if (_coinsEarned > 0) {
        ref.read(kidsZoneProvider.notifier).addCoins(_coinsEarned);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_gameWords.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final currentWord = _gameWords[_currentIndex];

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E1), // Playful warm honey child theme
      appBar: AppBar(
        title: const Text('Spelling Chef 👨‍🍳'),
        centerTitle: true,
        backgroundColor: Colors.amber.shade800,
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
                    'Word ${_currentIndex + 1} of 5',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber.shade900,
                    ),
                  ),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: Colors.amber.shade200),
                    ),
                    child: Text(
                      'Score: $_score',
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber.shade900,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.h),

              if (!_isFinished) ...[
                // --- Emoji Board ---
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 24.h),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.amber.withValues(alpha: 0.1),
                        blurRadius: 16,
                      )
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        currentWord.displayEmoji,
                        style: TextStyle(fontSize: 80.sp),
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'What is the spelling?',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppColor.textMuted,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24.h),

                // --- Word Puzzle Blanks ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(currentWord.word.length, (index) {
                    final char = currentWord.word[index];
                    final isBlank = index == currentWord.blankIndex;

                    return Container(
                      margin: EdgeInsets.symmetric(horizontal: 4.w),
                      width: 48.w,
                      height: 56.h,
                      decoration: BoxDecoration(
                        color: isBlank
                            ? (_hasAnswered
                                ? (_isAnswerCorrect
                                    ? Colors.green.shade100
                                    : Colors.red.shade100)
                                : Colors.amber.shade50)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: isBlank
                              ? (_hasAnswered
                                  ? (_isAnswerCorrect
                                      ? Colors.green
                                      : Colors.red)
                                  : Colors.amber.shade400)
                              : Colors.grey.shade300,
                          width: isBlank ? 2.w : 1.w,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          isBlank
                              ? (_hasAnswered ? _selectedLetter ?? '' : '?')
                              : char,
                          style: TextStyle(
                            fontSize: 22.sp,
                            fontWeight: FontWeight.bold,
                            color: isBlank
                                ? (_hasAnswered
                                    ? (_isAnswerCorrect
                                        ? Colors.green.shade900
                                        : Colors.red.shade900)
                                    : Colors.amber.shade900)
                                : Colors.black87,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
                SizedBox(height: 32.h),

                // --- Input Letter Options ---
                Text(
                  'Tap the missing letter:',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColor.textBlack,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: currentWord.options.map((letter) {
                    final isSelected = _selectedLetter == letter;
                    Color btnBg = Colors.white;
                    Color borderC = Colors.amber.shade300;

                    if (_hasAnswered && isSelected) {
                      btnBg = _isAnswerCorrect
                          ? Colors.green.shade500
                          : Colors.red.shade500;
                      borderC = Colors.transparent;
                    }

                    return GestureDetector(
                      onTap: () => _checkAnswer(letter),
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 10.w),
                        width: 60.w,
                        height: 60.h,
                        decoration: BoxDecoration(
                          color: btnBg,
                          shape: BoxShape.circle,
                          border: Border.all(color: borderC, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            letter,
                            style: TextStyle(
                              fontSize: 22.sp,
                              fontWeight: FontWeight.w900,
                              color: _hasAnswered && isSelected
                                  ? Colors.white
                                  : Colors.amber.shade900,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),

                SizedBox(height: 32.h),

                // --- Feedback banner & Next Button ---
                if (_hasAnswered) ...[
                  Container(
                    width: double.infinity,
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                    decoration: BoxDecoration(
                      color: _isAnswerCorrect
                          ? Colors.green.withValues(alpha: 0.1)
                          : Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: _isAnswerCorrect
                            ? Colors.green.withValues(alpha: 0.3)
                            : Colors.red.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      _isAnswerCorrect
                          ? '🎉 Correct spelling! Excellent job, Chef!'
                          : '❌ Oops! Try the next food item!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: _isAnswerCorrect
                            ? Colors.green.shade800
                            : Colors.red.shade800,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: 24.h),
                  SizedBox(
                    width: double.infinity,
                    height: 52.h,
                    child: ElevatedButton(
                      onPressed: _nextQuestion,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber.shade800,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                      ),
                      child: Text(
                        'Next Word ➡️',
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ] else ...[
                // --- Final Results Board ---
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
                        'Yum! Perfect Cooking! 👨‍🍳',
                        style: TextStyle(
                          fontSize: 22.sp,
                          fontWeight: FontWeight.w900,
                          color: Colors.amber.shade900,
                        ),
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'Total Spelling Score:',
                        style: TextStyle(
                            fontSize: 14.sp, color: AppColor.textMuted),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        '$_score Points',
                        style: TextStyle(
                          fontSize: 28.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber.shade700,
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
                      ],
                      SizedBox(height: 28.h),
                      ElevatedButton(
                        onPressed: _startNewGame,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber.shade800,
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
