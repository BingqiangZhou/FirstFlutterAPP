import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'dart:math';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '2048 Game',
      theme: ThemeData(primarySwatch: Colors.deepPurple, useMaterial3: true),
      home: const Game2048(),
    );
  }
}

class Game2048 extends StatefulWidget {
  const Game2048({super.key});

  @override
  State<Game2048> createState() => _Game2048State();
}

class _Game2048State extends State<Game2048> {
  static const int gridSize = 4;
  List<List<int>> grid = List.generate(
    gridSize,
    (_) => List.filled(gridSize, 0),
  );
  int score = 0;
  int bestScore = 0;
  bool isGameOver = false;
  bool isWin = false;
  Random random = Random();

  @override
  void initState() {
    super.initState();
    _initGame();
  }

  void _initGame() {
    setState(() {
      grid = List.generate(gridSize, (_) => List.filled(gridSize, 0));
      score = 0;
      isGameOver = false;
      isWin = false;
      _addNewTile();
      _addNewTile();
    });
  }

  void _addNewTile() {
    List<Point> emptyCells = [];
    for (int i = 0; i < gridSize; i++) {
      for (int j = 0; j < gridSize; j++) {
        if (grid[i][j] == 0) {
          emptyCells.add(Point(i, j));
        }
      }
    }

    if (emptyCells.isNotEmpty) {
      Point cell = emptyCells[random.nextInt(emptyCells.length)];
      grid[cell.x.toInt()][cell.y.toInt()] = random.nextInt(10) == 0 ? 4 : 2;
    }
  }

  void _moveLeft() {
    bool moved = false;
    for (int i = 0; i < gridSize; i++) {
      List<int> row = [];
      for (int j = 0; j < gridSize; j++) {
        if (grid[i][j] != 0) {
          row.add(grid[i][j]);
        }
      }

      List<int> newRow = [];
      for (int j = 0; j < row.length; j++) {
        if (j < row.length - 1 && row[j] == row[j + 1]) {
          newRow.add(row[j] * 2);
          score += row[j] * 2;
          if (row[j] * 2 == 2048) {
            isWin = true;
          }
          j++;
          moved = true;
        } else {
          newRow.add(row[j]);
        }
      }

      while (newRow.length < gridSize) {
        newRow.add(0);
      }

      for (int j = 0; j < gridSize; j++) {
        if (grid[i][j] != newRow[j]) {
          moved = true;
        }
        grid[i][j] = newRow[j];
      }
    }

    if (moved) {
      _addNewTile();
      _checkGameOver();
    }
  }

  void _moveRight() {
    bool moved = false;
    for (int i = 0; i < gridSize; i++) {
      List<int> row = [];
      for (int j = gridSize - 1; j >= 0; j--) {
        if (grid[i][j] != 0) {
          row.add(grid[i][j]);
        }
      }

      List<int> newRow = [];
      for (int j = 0; j < row.length; j++) {
        if (j < row.length - 1 && row[j] == row[j + 1]) {
          newRow.add(row[j] * 2);
          score += row[j] * 2;
          if (row[j] * 2 == 2048) {
            isWin = true;
          }
          j++;
          moved = true;
        } else {
          newRow.add(row[j]);
        }
      }

      while (newRow.length < gridSize) {
        newRow.add(0);
      }

      for (int j = 0; j < gridSize; j++) {
        if (grid[i][gridSize - 1 - j] != newRow[j]) {
          moved = true;
        }
        grid[i][gridSize - 1 - j] = newRow[j];
      }
    }

    if (moved) {
      _addNewTile();
      _checkGameOver();
    }
  }

  void _moveUp() {
    bool moved = false;
    for (int j = 0; j < gridSize; j++) {
      List<int> column = [];
      for (int i = 0; i < gridSize; i++) {
        if (grid[i][j] != 0) {
          column.add(grid[i][j]);
        }
      }

      List<int> newColumn = [];
      for (int i = 0; i < column.length; i++) {
        if (i < column.length - 1 && column[i] == column[i + 1]) {
          newColumn.add(column[i] * 2);
          score += column[i] * 2;
          if (column[i] * 2 == 2048) {
            isWin = true;
          }
          i++;
          moved = true;
        } else {
          newColumn.add(column[i]);
        }
      }

      while (newColumn.length < gridSize) {
        newColumn.add(0);
      }

      for (int i = 0; i < gridSize; i++) {
        if (grid[i][j] != newColumn[i]) {
          moved = true;
        }
        grid[i][j] = newColumn[i];
      }
    }

    if (moved) {
      _addNewTile();
      _checkGameOver();
    }
  }

