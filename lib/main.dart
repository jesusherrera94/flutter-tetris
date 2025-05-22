import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/services.dart'; //para eventos de teclado
import 'models/tetrominio.dart';

void main() {
  runApp(const TetrisApp());
}

class TetrisApp extends StatelessWidget {
  const TetrisApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Tetris',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: TetrisGame(),
    );
  }
}

class TetrisGame extends StatefulWidget {
  const TetrisGame({super.key});

  @override
  State<TetrisGame> createState() => _TetrisGameState();
}

class _TetrisGameState extends State<TetrisGame> {
  // dimension del tablero
  final int _boardWidth = 10;
  final int _boardHeight = 20;
  late List<List<Color?>> _gameBoard;

  // Tetromino actual
  Tetromino? _currentTetromino;
  int _tetrominoRow = 0;
  int _tetrominoCol = 0;
  int _tetrominoRotation = 0;

  // Estado del juego
  bool _isPlaying = false;
  bool _isPaused = false;
  bool _isGameOver = false;
  int _score = 0;
  int _level = 1;
  double _gameSpeed = 800; // Velocidad inicial en milisegundos
  Timer? _gameTimer;

  // siguiente tetromino
  Tetromino? _nextTetromino; // Para almacenar el siguiente tetromino

  // Puntuación
  int _linesCleared = 0;

  // TODO 4: crear un arreglo de players vacio almacenarlos aleatoriamente posteriormente en game over
  // para ello debe de crear una clase Player con los atributos name y score

  // Colores y fuentes personalizadas
  static const Color _backgroundColor = Color(0xFF000000); // Fondo negro
  static const Color _boardBorderColor = Color(0xFF333333); // Borde más oscuro
  static const Color _gameOverTextColor = Color(0xFFFFFFFF);
  static const TextStyle _scoreLevelTextStyle = TextStyle(
    fontSize: 16,
    color: Colors.white,
  );
  static const TextStyle _buttonTextStyle = TextStyle(
    fontSize: 14,
    color: Colors.white,
  );


  @override
  void initState() {
    super.initState();
    _initGame();
    RawKeyboard.instance.addListener(_handleKeyEvent);
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    RawKeyboard.instance.removeListener(_handleKeyEvent);
    super.dispose();
  }

  void _initGame() {
    _gameBoard = List.generate(_boardHeight, (_) => List.filled(_boardWidth, null));
    _score = 0;
    _level = 1;
    _gameSpeed = 800;
    _isGameOver = false;
    _isPlaying = false; 
    _isPaused = false;
    _linesCleared = 0;
    _spawnNextTetromino(); //aparecer el siguiente tetromino
    _spawnTetromino(); // Aparecer el tetromino actual.
  }

