#lang forge/froglet

open "chess.frg"

test suite for wellformed_turn {
    example two_piece is {some t:Turn | wellformed_turn[t]} for {
        Turn = `t
        Piece = `r + `k
        Rook = `r
        Knight = `k
        `t.board = (1,1) -> `r + (1,2) -> `k
    }

    example two_piece_one_captured is {some t:Turn | wellformed_turn[t]} for {
        Turn = `t
        Piece = `r + `k
        Rook = `r
        Knight = `k
        `t.board = (1,1) -> `r
    }

    example two_piece_not_bijection is {some t:Turn | not wellformed_turn[t]} for {
        Turn = `t
        Piece = `r + `k
        Rook = `r
        Knight = `k
        `t.board = (1,1) -> `r + (1,2) -> `k + (1,3) -> `r + (2,1) -> `r
    }
}