  void _moveDown() {
    bool moved = false;
    for (int j = 0; j < gridSize; j++) {
      List<int> column = [];
      for (int i = gridSize - 1; i >= 0; i--) {
        if (grid[i][j] != 0) {
          column.add(grid[i][j]);
        }
      }

      List<int> newColumn = [];
      for (int i = 0; i < column.length; i++) {
        if (i < column.length - 1 && column[i] == column[i + 1]) {
          newColumn.add(column[i] * 2);
          score += column[i] * 2;
          if (column[i] * 2 == 2048) {
            isWin = true;
          }
          i++;
          moved = true;
        } else {
          newColumn.add(column[i]);
        }
      }

      while (newColumn.length < gridSize) {
        newColumn.add(0);
      }

      for (int i = 0; i < gridSize; i++) {
        if (grid[gridSize - 1 - i][j] != newColumn[i]) {
          moved = true;
        }
        grid[gridSize - 1 - i][j] = newColumn[i];
      }
    }

    if (moved) {
      _addNewTile();
      _checkGameOver();
    }
  }

  void _checkGameOver() {
    if (isWin) return;

    // 检查是否还有空格
    for (int i = 0; i < gridSize; i++) {
      for (int j = 0; j < gridSize; j++) {
        if (grid[i][j] == 0) {
          return;
        }
      }
    }

    // 检查是否还能合并
    for (int i = 0; i < gridSize; i++) {
      for (int j = 0; j < gridSize; j++) {
        if (j < gridSize - 1 && grid[i][j] == grid[i][j + 1]) {
          return;
        }
        if (i < gridSize - 1 && grid[i][j] == grid[i + 1][j]) {
          return;
        }
      }
    }

    setState(() {
      isGameOver = true;
      if (score > bestScore) {
        bestScore = score;
      }
    });
  }

  void _handleSwipe(DragEndDetails details) {
    if (isGameOver || isWin) return;

    double dx = details.velocity.pixelsPerSecond.dx;
    double dy = details.velocity.pixelsPerSecond.dy;

    if (dx.abs() > dy.abs()) {
      if (dx > 0) {
        _moveRight();
      } else {
        _moveLeft();
      }
    } else {
      if (dy > 0) {
        _moveDown();
      } else {
        _moveUp();
      }
    }

    setState(() {});
  }

  Color _getTileColor(int value) {
    switch (value) {
      case 2:
        return const Color(0xFFEEE4DA);
      case 4:
        return const Color(0xFFEDE0C8);
      case 8:
        return const Color(0xFFF2B179);
      case 16:
        return const Color(0xFFF59563);
      case 32:
        return const Color(0xFFF67C5F);
      case 64:
        return const Color(0xFFF65E3B);
      case 128:
        return const Color(0xFFEDCF72);
      case 256:
        return const Color(0xFFEDCC61);
      case 512:
        return const Color(0xFFEDC850);
      case 1024:
        return const Color(0xFFEDC53F);
      case 2048:
        return const Color(0xFFEDC22E);
      default:
        return const Color(0xFFCDC1B4);
    }
  }

  Color _getTextColor(int value) {
    return value <= 4 ? const Color(0xFF776E65) : Colors.white;
  }

