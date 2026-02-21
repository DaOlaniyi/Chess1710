#lang forge/froglet

option run_sterling "board_viz.js"

////////// GENERAL IDEAS //////////

// We're going to ignore most of the higher-level rules of chess (i.e. castling, en passant, promotion, etc.)
// We're just going to focus on general piece dynamics, captures, check, and checkmate.

////////// SIGNATURES //////////

abstract sig Color {}
one sig Black, White extends Color {}

abstract sig Piece {
    color: one Color
}

sig Pawn, Knight, Rook, Bishop, Queen, King extends Piece {}

sig Turn {
    // Row-major order
    board: pfunc Int -> Int -> Piece,
    next: lone Turn
}

////////// WELLFORMED PREDICATES //////////

/** */
pred wellformed_pieces {
    // Note: Pieces do not __need__ to have a corresponding pfunc pointing to them, as this signifies captures
    all t:Turn | all p:Piece | all r,r_other: Int | all c,c_other: Int | {
        (t.board[r][c] = p and !(r = r_other and c = c_other)) implies !t.board[r_other][c_other] = p
    }

    // all t:Turn | all p:Piece | all r,r_other: Int | all disj c,c_other: Int | {
    //     t.board[r][c] = p implies !t.board[r_other][c_other] = p
    // }
}

pred wellformed_turn[t: Turn] {
    !reachable[t,t,next]
    all r,c: Int | {
        (r > 7 or r < 0 or c > 7 or c < 0) 
            implies no t.board[r][c]
    }
}

run {
    wellformed_pieces
    all t: Turn | wellformed_turn[t]
    
    } for exactly 1 Turn, exactly 8 Piece
