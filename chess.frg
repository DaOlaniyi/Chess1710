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

// Tuple Type object for getting possible positions
// sig Position {
//     r: one Int,
//     c: one Int
// }

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

/** The piece captured during the move from turn t to turn t + 1. All subsequent turns (t + n) must not have this piece on the board */
pred piece_captured[t:Turn, p:Piece] {
    all t_subsequent: Turn | all r,c: Int {
        (reachable[t_subsequent, t, next]) => t_subsequent.board[r][c] != p
    }
}

////////// MOVEMENT //////////

// Pawns: For a pawn in turn t, there exists a row and column it was at, and a row and column +/- 1 it exists at in the next stage
/** Capturing along an offset from the previous point. Useful for pawns, knights, and kings 
    t: Current turn
    p: Capturing Piece
    r,c: Int offsets from piece position
*/
pred captures_along_offset[t:Turn, p: Piece, r_offset,c_offset:Int] {
    all r,c:Int | all p_c: Piece{ // p_c is piece to be captured
        // If the capturing piece is at location A and the capturable piece is at location A + offset, and their colors differ...
        (t.board[r][c] = p and t.board[add[r, r_offset]][add[c, c_offset]] = p_c and p.color != p_c.color) =>
            t.next.board[add[r, r_offset]][add[c, c_offset]] = p and piece_captured[t, p_c] // Move the piece to the captured piece's location and make sure the captured piece is not present in future turns.
    }

}

pred white_pawn_moves[t:Turn, p: Piece] {
    all r,c:Int | {
        // movement
        ((t.board[r][c] = p) => t.next.board[r][subtract[c,1]] = p) or captures_along_offset[t,p,1,-1] or captures_along_offset[t,p,-1,-1]
            // captures
            // (all p_other: Piece | (t.board[r][c] = p and p_other.color != p.color and t.board[subtract[r,1]][subtract[c,1]] = p_other) 
            //     implies t.board[subtract[r,1]][subtract[c,1]] = p and piece_captured[t,p_other]) or
            // (all p_other: Piece | (t.board[r][c] = p and p_other.color != p.color and t.board[add[r,1]][subtract[c,1]] = p_other) 
            //     implies t.board[add[r,1]][subtract[c,1]] = p and piece_captured[t,p_other])
    }
}

pred black_pawn_moves[t:Turn, p: Piece] {
    all r,c:Int | {
        (t.board[r][c] = p) => t.next.board[r][add[c,1]] = p
    }
}

// Rook: A rook can move to any square provided one of its indices remains the same

pred rook_moves[t: Turn, p: Piece] {
    all r,c:Int | some any:Int | {
        (t.board[r][c] = p) => t.next.board[r][any] = p or t.next.board[any][c] = p
    }
}

// Bishops: Diagonals

pred bishop_moves[t: Turn, p: Piece] {
    all r,c:Int | some any:Int | {
        (t.board[r][c] = p) => t.next.board[add[r,any]][add[c,any]] = p or t.next.board[add[r,any]][subtract[c,any]] = p
    }
}

// Queens: We basically get this one for free.

pred queen_moves[t: Turn, p: Piece] {
    all r,c:Int | some any:Int | {
        (t.board[r][c] = p) => t.next.board[add[r,any]][add[c,any]] = p or t.next.board[add[r,any]][subtract[c,any]] = p or t.next.board[r][any] = p or t.next.board[any][c] = p
    }
}

// Knights: An excersize in wondering how many different better ways of doing this there are

pred knight_moves[t: Turn, p: Piece] {
    all r,c:Int | {
        (t.board[r][c] = p) => 
                        t.next.board[add[r,1]][add[c,2]] = p or 
                        t.next.board[subtract[r,1]][add[c,2]] = p or 
                        t.next.board[add[r,1]][subtract[c,2]] = p or 
                        t.next.board[subtract[r,1]][subtract[c,2]] = p or 
                        t.next.board[add[r,2]][add[c,1]] = p or 
                        t.next.board[subtract[r,2]][add[c,1]] = p or 
                        t.next.board[add[r,2]][subtract[c,1]] = p or 
                        t.next.board[subtract[r,2]][subtract[c,1]] = p
    }
}