  void _handleKeyEvent(RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      if (isGameOver || isWin) return;

      if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        _moveUp();
        setState(() {});
      } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        _moveDown();
        setState(() {});
      } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
        _moveLeft();
        setState(() {});
      } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
        _moveRight();
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('2048 Game'),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // 根据屏幕尺寸计算网格大小
          double gridSizeValue = min(
            constraints.maxWidth * 0.9,
            constraints.maxHeight * 0.6,
          );
          gridSizeValue = min(gridSizeValue, 400); // 最大400px
          gridSizeValue = max(gridSizeValue, 280); // 最小280px

          // 计算字体大小
          double tileFontSize = gridSizeValue / 12;
          double titleFontSize = min(48, constraints.maxWidth / 8);
          double buttonFontSize = min(16, constraints.maxWidth / 25);

          return RawKeyboardListener(
            focusNode: FocusNode(),
            onKey: _handleKeyEvent,
            autofocus: true,
            child: GestureDetector(
              onVerticalDragEnd: _handleSwipe,
              onHorizontalDragEnd: _handleSwipe,
              child: Container(
                color: const Color(0xFFFAF8EF),
                child: Column(
                  children: [
                    // 分数区域
                    Padding(
                      padding: EdgeInsets.all(constraints.maxWidth * 0.04),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildScoreBox('分数', score, constraints.maxWidth),
                          _buildScoreBox(
                            '最高分',
                            bestScore,
                            constraints.maxWidth,
                          ),
                        ],
                      ),
                    ),

                    // 游戏标题和按钮
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: constraints.maxWidth * 0.04,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '2048',
                            style: TextStyle(
                              fontSize: titleFontSize,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurple,
                            ),
                          ),
                          ElevatedButton(
                            onPressed: _initGame,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurple,
                              padding: EdgeInsets.symmetric(
                                horizontal: constraints.maxWidth * 0.06,
                                vertical: constraints.maxWidth * 0.03,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              '新游戏',
                              style: TextStyle(
                                fontSize: buttonFontSize,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: constraints.maxHeight * 0.02),

                    // 游戏网格 - 响应式大小
                    Expanded(
                      child: Center(
                        child: Container(
                          width: gridSizeValue,
                          height: gridSizeValue,
                          padding: EdgeInsets.all(gridSizeValue * 0.025),
                          decoration: BoxDecoration(
                            color: const Color(0xFFBBADA0),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: GridView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: gridSize,
                                  crossAxisSpacing: gridSizeValue * 0.025,
                                  mainAxisSpacing: gridSizeValue * 0.025,
                                ),
                            itemCount: gridSize * gridSize,
                            itemBuilder: (context, index) {
                              int row = index ~/ gridSize;
                              int col = index % gridSize;
                              int value = grid[row][col];

                              return Container(
                                decoration: BoxDecoration(
                                  color: _getTileColor(value),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: Text(
                                    value == 0 ? '' : '$value',
                                    style: TextStyle(
                                      fontSize: value > 512
                                          ? tileFontSize * 0.7
                                          : tileFontSize,
                                      fontWeight: FontWeight.bold,
                                      color: _getTextColor(value),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),

                    // 游戏状态提示
                    if (isWin || isGameOver)
                      Container(
                        padding: EdgeInsets.all(constraints.maxWidth * 0.04),
                        margin: EdgeInsets.all(constraints.maxWidth * 0.04),
                        decoration: BoxDecoration(
                          color: isWin ? Colors.green : Colors.red,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Text(
                              isWin ? '🎉 恭喜你赢了！' : '😢 游戏结束',
                              style: TextStyle(
                                fontSize: min(24, constraints.maxWidth / 15),
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: constraints.maxWidth * 0.02),
                            Text(
                              '最终得分: $score',
                              style: TextStyle(
                                fontSize: min(18, constraints.maxWidth / 20),
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),

                    // 操作提示
                    Padding(
                      padding: EdgeInsets.all(constraints.maxWidth * 0.04),
                      child: Column(
                        children: [
                          Text(
                            '滑动屏幕来移动方块',
                            style: TextStyle(
                              fontSize: min(16, constraints.maxWidth / 25),
                              color: Colors.grey,
                            ),
                          ),
                          SizedBox(height: constraints.maxWidth * 0.01),
                          Text(
                            '或使用方向键: ↑ ↓ ← →',
                            style: TextStyle(
                              fontSize: min(14, constraints.maxWidth / 28),
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildScoreBox(String label, int value, double screenWidth) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.04,
        vertical: screenWidth * 0.02,
      ),
      decoration: BoxDecoration(
        color: Colors.deepPurple,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: min(14, screenWidth / 30),
              color: Colors.white70,
            ),
          ),
          Text(
            '$value',
            style: TextStyle(
              fontSize: min(24, screenWidth / 18),
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
