# Chess1710

### Project Objective: What are you trying to model? 
For our Midterm, we're modeling chess! Specifically piece movement, check, and checkmate. We're ignoring the extra stuff like castling, en passant, and promotion.  We just focused on how pieces move, when a king is in check, and when it's actually checkmate. 

### Model Design and Visualization: 

*Give an overview of your model design choices, what checks or run statements you wrote, and what we should expect to see from an instance produced by the Sterling visualizer. How should we look at and interpret an instance created by your spec? Did you create a custom visualization, or did you use the default?*

We used a `Turn` sig with a `board` partial function mapping (row, col) -> Piece to represent board states. In this system, turns are linked via `next` to form a chain. We also wrote run statements in check.frg to find checkmate positions; when you run `chess.frg` or `check.frg` you will see Sterling graph with Turn nodes pointing to Piece nodes, with board positions labeled like `board[2,6]`. 

Our repo also has custom visualization `board_viz.js` that renders each turn as an 8x8 chessboard side by side!

### Signatures and Predicates: 
*At a high level, what do each of your sigs and preds represent in the context of the model? Justify the purpose for their existence and how they fit together.*
1) `Color`, `Black`, `White`: two colors for the 2 players in chess
2) `Piece` and its subtypes (`Pawn`, `Knight`, `Rook`, `Bishop`, `Queen`, `King`): each unique type of piece
3) `Turn`: represents the board state. Has a `board` pfunc and a `next` pointer 
  to chain turns together
4) `wellformed_pieces`: our pred for making sure no piece is in two places at once
5)  `wellformed_turn`: keeps pieces inside the 8x8 grid and prevents turn cycles
6)  Movement preds (`white_pawn_moves`, `rook_moves`, etc.): are what define legal movement in our system for each piece type between turns
7) `white_turn`/`black_turn`: defines that exactly one piece of the right color 
  moved
8) `in_check`: only to be true if some enemy piece is threatening the king right now
9) `is_checkmate`: for when (of course) king is in check AND has no escape squares (we check every square the king could step to and verify it's either blocked or attacked)

### Testing: 
*What tests did you write to test your model itself? What tests did you write to verify properties about your domain area? Feel free to give a high-level overview of this.*

We wrote tests in test.frg covering both files. For check.frg we tested that a rook on the same row triggers check, that a queen on a diagonal triggers check, that a knight in an L-shape triggers check, and that a king with zero enemies on the board is never in check. For chess.frg we tested that wellformed_pieces rejects a piece on two squares, that pieces outside the 8x8 grid fail wellformed_turn, that white/black pawns move in the right direction, and that a rook can't teleport diagonally. As of this writing, we have about 8 tests total.

### Documentation: 
*Make sure your model and test files are well-documented. This will help in understanding the structure and logic of your project.*
We kept comments throughout the repo files.