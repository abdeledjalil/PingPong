import 'dart:async';

import 'package:flutter/material.dart';

void main() {
  runApp(const PingPongApp());
}

enum GameDifficulty {
  easy('سهل', 2.5),
  medium('متوسط', 3.5),
  hard('صعب', 5.0);

  const GameDifficulty(this.label, this.ballSpeed);

  final String label;
  final double ballSpeed;
}

class PingPongApp extends StatelessWidget {
  const PingPongApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ping Pong',
      theme: ThemeData(
        brightness: Brightness.dark,
        colorScheme:
            ColorScheme.fromSeed(
              seedColor: const Color(0xFF75F0C2),
              brightness: Brightness.dark,
            ).copyWith(
              primary: const Color(0xFF75F0C2),
              secondary: const Color(0xFFFF7E78),
            ),
        scaffoldBackgroundColor: const Color(0xFF080C12),
        useMaterial3: true,
      ),
      home: const PongGameScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class PongGameScreen extends StatefulWidget {
  const PongGameScreen({super.key});

  @override
  State<PongGameScreen> createState() => _PongGameScreenState();
}

class _PongGameScreenState extends State<PongGameScreen> {
  Timer? _timer;
  GameDifficulty difficulty = GameDifficulty.medium;

  // أبعاد إطار اللعبة
  final double gameWidth = 400;
  final double gameHeight = 600;

  // إحداثيات وسرعة الكرة
  double ballX = 0;
  double ballY = 0;
  double ballDx = 3.5;
  double ballDy = 3.5;
  final double ballRadius = 10;

  // مواقع المضارب
  double paddle1Y = 0; // اللاعب الأول (يسار)
  double paddle2Y = 0; // اللاعب الثاني (يمين)
  final double paddleHeight = 100;
  final double paddleWidth = 15;

  // النقاط وحالة اللعبة
  int score1 = 0;
  int score2 = 0;
  bool gameStarted = false;
  bool gameOver = false;
  String winningMessage = "";

  @override
  void initState() {
    super.initState();
  }

