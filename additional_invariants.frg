#lang forge/froglet

open "chess.frg"

pred max_king_count { 
    #(King) = 2
}

pred single_move {
    //For all distinct pairs of turns, at most one square differs
    all disj t1, t2: Turn |
    all r1, c1: Int |
        (some t1.board[r1][c1] or some t2.board[r1][c1]) =>
        (t1.board[r1][c1] != t2.board[r1][c1]) =>
        (all r2, c2: Int |
            (some t1.board[r2][c2] or some t2.board[r2][c2]) =>
            (t1.board[r2][c2] != t2.board[r2][c2]) =>
            (r2 = r1 and c2 = c1))
}

pred linear_turns {
    //No two distinct turns point to the same next turn (tree becomes a line)
    all disj t1, t2: Turn |
        t1.next = t2 =>
        (all t3: Turn | (t3.next = t2) => (t1 = t3))
}

// each color has exactly one king.
// max_king_count ensures #King = 2, but doesn't prevent both being
//. the same color. This closes that gap.
pred one_king_per_color {
    one k: King | k.color = White
    one k: King | k.color = Black
}

//all pieces on any board are always within the 8x8 bounds.
// (our wellformed_turn enforces this already, however, but only when explicitly invoked)
pred pieces_always_in_bounds {
    all t: Turn | all r, c: Int | {
        some t.board[r][c] =>
            r >= 0 and r <= 7 and c >= 0 and c <= 7
    }
}

// no two pieces ever occupy the same square on the same turn.
// mirrors wellformed_pieces
pred no_two_pieces_same_square {
    all t: Turn | all r, c: Int | all disj p1, p2: Piece | {
        t.board[r][c] = p1 => t.board[r][c] != p2
    }
}

// captured pieces never return to the board.
pred captured_pieces_stay_captured {
    all t: Turn | all p: Piece | {
        (all r, c: Int | t.board[r][c] != p) =>
            (all t2: Turn | reachable[t2, t, next] =>
                (all r2, c2: Int | t2.board[r2][c2] != p))
    }
}

// The two kings are never on adjacent squares.
pred kings_never_adjacent {
    all t: Turn | all disj k1, k2: King | all r1, c1, r2, c2: Int | {
        (t.board[r1][c1] = k1 and t.board[r2][c2] = k2) =>
            not (
                (r2 = add[r1, 1] or r2 = subtract[r1, 1] or r2 = r1) and
                (c2 = add[c1, 1] or c2 = subtract[c1, 1] or c2 = c1) and
                not (r2 = r1 and c2 = c1)
            )
    }
}


// run { wellformed_pieces  
//       one_king_per_color 
// } for 1 Turn, 2 Piece, 4 Int

// run { wellformed_pieces
//       pieces_always_in_bounds
// } for 1 Turn, 2 Piece, 4 Int

// run { wellformed_pieces
//       no_two_pieces_same_square
// } for 1 Turn, 2 Piece, 4 Int

// run { wellformed_pieces
//       all t: Turn | wellformed_turn[t]
//       kings_never_adjacent
// } for 2 Turn, 2 Piece, 4 Int

// run { wellformed_pieces
//       all t: Turn | wellformed_turn[t]
//       captured_pieces_stay_captured
// } for 2 Turn, 2 Piece, 4 Int