pred king_moves[t: Turn, p: Piece] {
    all r,c:Int | all offset_r, offset_c: Int | {
        (t.board[r][c] = p and  // I don't think this fully works yet
        offset_r > -2 and offset_r < 2 and
        offset_c > -2 and offset_c < 2) => t.next.board[add[r,offset_r]][add[c,offset_c]] = p 
    }
}

/** Get a set of possible moves for a potential piece in turn t at position [r][c] */
// fun getMoves[t: Turn, r, c: Int]: set Position{
//     (t.board[r][c] in Pawn and t.board[r][c].color in White) implies {some p:Position | p.r = r and p.c = subtract[c,1]}
//     (t.board[r][c] in Pawn and t.board[r][c].color in Black) implies {some p:Position | p.r = r and p.c = add[c,1]}

// }

/** True if a piece can move to a location
    pre fields represent idx of piece
    post fields represent after idx of piece
*/
// pred can_move[t:Turn, r_pre, c_pre, r_post, c_post:Int]{

// }

////////// TURNS //////////

/** True iff only one piece moved */
pred only_one_piece_moved[p_moved: Piece, tA, tB: Turn]{
    all p_stable : Piece | some r_stable,c_stable: Int | {
        // All stable pieces do not move between turns
        (p_stable != p_moved) implies 
            // note: This is currently overconstraining the model, as this makes it imperative that the piece is there in the next stage
            tA.board[r_stable][c_stable] = p_stable
            tA.next.board[r_stable][c_stable] = p_stable // Note: Maybe this should be tA.next
    }
    // The moved piece changed location
    // all r_moved_before, r_moved_after, c_moved_before, c_moved_after: Int | {
    //     (tA.board[r_moved_before][c_moved_before] = p_moved and (r_moved_before != r_moved_after or c_moved_before != c_moved_after)) implies
    //         tB.board[r_moved_after][c_moved_after] = p_moved
    // }
}

pred move_piece_not_pawn[t: Turn, p: Piece]{
    (p in Knight) => knight_moves[t,p]
    (p in Rook) => rook_moves[t,p]
    (p in Bishop) => bishop_moves[t,p]
    (p in Queen) => queen_moves[t,p]
    (p in King) => king_moves[t,p]
}

/** True if one black piece was moved between turn A and B

*/
pred black_turn[tA, tB: Turn] {
    some p:Piece | {
        p.color = Black
        only_one_piece_moved[p, tA, tB]
        (p in Pawn) => black_pawn_moves[tA, p]
        else move_piece_not_pawn[tA,p]
    }

}

/** True if one white piece was moved between turn A and B

*/
pred white_turn[tA, tB: Turn] {
    some p:Piece | {
        p.color = White
        only_one_piece_moved[p, tA, tB]
        (p in Pawn) => white_pawn_moves[tA, p]
        else move_piece_not_pawn[tA,p]
    }

}


////////// RUN PREDICATES //////////

// run {
//     wellformed_pieces
//     all t: Turn | wellformed_turn[t]
    
//     } for exactly 1 Turn, exactly 8 Piece

// run {
//     wellformed_pieces
//     // 
//     some disj turnA, turnB: Turn | { 
//         white_turn[turnA, turnB]
//         wellformed_turn[turnA]
//         wellformed_turn[turnB] }
//     all t: Turn | all p:Piece | some r,c: Int | t.board[r][c] = p // temp. predicate for testing move conditions. This holds true anyway until we add captures.
// } for exactly 2 Turn, exactly 4 Piece

run {
    wellformed_pieces
    // 
    some disj turnA, turnB, turnC: Turn | { 
        turnA.next = turnB
        turnB.next = turnC
        //white_turn[turnA, turnB]
        //black_turn[turnB, turnC]
        black_turn[turnA, turnB]
        white_turn[turnB, turnC]
        wellformed_turn[turnA]
        wellformed_turn[turnB] 
        wellformed_turn[turnC] 

        some disj pW,pB1,pB2,pB3: Pawn | some r,c: Int | {
            pW.color = White
            pB1.color = Black
            pB2.color = Black
            pB3.color = Black
            turnA.board[r][c] = pW
            turnA.board[r][subtract[c,1]] = pB2
            turnA.board[subtract[r,1]][subtract[c,1]] = pB1
            turnA.board[add[r,1]][subtract[c,1]] = pB3
            //piece_captured[turnB, pW2]
        }
    }
    //all t: Turn | all p:Piece | some r,c: Int | t.board[r][c] = p // temp. predicate for testing move conditions. This holds true anyway until we add captures.
} for exactly 3 Turn, exactly 4 Piece, exactly 4 Pawn

