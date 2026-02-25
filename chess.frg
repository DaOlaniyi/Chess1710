#lang forge
// /froglet

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

sig Position {
    r: one Int,
    c: one Int
}

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

////////// MOVEMENT //////////

/** Get a set of possible moves for the piece in turn t at position [r][c] */
fun getMoves[t: Turn, r, c: Int]: set Int{


}

/** True if a piece can move to a location
    pre fields represent idx of piece
    post fields represent after idx of piece
*/
pred can_move[t:Turn, r_pre, c_pre, r_post, c_post:Int]{

}

////////// TURNS //////////

/** True iff only one piece moved */
pred only_one_piece_moved[p_moved: Piece, tA, tB: Turn]{
    all p_stable : Piece | some r_stable,c_stable: Int | {
        // All stable pieces do not move between turns
        (p_stable != p_moved) implies 
            tA.board[r_stable][c_stable] = p_stable
            tA.next.board[r_stable][c_stable] = p_stable // Note: Maybe this should be tA.next
    }
    // The moved piece changed location
    // all r_moved_before, r_moved_after, c_moved_before, c_moved_after: Int | {
    //     (tA.board[r_moved_before][c_moved_before] = p_moved and (r_moved_before != r_moved_after or c_moved_before != c_moved_after)) implies
    //         tB.board[r_moved_after][c_moved_after] = p_moved
    // }
}

/** True if one black piece was moved between turn A and B

*/
pred black_turn[tA, tB: Turn] {
    some p:Piece | {
        p.color = Black
        only_one_piece_moved[p, tA, tB]
    }

}

/** True if one white piece was moved between turn A and B

*/
pred white_turn[tA, tB: Turn] {
    some p:Piece | {
        p.color = White
        only_one_piece_moved[p, tA, tB]
    }

}


////////// RUN PREDICATES //////////

// run {
//     wellformed_pieces
//     all t: Turn | wellformed_turn[t]
    
//     } for exactly 1 Turn, exactly 8 Piece

run {
    wellformed_pieces
    // 
    some disj turnA, turnB: Turn | { 
        white_turn[turnA, turnB]
        wellformed_turn[turnA]
        wellformed_turn[turnB] }
    all t: Turn | all p:Piece | some r,c: Int | t.board[r][c] = p // temp. predicate for testing move conditions. This holds true anyway until we add captures.
} for exactly 2 Turn, exactly 4 Piece
