import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';

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
  static const int rows = 10;
  static const int columns = 10;

  List<List<bool>> labyrinth = List.generate(
    rows,
    (_) => List.generate(columns, (_) => true),
  );

  int playerX = 0;
  int playerY = 0;

  int collisions = 0;
  bool gameWon = false;
  bool gameOver = false;

  void generateMaze() {
    for (int i = 0; i < rows; i++) {
      for (int j = 0; j < columns; j++) {
        labyrinth[i][j] = true;
      }
    }
    labyrinth[0][0] = false;
    labyrinth[0][1] = false;
    labyrinth[1][1] = false;
    labyrinth[2][1] = false;
    labyrinth[2][2] = false;
    labyrinth[2][3] = false;
    labyrinth[3][3] = false;
    labyrinth[4][3] = false;
    labyrinth[5][3] = false;
    labyrinth[5][4] = false;
    labyrinth[5][5] = false;
    labyrinth[6][5] = false;
    labyrinth[7][5] = false;
    labyrinth[8][5] = false;
    labyrinth[8][6] = false;
    labyrinth[8][7] = false;
    labyrinth[8][8] = false;
    labyrinth[9][8] = false;
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
    if (x == columns - 2 && y == rows - 1) {
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
    });
  }

  @override
  void initState() {
    super.initState();
    generateMaze();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue[100],
          title: BounceInUp(
            delay: Duration(milliseconds: 1000),
            child: Padding(
              padding: const EdgeInsets.only(top: 5),
              child: Center(
                child: Text('Endless Labyrinth',
                    style: TextStyle(
                        color: Colors.blueAccent,
                        fontSize: 40,
                        fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        ),
        backgroundColor: Colors.grey[300],
        body: ZoomIn(
          delay: const Duration(milliseconds: 1500),
          child: Center(
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
                            color:
                                labyrinth[row][col] ? Colors.grey : Colors.blue,
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
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
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
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
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
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),
                    ],
                  ),
                if (!gameOver && collisionOccurred && collisions > 1)
                  Column(
                    children: [
                      Text(
                        'You collided $collisions times out of your 3 chances.',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