  // aparecer el siguiente tetromino
  void _spawnTetromino() {
    _currentTetromino = _nextTetromino; //mover el siguiente tetromino a actual
    _tetrominoRow = 1;
    _tetrominoCol = (_boardWidth / 2).floor() - 2; // Comenzar en el centro
    _tetrominoRotation = 0;
    _spawnNextTetromino(); //aparecer el siguiente tetromino
    // Comprobar si hay fin del juego: ¿se puede colocar el nuevo tetromino?
    if (!_canPlaceTetromino(_tetrominoRow, _tetrominoCol, _tetrominoRotation)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _gameOver();
    });
    }
  }

  //aparecer el siguiente tetromino
  void _spawnNextTetromino() {
    _nextTetromino = Tetromino(
      TetrominoType.values[math.Random().nextInt(TetrominoType.values.length)],
    );
  }

  // Game loop
  void _startGameLoop() {
    _gameTimer = Timer.periodic(Duration(milliseconds: _gameSpeed.toInt()), (timer) {
      if (_isPlaying && !_isPaused) { // Only if playing and not paused
        _moveDown();
      }
    });
  }

  // detener el game loop
  void _stopGameLoop() {
    _gameTimer?.cancel();
  }

  // Helpers para el juego
  // verificar si se puede colocar el tetromino
  // en la posición y rotación dadas
  bool _canPlaceTetromino(int newRow, int newCol, int newRotation) {
    if (_currentTetromino == null){ 
      return true;
    }
    final List<Offset> shape = _currentTetromino!.getShape(newRotation);
    for (Offset offset in shape) {
      int row = newRow + offset.dy.toInt();
      int col = newCol + offset.dx.toInt();

      if (row < 0 ||
          row >= _boardHeight ||
          col < 0 ||
          col >= _boardWidth ||
          _gameBoard[row][col] != null) {
        return false;
      }
    }
    return true;
  }

  // mueve el tetromino hacia abajo
  void _moveDown() {
    if (_currentTetromino == null) return;
    if (_canPlaceTetromino(_tetrominoRow + 1, _tetrominoCol, _tetrominoRotation)) {
      setState(() {
        _tetrominoRow++;
      });
    } else {
      _placeTetromino();
    }
  }

  // Mover el tetromino a la izquierda
  void _moveLeft() {
    if (_currentTetromino == null) return;
    if (_canPlaceTetromino(_tetrominoRow, _tetrominoCol - 1, _tetrominoRotation)) {
      setState(() {
        _tetrominoCol--;
      });
    }
  }

  // Mover el tetromino a la derecha
  void _moveRight() {
    if (_currentTetromino == null) return;
    if (_canPlaceTetromino(_tetrominoRow, _tetrominoCol + 1, _tetrominoRotation)) {
      setState(() {
        _tetrominoCol++;
      });
    }
  }

  // Rotar el tetromino
  void _rotate() {
    if (_currentTetromino == null) return;
    int newRotation = (_tetrominoRotation + 1) % _currentTetromino!.getShapeCount();
    if (_canPlaceTetromino(_tetrominoRow, _tetrominoCol, newRotation)) {
      setState(() {
        _tetrominoRotation = newRotation;
      });
    }
  }

  // Colocar el tetromino en el tablero
  void _placeTetromino() {
    if (_currentTetromino == null) return;
    List<Offset> shape = _currentTetromino!.getShape(_tetrominoRotation);
    for (Offset offset in shape) {
      int row = _tetrominoRow + offset.dy.toInt();
      int col = _tetrominoCol + offset.dx.toInt();
      _gameBoard[row][col] = _currentTetromino!.color;
    }
    _linesCleared = _clearLines();
    _score += _calculateScore(_linesCleared, _level);
    // TODO 3: Actualmente se sube de nivel con 1000 * _level puntos,
    // se desea cambiar a que aumente de nivel cada 200 puntos
    // para acelerar el juego
    if (_score >= _level * 1000) {
      _level++;
      _gameSpeed *= 0.9; // Aumentar velocidad, reducir retraso
      _stopGameLoop();
      _startGameLoop();
    }
    _spawnTetromino();
  }

  // limpiar las lineas completas
  // y devolver el número de líneas eliminadas
  int _clearLines() {
    int linesCleared = 0;
    for (int row = _boardHeight - 1; row >= 0; row--) {
      if (_gameBoard[row].every((cell) => cell != null)) {
        linesCleared++;
        // Remove the completed line and add a new empty line at the top
        _gameBoard.removeAt(row);
        _gameBoard.insert(0, List.filled(_boardWidth, null));
      }
    }
    return linesCleared;
  }

  // calcular la puntuación
  // en función de las líneas eliminadas y el nivel
  int _calculateScore(int linesCleared, int level) {
    if (linesCleared == 0) return 0;
    return (level * linesCleared * linesCleared * 100);
  }

  // Game Over
  void _gameOver() {
    if (_isGameOver) return;
    _stopGameLoop();
    // TODO 5.2: Al finalizar el juego, se debe de guardar el score y asignar 
    // el nombre de un jugador aleatorio a este score(leer los nombres del archivo de data)
    // Hint: crear un metodo privado _setRandomPlayerNameToScore,
    // el cual inserte el score en la lista de jugadores
    // y debera de ordenar la lista de jugadores por score
    // y limitar la lista a los 5 mejores jugadores
    setState(() {
      _isPlaying = false;
      _isGameOver = true;
    });
    Future.delayed(Duration(milliseconds: 50), () {
    if (mounted) {
      _showGameOverDialog();
    }
  });
  }

  // muestra Game Over Dialog
  void _showGameOverDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _backgroundColor,
        title: Text(
          'Game Over',
          style: _scoreLevelTextStyle.copyWith(fontSize: 24),
        ),
        // TODO 5.1: Ademas de mostrar el score, se desea mostrar
        // el listado de jugadores y sus scores,
        // en un Column este listado se debe de mostrar en orden descendente
        // por score.
        // Hint: usar el widget ListTile para cada jugador
        // Hint: usar el widget SizedBox para limitar la altura del listado
        // debe respetar el "Your Score" y debajo de este deberá mostrar el listado de los 5 mejores jugadores
        content: Text(
          'Your Score: $_score',
          style: _scoreLevelTextStyle,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _initGame();
              setState(() {
                _isPlaying = false;
                _isGameOver = false;
              });
            },
            child: Text(
              'Play Again',
              style: _buttonTextStyle,
            ),
          ),
        ],
      ),
    );
  }

  // manejar eventos de teclado
  // para controlar el tetromino
  // y pausar/reanudar el juego
  void _handleKeyEvent(RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
        _moveLeft();
      } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
        _moveRight();
      } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        _moveDown();
      } else if (event.logicalKey == LogicalKeyboardKey.space) {
        _rotate();
      } else if (event.logicalKey == LogicalKeyboardKey.enter) {
        if (!_isPlaying) {
          _startGame();
        } else if (_isPaused) {
          _resumeGame();
        } else {
          _pauseGame();
        }
      }
    }
  }

  // Iniciar el juego
  // y el bucle de juego
  void _startGame() {
    if (!_isPlaying) {
      setState(() {
        _isPlaying = true;
        _isGameOver = false; // Reiniciar el estado de Game Over
        _spawnTetromino(); // Aparecer el primer tetromino
        _startGameLoop();
      });
    }
  }

  //pausar el juego
  void _pauseGame() {
    if (_isPlaying && !_isPaused) {
      setState(() {
        _isPaused = true;
        _stopGameLoop();
      });
    }
  }

  //reanudar el juego
  void _resumeGame() {
    if (_isPlaying && _isPaused) {
      setState(() {
        _isPaused = false;
        _startGameLoop();
      });
    }
  }

  // Build del tablero de juego
  // y el tetromino actual
  Widget _buildGameBoard() {
    return Container(
      padding: EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        border: Border.all(color: _boardBorderColor, width: 4.0),
        color: _backgroundColor,
      ),
      child: AspectRatio(
        aspectRatio: _boardWidth / _boardHeight,
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: _boardWidth,
            childAspectRatio: 1.0 / 1.0,
          ),
          itemCount: _boardHeight * _boardWidth,
          itemBuilder: (context, index) {
            int row = index ~/ _boardWidth;
            int col = index % _boardWidth;
            Color? cellColor = _gameBoard[row][col];

            //Dibuja el tetromino actual
            if (_currentTetromino != null) {
              List<Offset> shape = _currentTetromino!.getShape(_tetrominoRotation);
              for (Offset offset in shape) {
                int pieceRow = _tetrominoRow + offset.dy.toInt();
                int pieceCol = _tetrominoCol + offset.dx.toInt();
                if (pieceRow == row && pieceCol == col) {
                  cellColor = _currentTetromino!.color;
                  break;
                }
              }
            }

            return Container(
              margin: EdgeInsets.all(1.0),
              decoration: BoxDecoration(
                color: cellColor ?? Colors.grey[800], // Color de fondo de la celda
                // Color de la celda
                border: Border.all(
                  color: cellColor != null ? Colors.grey[900]! : _boardBorderColor,
                  width: 1.0,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // Build del preview del siguiente tetromino
  Widget _buildNextTetrominoPreview() {
    if (_nextTetromino == null) {
      return Container();
    }

    List<Offset> shape = _nextTetromino!.getShape(0);
    int minRow = shape.map((offset) => offset.dy.toInt()).reduce(math.min);
    int maxRow = shape.map((offset) => offset.dy.toInt()).reduce(math.max);
    int minCol = shape.map((offset) => offset.dx.toInt()).reduce(math.min);
    int maxCol = shape.map((offset) => offset.dx.toInt()).reduce(math.max);

    int gridWidth = maxCol - minCol + 3;
    int gridHeight = maxRow - minRow + 3;

    int rowOffset = (gridHeight - (maxRow - minRow + 1)) ~/ 2 - minRow;
    int colOffset = (gridWidth - (maxCol - minCol + 1)) ~/ 2 - minCol;

    return Container(
      padding: EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        border: Border.all(color: _boardBorderColor, width: 4.0),
        color: _backgroundColor,
      ),
      child: AspectRatio(
        aspectRatio: gridWidth / gridHeight,
        child: GridView.builder(
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: gridWidth,
            childAspectRatio: 1.0 / 1.0,
          ),
          itemCount: gridHeight * gridWidth,
          itemBuilder: (context, index) {
            int row = index ~/ gridWidth;
            int col = index % gridWidth;
            Color? cellColor;

            for (Offset offset in shape) {
              int pieceRow = offset.dy.toInt() + rowOffset;
              int pieceCol = offset.dx.toInt() + colOffset;
              if (pieceRow == row && pieceCol == col) {
                cellColor = _nextTetromino!.color;
                break;
              }
            }
            return Container(
              margin: EdgeInsets.all(1.0),
              decoration: BoxDecoration(
                color: cellColor ?? Colors.grey[800],
                border: Border.all(
                  color: cellColor != null ? Colors.grey[900]! : _boardBorderColor,
                  width: 1.0,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            // TODO 2: agregar el texto del score y el level demostrado en un row
             // y ademas su nombre y cuenta encima de esta fila(como title)
            Text(
              'Score: $_score',
              style: _scoreLevelTextStyle,
            ),
            Text(
              'Level: $_level',
              style: _scoreLevelTextStyle,
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 220, // Ud puede ajustar el ancho
                  height: 540, // o cualquier altura fija que desee
                  child: _buildGameBoard(), // Build del game board
                ),
                SizedBox(width: 16),
                Column(
                  children: [
                    SizedBox(
                      width: 80,
                      height: 120,
                      child: _buildNextTetrominoPreview(), // Build del preview del siguiente tetromino
                    ),
                    SizedBox(height: 16),
                    if (!_isPlaying)
                      ElevatedButton(
                        onPressed: _startGame,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                        ),
                        child: const Text('Start', style: _buttonTextStyle),
                      ),
                    if (_isPlaying)
                      ElevatedButton(
                        onPressed: _isPaused ? _resumeGame : _pauseGame,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isPaused ? Colors.green : Colors.yellow,
                          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                        ),
                        // TODO 1: Cambiar el color del botón según el estado
                        // del juego (pausado o no)
                        // Hint: usar _buttonTextStyle.copyWith para cambiar el color
                        child: Text(_isPaused ? 'Resume' : 'Pause', style: _buttonTextStyle),
                      ),
                    if (_isGameOver) //Muestra el texto de Game Over
                      Text(
                        'Game Over',
                        style: _scoreLevelTextStyle.copyWith(fontSize: 24, color: _gameOverTextColor),
                      ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: _isPlaying ? _moveLeft : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                  ), // Dishabilitado si no está jugando
                  child: Text('Left', style: _buttonTextStyle),
                ),
                ElevatedButton(
                  onPressed: _isPlaying ? _rotate : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                  ),
                  child: Text('Rotate', style: _buttonTextStyle),
                ),
                ElevatedButton(
                  onPressed: _isPlaying ? _moveRight : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                  ),
                  child: Text('Right', style: _buttonTextStyle),
                ),
              ],
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isPlaying ? _moveDown : null,
              child: Text('Down', style: _buttonTextStyle),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

