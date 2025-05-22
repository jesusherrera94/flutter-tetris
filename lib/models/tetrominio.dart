import 'package:flutter/material.dart';

// Tetromino Class
class Tetromino {
  TetrominoType type;
  Color? color;
  // List of shapes for each rotation.  Use const for better performance.
  static const List<List<List<Offset>>> _shapes = [
    // I-shape
    [
      [Offset(-1, 0), Offset(0, 0), Offset(1, 0), Offset(2, 0)],
      [Offset(0, -1), Offset(0, 0), Offset(0, 1), Offset(0, 2)],
      [Offset(-1, 0), Offset(0, 0), Offset(1, 0), Offset(2, 0)],
      [Offset(0, -1), Offset(0, 0), Offset(0, 1), Offset(0, 2)],
    ],
    // J-shape
    [
      [Offset(-1, 0), Offset(0, 0), Offset(1, 0), Offset(1, -1)],
      [Offset(0, -1), Offset(0, 0), Offset(0, 1), Offset(-1, 1)],
      [Offset(-1, 0), Offset(0, 0), Offset(1, 0), Offset(-1, 1)],
      [Offset(0, -1), Offset(0, 0), Offset(0, 1), Offset(1, -1)],
    ],
    // L-shape
    [
      [Offset(-1, 0), Offset(0, 0), Offset(1, 0), Offset(1, 1)],
      [Offset(0, -1), Offset(0, 0), Offset(0, 1), Offset(1, 1)],
      [Offset(-1, 0), Offset(0, 0), Offset(1, 0), Offset(-1, 1)],
      [Offset(0, -1), Offset(0, 0), Offset(0, 1), Offset(-1, -1)],
    ],
    // O-shape
    [
      [Offset(0, 0), Offset(1, 0), Offset(0, -1), Offset(1, -1)],
      [Offset(0, 0), Offset(1, 0), Offset(0, -1), Offset(1, -1)],
      [Offset(0, 0), Offset(1, 0), Offset(0, -1), Offset(1, -1)],
      [Offset(0, 0), Offset(1, 0), Offset(0, -1), Offset(1, -1)],
    ],
    // S-shape
    [
      [Offset(0, 0), Offset(1, 0), Offset(-1, -1), Offset(0, -1)],
      [Offset(0, -1), Offset(0, 0), Offset(1, 0), Offset(1, 1)],
      [Offset(0, 0), Offset(1, 0), Offset(-1, -1), Offset(0, -1)],
      [Offset(0, -1), Offset(0, 0), Offset(1, 0), Offset(1, 1)],
    ],
    // T-shape
    [
      [Offset(-1, 0), Offset(0, 0), Offset(1, 0), Offset(0, -1)],
      [Offset(0, -1), Offset(0, 0), Offset(0, 1), Offset(-1, 0)],
      [Offset(-1, 0), Offset(0, 0), Offset(1, 0), Offset(0, 1)],
      [Offset(0, -1), Offset(0, 0), Offset(0, 1), Offset(1, 0)],
    ],
    // Z-shape
    [
      [Offset(-1, 0), Offset(0, 0), Offset(0, -1), Offset(1, -1)],
      [Offset(1, -1), Offset(0, -1), Offset(0, 0), Offset(1, 0)],
      [Offset(-1, 0), Offset(0, 0), Offset(0, -1), Offset(1, -1)],
      [Offset(1, -1), Offset(0, -1), Offset(0, 0), Offset(1, 0)],
    ],
  ];

  Tetromino(this.type) : color = _tetrominoColors[type] {
    // No need to calculate shape here, just store the type.
  }

  // Color mapping for each tetromino type.  Use a const Map.
  static const Map<TetrominoType, Color> _tetrominoColors = {
    TetrominoType.I: Color(0xFF00FFFF), // Cyan
    TetrominoType.J: Color(0xFF0000FF), // Blue
    TetrominoType.L: Color(0xFFFF7F00), // Orange
    TetrominoType.O: Color(0xFFFFFF00), // Yellow
    TetrominoType.S: Color(0xFF00FF00), // Green
    TetrominoType.T: Color(0xFF800080), // Purple
    TetrominoType.Z: Color(0xFFFF0000), // Red
  };

  // Get the shape of the tetromino for a given rotation
  List<Offset> getShape(int rotation) {
    // Ensure rotation is within valid bounds (0 to 3)
    final normalizedRotation = rotation % _shapes[type.index].length;
    return _shapes[type.index][normalizedRotation];
  }

  // Get the number of possible rotations for the tetromino
  int getShapeCount() {
    return _shapes[type.index].length;
  }
}

// Tetromino Type Enum
enum TetrominoType {
  I,
  J,
  L,
  O,
  S,
  T,
  Z,
}
