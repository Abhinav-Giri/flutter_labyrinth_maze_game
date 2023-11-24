import 'package:flutter/material.dart';

void main() {
  runApp(EndlessLabyrinthApp());
}

class EndlessLabyrinthApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Endless Labyrinth',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: LabyrinthScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class LabyrinthScreen extends StatefulWidget {
  @override
  _LabyrinthScreenState createState() => _LabyrinthScreenState();
}

class _LabyrinthScreenState extends State<LabyrinthScreen> {
  static const int rows = 11;
  static const int columns = 11;

  List<List<bool>> labyrinth = [];

  int playerX = 0;
  int playerY = 0;

  int lastX = 0;
  int lastY = 0;

  int collisions = 0;
  bool gameWon = false;
  bool gameOver = false;

  void generateMaze() {
    labyrinth = List.generate(rows, (_) => List.generate(columns, (_) => true));

    final List<List<int>> directions = [
      [1, 0],
      [0, 1],
      [-1, 0],
      [0, -1],
    ];

    final List<List<bool>> visited =
        List.generate(rows, (_) => List.generate(columns, (_) => false));

    void recursiveBacktrack(int x, int y) {
      visited[y][x] = true;
      labyrinth[y][x] = false;

      if (x == columns - 1 && y == rows - 1) {
        return;
      }

      final List<List<int>> dirs = List.from(directions)..shuffle();
      for (final dir in dirs) {
        final int nx = x + dir[0] * 2;
        final int ny = y + dir[1] * 2;

        if (nx >= 0 &&
            nx < columns &&
            ny >= 0 &&
            ny < rows &&
            !visited[ny][nx]) {
          labyrinth[y + dir[1]][x + dir[0]] = false;
          recursiveBacktrack(nx, ny);
        }
      }
    }

    recursiveBacktrack(0, 0);

    if (!labyrinth[rows - 1][columns - 1]) {
      for (int i = rows - 1; i >= 0; i--) {
        for (int j = columns - 1; j >= 0; j--) {
          if (labyrinth[i][j]) {
            labyrinth[i][j] = false;
            return;
          }
        }
      }
    }
  }

  bool collisionOccurred = false;

  void movePlayer(int dx, int dy) {
    if (!gameWon && !gameOver) {
      int newPlayerX = playerX + dx;
      int newPlayerY = playerY + dy;

      bool collided = false; // Flag to check collision

      if (newPlayerX >= 0 &&
          newPlayerX < columns &&
          newPlayerY >= 0 &&
          newPlayerY < rows) {
        if (!labyrinth[newPlayerY][newPlayerX]) {
          setState(() {
            playerX = newPlayerX;
            playerY = newPlayerY;
            collisionOccurred = false; // Reset collision flag on a valid move
          });

          checkWinCondition(newPlayerX, newPlayerY);
        } else {
          collided = true; // Update collision flag
          collisions++;
          int attemptsLeft = 3 - collisions;
          if (attemptsLeft > 0) {
            print('Oops! You hit a wall. $attemptsLeft attempt(s) left.');
          } else {
            gameOver = true;
          }
        }
      }

      setState(() {
        collisionOccurred =
            collided; // Update collisionOccurred based on collision status
      });
    }
  }

  void checkWinCondition(int x, int y) {
    if (x == columns - 1 && y == rows - 1) {
      setState(() {
        gameWon = true;
      });
    }
  }

  void restartGame() {
    setState(() {
      playerX = 0;
      playerY = 0;
      gameWon = false;
      collisions = 0;
      gameOver = false;
      collisionOccurred = false;
      generateMaze(); // Regenerate the maze on restart
    });
  }

  @override
  void initState() {
    super.initState();
    generateMaze(); // Generate the maze when the screen initializes
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Endless Labyrinth',
          style: TextStyle(
            color: Colors.blueAccent,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.blue[100],
      ),
      backgroundColor: Colors.grey[300],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              width: 300,
              height: 300,
              child: GridView.builder(
                itemCount: rows * columns,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                ),
                itemBuilder: (BuildContext context, int index) {
                  int row = index ~/ columns;
                  int col = index % columns;

                  if (row == playerY && col == playerX) {
                    return Container(
                      color: Colors.red,
                      child: Icon(Icons.face_2_sharp),
                    );
                  } else {
                    return GestureDetector(
                      onTap: () {
                        int dx = (col - playerX).abs();
                        int dy = (row - playerY).abs();
                        if ((dx == 0 && dy == 1) || (dx == 1 && dy == 0)) {
                          movePlayer(col - playerX, row - playerY);
                        }
                      },
                      child: Container(
                        color: labyrinth[row][col] ? Colors.grey : Colors.blue,
                      ),
                    );
                  }
                },
              ),
            ),
            SizedBox(height: 20),
            if (gameWon)
              Column(
                children: [
                  Text(
                    'Congratulations! You won!',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: restartGame,
                    child: Text('Restart Game'),
                  ),
                ],
              ),
            if (gameOver)
              Column(
                children: [
                  Text(
                    'Game Over! You collided $collisions times!',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: restartGame,
                    child: Text('Restart Game'),
                  ),
                ],
              ),
            if (!gameOver && collisionOccurred && collisions == 1)
              Column(
                children: [
                  Text(
                    'Oops! You hit a wall. You have 2 chances left',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                ],
              ),
            if (!gameOver && collisionOccurred && collisions > 1)
              Column(
                children: [
                  Text(
                    'You collided $collisions times out of your 3 chances.',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
