import 'dart:math';
// core game logic: swipe moves, tile sliding, merging, scoring, and new tiles.
// Grid is a 4x4 box of empty spots (null). startGame() clears it and adds 2 random tiles (2 or 4).

class GameModel {
  static const int gridSize = 4;
  List<List<int?>> grid = List.generate(gridSize, (_) => List<int?>.filled(gridSize, null));

  int score = 0;
  int bestScore = 0;

  GameModel() {
    startGame();
  }

  void startGame() {
    grid = List.generate(gridSize, (_) => List<int?>.filled(gridSize, null));
    score = 0;
    addRandomTile();
    addRandomTile();
  }

  // Swipe left (same for right/up/down by rotating logic later)
  bool moveLeft() {
    bool moved = false;
    
    for (int i = 0; i < gridSize; i++) { // each row
      List<int?> row = grid[i];
      
      // Remove nulls and pack to left: [2, null, 2, null] → [2, 2, null, null]
      List<int?> packed = [];
      for (int? val in row) {
        if (val != null) packed.add(val);
      }
      
      // Merge same numbers
      for (int j = 0; j < packed.length - 1; j++) {
        if (packed[j] != null && packed[j] == packed[j + 1]) {
          int merged = packed[j]! * 2;
          score += merged;
          packed[j] = merged;
          packed[j + 1] = null;
          moved = true;
        }
      }
      
      // Pack again after merge
      List<int?> newPacked = [];
      for (int? val in packed) {
        if (val != null) newPacked.add(val);
      }
      while (newPacked.length < gridSize) {
        newPacked.add(null);
      }
      
      // Update row if changed
      if (row.join(',') != newPacked.join(',')) {
        grid[i] = newPacked;
        moved = true;
      }
    }
    
    if (moved) {
      addRandomTile();
      if (score > bestScore) bestScore = score;
    }
    
    return moved;
  }

  // Add more directions later, but test left first
  bool moveRight() => _rotateClockwise() && moveLeft() && _rotateCounterClockwise();
  bool moveUp() => _rotateClockwiseTwice() && moveLeft() && _rotateCounterClockwiseTwice();
  bool moveDown() => _rotateClockwise() && moveLeft() && _rotateClockwise();

  // Rotation helpers (clever trick for all directions)
  bool _rotateClockwise() {
    // Transpose + reverse each row
    for (int i = 0; i < gridSize; i++) {
      for (int j = i + 1; j < gridSize; j++) {
        int? temp = grid[i][j];
        grid[i][j] = grid[j][i];
        grid[j][i] = temp;
      }
    }
    for (int i = 0; i < gridSize; i++) {
      grid[i] = grid[i].reversed.toList();
    }
    return true;
  }

  bool _rotateCounterClockwise() {
    for (int i = 0; i < gridSize; i++) {
      grid[i] = grid[i].reversed.toList();
    }
    for (int i = 0; i < gridSize; i++) {
      for (int j = i + 1; j < gridSize; j++) {
        int? temp = grid[i][j];
        grid[i][j] = grid[j][i];
        grid[j][i] = temp;
      }
    }
    return true;
  }

  bool _rotateClockwiseTwice() => _rotateClockwise() && _rotateClockwise();
  bool _rotateCounterClockwiseTwice() => _rotateCounterClockwise() && _rotateCounterClockwise();

  void addRandomTile() {
    List<int> emptyIndices = [];
    for (int i = 0; i < gridSize * gridSize; i++) {
      int row = i ~/ gridSize;
      int col = i % gridSize;
      if (grid[row][col] == null) emptyIndices.add(i);
    }
    if (emptyIndices.isNotEmpty) {
      int randomIndex = emptyIndices[Random().nextInt(emptyIndices.length)];
      int row = randomIndex ~/ gridSize;
      int col = randomIndex % gridSize;
      grid[row][col] = Random().nextBool() ? 2 : 4;
    }
  }

  bool get gameOver {
    // Check if full and no adjacent equals
    bool full = true;
    for (int i = 0; i < gridSize; i++) {
      for (int j = 0; j < gridSize; j++) {
        if (grid[i][j] == null) full = false;
      }
    }
    if (!full) return false;
    
    // Check adjacent
    for (int i = 0; i < gridSize; i++) {
      for (int j = 0; j < gridSize - 1; j++) {
        if (grid[i][j] == grid[i][j + 1] || grid[j][i] == grid[j + 1][i]) return false;
      }
    }
    return true;
  }
}