capture: run {
    wellformed_pieces
    // 
    some disj turnA, turnB, turnC: Turn | { 
        turnA.next = turnB
        turnB.next = turnC
        //white_turn[turnA, turnB]
        //black_turn[turnB, turnC]
        black_turn[turnA, turnB]
        white_turn[turnB, turnC]
        wellformed_turn[turnA]
        wellformed_turn[turnB] 
        wellformed_turn[turnC] 

        some p: Pawn |  {
            piece_captured[turnC, p]
        }
    }
    //all t: Turn | all p:Piece | some r,c: Int | t.board[r][c] = p // temp. predicate for testing move conditions. This holds true anyway until we add captures.
} for exactly 3 Turn, exactly 1 Piece, exactly 1 Pawn

// Pawn Movement Run
// run {
//     wellformed_pieces
//     // 
//     some disj turnA, turnB: Turn | { 
//         turnA.next = turnB
//         white_turn[turnA, turnB]
//         wellformed_turn[turnA]
//         wellformed_turn[turnB] 
//         all p: Pawn | {
//             white_pawn_moves[turnA,p]
//         }
//     }
//     all t: Turn | all p:Piece | some r,c: Int | t.board[r][c] = p // temp. predicate for testing move conditions. This holds true anyway until we add captures.
// } for exactly 2 Turn, exactly 1 Pawn, exactly 1 Piece


// run {
//     wellformed_pieces
//     // 
//     some disj turnA, turnB: Turn | { 
//         turnA.next = turnB
//         white_turn[turnA, turnB]
//         wellformed_turn[turnA]
//         wellformed_turn[turnB] 
//         all r: Rook | {
//             rook_moves[turnA,r]
//         }
//     }
//     all t: Turn | all p:Piece | some r,c: Int | t.board[r][c] = p // temp. predicate for testing move conditions. This holds true anyway until we add captures.
// } for exactly 2 Turn, exactly 1 Rook, exactly 1 Piece


// run {
//     wellformed_pieces
//     // 
//     some disj turnA, turnB: Turn | { 
//         turnA.next = turnB
//         white_turn[turnA, turnB]
//         wellformed_turn[turnA]
//         wellformed_turn[turnB] 
//         all b: Bishop | {
//             bishop_moves[turnA,b]
//         }
//     }
//     all t: Turn | all p:Piece | some r,c: Int | t.board[r][c] = p // temp. predicate for testing move conditions. This holds true anyway until we add captures.
// } for exactly 2 Turn, exactly 1 Bishop, exactly 1 Piece

// run {
//     wellformed_pieces
//     // 
//     some disj turnA, turnB: Turn | { 
//         turnA.next = turnB
//         white_turn[turnA, turnB]
//         wellformed_turn[turnA]
//         wellformed_turn[turnB] 
//         all q: Queen | {
//             queen_moves[turnA,q]
//         }
//     }
//     all t: Turn | all p:Piece | some r,c: Int | t.board[r][c] = p // temp. predicate for testing move conditions. This holds true anyway until we add captures.
// } for exactly 2 Turn, exactly 1 Queen, exactly 1 Piece

// run {
//     wellformed_pieces
//     // 
//     some disj turnA, turnB: Turn | { 
//         turnA.next = turnB
//         white_turn[turnA, turnB]
//         wellformed_turn[turnA]
//         wellformed_turn[turnB] 
//         all n: Knight | {
//             knight_moves[turnA,n]
//         }
//     }
//     all t: Turn | all p:Piece | some r,c: Int | t.board[r][c] = p // temp. predicate for testing move conditions. This holds true anyway until we add captures.
// } for exactly 2 Turn, exactly 1 Knight, exactly 1 Piece

// run {
//     wellformed_pieces
//     // 
//     some disj turnA, turnB: Turn | { 
//         turnA.next = turnB
//         white_turn[turnA, turnB]
//         wellformed_turn[turnA]
//         wellformed_turn[turnB] 
//         all k: Knight | {
//             king_moves[turnA,k]
//         }
//     }
//     all t: Turn | all p:Piece | some r,c: Int | t.board[r][c] = p // temp. predicate for testing move conditions. This holds true anyway until we add captures.
// } for exactly 2 Turn, exactly 1 King, exactly 1 Piece