enum GameState {
  idle,      // before game starts
  playing,   // waiting for swipe
  moving,    // tiles sliding
  spawning,  // new tile appearing
  gameOver,  // no moves left
}
