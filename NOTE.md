| game_model.dart  ✅           |      game_screen.dart  ✅ |  tile_data.dart ✅ |
| ----------------------------- | ------------------------- | ----------------- |
|getTiles()    |                    _handleSwipe()  ← stays here | TileData class |
| moveLeft()  |_showGameOverDialog() | getTileColor() |
| moveRight()     |      _showWelcomeDialog()            |   | 
| moveUp()   |              build()            |  |
| moveDown()  | |        |                
| saveBestScore() | | |
| loadBestScore() | | |
| gameOver | | |

//-------------------- GAME LIFECYCLE -----------------------------

swipe →  [moving]   → tiles slide → wait 150ms
                    → didMerge? → 💥 merge sound
       →  [spawning] → new tile appears
                    → hit 2048? → 🏆 win sound
                    → wait 150ms
       →  [gameOver]? → 💀 gameover sound → dialog
       →  [playing]  → ready for next swipe


//-------------------- ANIMATION TWEAK -----------------------------

There are just 3 things you can tweak in your current animation code to change how it feels:

1. Speed — duration
This controls how long the slide takes:

```dart
duration: const Duration(milliseconds: 150), // faster = snappier
duration: const Duration(milliseconds: 300), // slower = smoother
duration: const Duration(milliseconds: 500), // very slow (good for testing)
```
👉 Try 500 first so you can clearly see the animation, then bring it back down.

2. Style — curve
This controls the shape of the movement — does it start fast? slow down at the end? bounce?

```dart
curve: Curves.easeInOut,   // smooth start and end (default feel)
curve: Curves.easeOut,     // fast start, slows at destination
curve: Curves.bounceOut,   // bounces when it arrives 🏀
curve: Curves.elasticOut,  // overshoots then snaps back 🎯
curve: Curves.linear,      // constant speed, robotic feel
curve: Curves.decelerate,  // rushes in, gently stops
```
Think of it like a car — easeOut is like braking smoothly, bounceOut is like hitting a wall and bouncing. Just swap the word after Curves. and hot reload to see the difference instantly.

3. New tile pop-in — ScaleTransition
You can also make new tiles grow into place instead of just appearing. In your itemBuilder for new tiles, wrap the tile with:

```dart
AnimatedScale(
  scale: 1.0,
  duration: const Duration(milliseconds: 200),
  curve: Curves.elasticOut,
  child: yourTileWidget,
)
```
Quick Experiment Idea 🧪
Set these values and swipe — you'll see the animation very clearly:

dart
duration: const Duration(milliseconds: 600),
curve: Curves.bounceOut,
Then once you find a feel you like, bring duration back down to around 150–200ms for a snappy game feel. That's exactly how real game developers tune animations — just play until it feels right!