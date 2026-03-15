enum GameState {
  idle,      // before game starts
  playing,   // waiting for swipe
  moving,    // tiles sliding
  addingTile,  // new tile appearing
  gameOver,  // no moves left
}