  // حلقة اللعبة الأساسية (Game Loop)
  void startGame() {
    if (gameStarted || gameOver) return;
    setState(() => gameStarted = true);
    _timer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      if (!gameStarted || gameOver) return;

      setState(() {
        // حركة الكرة
        ballX += ballDx;
        ballY += ballDy;

        // اصطدام الكرة بالأعلى والأسفل
        if (ballY <= -gameHeight / 2 + 10) {
          ballY = -gameHeight / 2 + 10;
          ballDy *= -1;
        }
        if (ballY >= gameHeight / 2 - 10) {
          ballY = gameHeight / 2 - 10;
          ballDy *= -1;
        }

        // اصطدام الكرة بالمضرب الأول (اليسار)
        double p1Left = -gameWidth / 2 + 30;
        double p1Right = p1Left + paddleWidth;
        if (ballDx < 0 &&
            ballX - ballRadius <= p1Right &&
            ballX + ballRadius >= p1Left &&
            ballY + ballRadius >= paddle1Y - paddleHeight / 2 &&
            ballY - ballRadius <= paddle1Y + paddleHeight / 2) {
          ballX = p1Right + ballRadius;
          ballDx = ballDx.abs();
        }

        // اصطدام الكرة بالمضرب الثاني (اليمين)
        double p2Right = gameWidth / 2 - 30;
        double p2Left = p2Right - paddleWidth;
        if (ballDx > 0 &&
            ballX + ballRadius >= p2Left &&
            ballX - ballRadius <= p2Right &&
            ballY + ballRadius >= paddle2Y - paddleHeight / 2 &&
            ballY - ballRadius <= paddle2Y + paddleHeight / 2) {
          ballX = p2Left - ballRadius;
          ballDx = -ballDx.abs();
        }

        // حساب النقاط عند تجاوز الحدود
        if (ballX < -gameWidth / 2) {
          score2++;
          resetBall();
          checkWinCondition();
        } else if (ballX > gameWidth / 2) {
          score1++;
          resetBall();
          checkWinCondition();
        }
      });
    });
  }

  void changeDifficulty(GameDifficulty selected) {
    setState(() {
      difficulty = selected;
      ballDx = ballDx.isNegative ? -selected.ballSpeed : selected.ballSpeed;
      ballDy = ballDy.isNegative ? -selected.ballSpeed : selected.ballSpeed;
    });
  }

  void resetBall() {
    ballX = 0;
    ballY = 0;
  }

  void checkWinCondition() {
    if (score1 >= 5) {
      gameOver = true;
      winningMessage = "Player 1: You Win!\nPlayer 2: You Lose!";
    } else if (score2 >= 5) {
      gameOver = true;
      winningMessage = "Player 2: You Win!\nPlayer 1: You Lose!";
    }
  }

  void replayGame() {
    _timer?.cancel();
    setState(() {
      ballX = 0;
      ballY = 0;
      ballDx = difficulty.ballSpeed;
      ballDy = difficulty.ballSpeed;
      paddle1Y = 0;
      paddle2Y = 0;
      score1 = 0;
      score2 = 0;
      gameStarted = false;
      gameOver = false;
      winningMessage = "";
    });
    startGame();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'PING PONG',
          style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 0),
        ),
        backgroundColor: const Color(0xFF080C12),
        centerTitle: true,
        actions: [
          PopupMenuButton<GameDifficulty>(
            key: const Key('difficultyMenu'),
            tooltip: 'مستوى الصعوبة',
            initialValue: difficulty,
            onSelected: changeDifficulty,
            itemBuilder: (context) => [
              for (final option in GameDifficulty.values)
                PopupMenuItem(
                  value: option,
                  child: Row(
                    children: [
                      Expanded(child: Text(option.label)),
                      if (option == difficulty)
                        const Icon(Icons.check_rounded, size: 18),
                    ],
                  ),
                ),
            ],
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.speed_rounded, size: 19),
                  const SizedBox(width: 4),
                  Text(difficulty.label),
                ],
              ),
            ),
          ),
          IconButton.filledTonal(
            key: const Key('replayButton'),
            tooltip: 'إعادة اللعب',
            onPressed: replayGame,
            icon: const Icon(Icons.replay_rounded),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Center(
        child: FittedBox(
          fit: BoxFit.contain,
          child: Container(
            width: gameWidth,
            height: gameHeight,
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFF314153), width: 1.5),
              borderRadius: BorderRadius.circular(20),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF111C29), Color(0xFF0B111A)],
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x55000000),
                  blurRadius: 28,
                  offset: Offset(0, 14),
                ),
              ],
            ),
            child: Stack(
              children: [
                // العنوان والنقاط في المنتصف بالأعلى
                Positioned(
                  top: 20,
                  left: 0,
                  right: 0,
                  child: Column(
                    children: [
                      const Text(
                        "JALILO PONG",
                        style: TextStyle(
                          color: Color(0xFF75F0C2),
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "$score1     $score2",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ),

                // المضرب الأول (اللاعب الأزرق - يسار) مع إمكانية السحب
                Positioned(
                  left: 30,
                  top: (gameHeight / 2) + paddle1Y - (paddleHeight / 2),
                  child: GestureDetector(
                    onVerticalDragUpdate: (details) {
                      setState(() {
                        paddle1Y += details.delta.dy;
                        // تقييد الحركة داخل الإطار
                        if (paddle1Y <
                            -gameHeight / 2 + paddleHeight / 2 + 40) {
                          paddle1Y = -gameHeight / 2 + paddleHeight / 2 + 40;
                        }
                        if (paddle1Y > gameHeight / 2 - paddleHeight / 2 - 20) {
                          paddle1Y = gameHeight / 2 - paddleHeight / 2 - 20;
                        }
                      });
                    },
                    child: Container(
                      width: paddleWidth,
                      height: paddleHeight,
                      decoration: BoxDecoration(
                        color: const Color(0xFF75F0C2),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: const [
                          BoxShadow(color: Color(0x8875F0C2), blurRadius: 14),
                        ],
                      ),
                    ),
                  ),
                ),

                // المضرب الثاني (اللاعب الأحمر - يمين) مع إمكانية السحب
                Positioned(
                  right: 30,
                  top: (gameHeight / 2) + paddle2Y - (paddleHeight / 2),
                  child: GestureDetector(
                    onVerticalDragUpdate: (details) {
                      setState(() {
                        paddle2Y += details.delta.dy;
                        // تقييد الحركة داخل الإطار
                        if (paddle2Y <
                            -gameHeight / 2 + paddleHeight / 2 + 40) {
                          paddle2Y = -gameHeight / 2 + paddleHeight / 2 + 40;
                        }
                        if (paddle2Y > gameHeight / 2 - paddleHeight / 2 - 20) {
                          paddle2Y = gameHeight / 2 - paddleHeight / 2 - 20;
                        }
                      });
                    },
                    child: Container(
                      width: paddleWidth,
                      height: paddleHeight,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF7E78),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: const [
                          BoxShadow(color: Color(0x88FF7E78), blurRadius: 14),
                        ],
                      ),
                    ),
                  ),
                ),

                // الكرة البيضاء
                Positioned(
                  left: (gameWidth / 2) + ballX - ballRadius,
                  top: (gameHeight / 2) + ballY - ballRadius,
                  child: Container(
                    width: ballRadius * 2,
                    height: ballRadius * 2,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF5F7FA),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: Color(0xAA75F0C2), blurRadius: 16),
                      ],
                    ),
                  ),
                ),

                if (!gameStarted && !gameOver)
                  Container(
                    color: const Color(0xE8080C12),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.sports_tennis_rounded,
                            color: Color(0xFF75F0C2),
                            size: 52,
                          ),
                          const SizedBox(height: 18),
                          const Text(
                            'استعد للمباراة',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 22),
                          FilledButton.icon(
                            key: const Key('startButton'),
                            onPressed: startGame,
                            icon: const Icon(Icons.play_arrow_rounded),
                            label: const Text('ابدأ اللعبة'),
                            style: FilledButton.styleFrom(
                              foregroundColor: const Color(0xFF07120E),
                              backgroundColor: const Color(0xFF75F0C2),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 14,
                              ),
                              textStyle: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // شاشة نهاية اللعبة (عند الفوز)
                if (gameOver)
                  Container(
                    color: const Color(0xE8080C12),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.emoji_events_rounded,
                            color: Color(0xFF75F0C2),
                            size: 48,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            winningMessage,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 22),
                          FilledButton.icon(
                            key: const Key('endReplayButton'),
                            onPressed: replayGame,
                            icon: const Icon(Icons.replay_rounded),
                            label: const Text('إعادة اللعب'),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
