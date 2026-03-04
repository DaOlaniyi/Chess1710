#lang forge/froglet

open "chess.frg"
open "check.frg"

//a king with an enemy rook on the same row should be in check
test expect {
    rook_gives_check: {
       some t: Turn | some r: Rook | some rk: King | {
  wellformed_turn[t]
  r.color = White
  rk.color = Black

  some row, c1, c2: Int | {
    c1 != c2
    t.board[row][c1] = r
    t.board[row][c2] = rk
  }

  in_check[t, rk]
}
    } is sat
}

// a king with no opponents on the board should never be in check
test expect {
    no_enemies_no_check: {
        some t: Turn | some k: King | {
            wellformed_turn[t]
            k.color = Black
            all p: Piece | p.color = White => {
                all r, c: Int | t.board[r][c] != p
            }
            in_check[t, k]
        }
    } is unsat
}

// A queen on the same diagonal as a king should give check
test expect {
    queen_diagonal_check: {
        some t: Turn | some q: Queen | some k: King | {
            wellformed_turn[t]
            q.color = White
            k.color = Black
            some r1, c1, d: Int | {
                d != 0
                t.board[r1][c1] = q
                t.board[add[r1,d]][add[c1,d]] = k
            }
            in_check[t, k]
        }
    } is sat
}

// A knight delivering check should be detectable
test expect {
    knight_gives_check: {
        some t: Turn | some n: Knight | some k: King | {
            wellformed_turn[t]
            n.color = White
            k.color = Black
            some r, c: Int | {
                t.board[r][c] = n
                t.board[add[r,2]][add[c,1]] = k
            }
            in_check[t, k]
        }
    } is sat
}

////////// TESTS FOR CHESS.FRG //////////

// A board with the same piece on two squares at once should be malformed
test expect {
    piece_cant_be_in_two_places: {
        some t: Turn | some p: Piece | some r1, c1, r2, c2: Int | {
            not (r1 = r2 and c1 = c2)
            t.board[r1][c1] = p
        t.board[r2][c2] = p
            wellformed_pieces
        }
    } is unsat
}

// A piece outside the 8x8 grid should violate wellformed_turn
test expect {
    piece_out_of_bounds: {
        some t: Turn | some p: Piece | {
            t.board[9][0] = p   // row 9 is out of bounds
            wellformed_turn[t]
        }
    } is unsat
}

// A white pawn should move forward (decreasing column) each turn
test expect {
    white_pawn_moves_forward: {
        some t: Turn | some p: Piece | some r, c: Int | {
            p in Pawn
            p.color = White
            t.board[r][c] = p
             wellformed_turn[t]
            white_pawn_moves[t, p]
            t.next.board[r][subtract[c,1]] = p  // should be here next turn
        }
    } is sat
}

//A black pawn should move forward (increasing column) each turn
test expect {
    black_pawn_moves_forward: {
        some t: Turn | some p: Piece | some r, c: Int | {
            p in Pawn
            p.color = Black
            t.board[r][c] = p
            wellformed_turn[t]
            black_pawn_moves[t, p]
            t.next.board[r][add[c,1]] = p  // should be here next turn
        }
    } is sat
}

// a rook cannot teleport to a completely unrelated square (different row AND column)
test expect {
    rook_cant_move_diagonally: {
        some t: Turn | some p: Piece | some r, c: Int | {
            p in Rook
            p.color = White
            t.board[r][c] = p
             wellformed_turn[t]
            rook_moves[t, p]
            //check position and ensure the rows and columns are diff 
            t.next.board[add[r,2]][add[c,2]] = p
             not (t.next.board[r][add[c,2]] = p) 
            not (t.next.board[add[r,2]][c] = p) 
        }
    } is unsat
}