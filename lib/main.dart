import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

void main() {
  runApp(SnakeGame());
}

class SnakeGame extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Snake Game',
      home: SnakeGameScreen(),
    );
  }
}

class SnakeGameScreen extends StatefulWidget {
  @override
  _SnakeGameScreenState createState() => _SnakeGameScreenState();
}

class _SnakeGameScreenState extends State<SnakeGameScreen> {
  static const int gridSize = 20;
  static const int snakeSpeed = 300;

  List<Offset> snake = [Offset(10, 10)];
  Offset food = Offset(5, 5);
  Direction direction = Direction.right;
  bool isGameOver = false;
  int score = 0;

  @override
  void initState() {
    super.initState();
    startGame();
  }

  void startGame() {
    isGameOver = false;
    snake = [Offset(10, 10)];
    direction = Direction.right;
    score = 0;
    generateFood();
    Timer.periodic(Duration(milliseconds: snakeSpeed), (timer) {
      if (!isGameOver) {
        setState(() {
          moveSnake();
          checkCollisions();
        });
      } else {
        timer.cancel();
      }
    });
  }

  void moveSnake() {
    Offset head = snake.first;
    Offset newHead;
    switch (direction) {
      case Direction.up:
        newHead = Offset(head.dx, head.dy - 1);
        break;
      case Direction.down:
        newHead = Offset(head.dx, head.dy + 1);
        break;
      case Direction.left:
        newHead = Offset(head.dx - 1, head.dy);
        break;
      case Direction.right:
        newHead = Offset(head.dx + 1, head.dy);
        break;
    }
    snake.insert(0, newHead);
    if (newHead != food) {
      snake.removeLast();
    } else {
      score += 10;
      generateFood();
    }
  }

  void generateFood() {
    final random = Random();
    food = Offset(random.nextInt(gridSize).toDouble(),
        random.nextInt(gridSize).toDouble());
  }

  void checkCollisions() {
    Offset head = snake.first;
    if (head.dx < 0 ||
        head.dx >= gridSize ||
        head.dy < 0 ||
        head.dy >= gridSize ||
        snake.sublist(1).any((segment) => segment == head)) {
      isGameOver = true;
    }
  }

  void handleTap(Direction newDirection) {
    if ((direction == Direction.up && newDirection != Direction.down) ||
        (direction == Direction.down && newDirection != Direction.up) ||
        (direction == Direction.left && newDirection != Direction.right) ||
        (direction == Direction.right && newDirection != Direction.left)) {
      direction = newDirection;
    }
  }

  Widget buildSnake() {
    return Stack(
      children: [
        for (var i = 0; i < snake.length; i++)
          Positioned(
            left: snake[i].dx * gridSize,
            top: snake[i].dy * gridSize,
            child: Container(
              width: gridSize.toDouble(),
              height: gridSize.toDouble(),
              decoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
            ),
          ),
      ],
    );
  }

  void restartGame() {
    setState(() {
      startGame();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Snake Game'),
      ),
      body: GestureDetector(
        onVerticalDragUpdate: (details) {
          if (details.delta.dy > 0) {
            handleTap(Direction.down);
          } else if (details.delta.dy < 0) {
            handleTap(Direction.up);
          }
        },
        onHorizontalDragUpdate: (details) {
          if (details.delta.dx > 0) {
            handleTap(Direction.right);
          } else if (details.delta.dx < 0) {
            handleTap(Direction.left);
          }
        },
        child: Center(
          child: AspectRatio(
            aspectRatio: 1.0,
            child: Container(
              color: Colors.grey[200],
              child: Stack(
                children: [
                  buildSnake(),
                  if (!isGameOver)
                    Positioned(
                      left: food.dx * gridSize,
                      top: food.dy * gridSize,
                      child: Container(
                        width: gridSize.toDouble(),
                        height: gridSize.toDouble(),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  if (isGameOver)
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Game Over',
                            style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: restartGame,
                            child: Text('Restart Game'),
                          ),
                        ],
                      ),
                    ),
                  if (!isGameOver)
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Text(
                        'Score: $score',
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

enum Direction { up, down, left, right }
