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

    example turn_two_piece_not_bijection is {some t:Turn | not wellformed_turn[t]} for {
        Turn = `t
        Piece = `r + `k
        Rook = `r
        Knight = `k
        `t.board = (1,1) -> `r + (1,2) -> `k + (1,3) -> `r + (2,1) -> `r
    }

    // todo, neg indices
}

test suite for wellformed_pieces {
    example piece_bijection is {wellformed_pieces} for {
        Turn = `t
        Piece = `r + `k
        Rook = `r
        Knight = `k
        `t.board = (1,1) -> `r + (1,2) -> `k
    }

    example pieces_post_capture is {some t:Turn | wellformed_pieces and wellformed_turn[t]} for {
        Turn = `t
        Piece = `r + `k
        Rook = `r
        Knight = `k
    }

    example two_piece_not_bijection is {not wellformed_pieces} for {
        Turn = `t
        Piece = `r + `k
        Rook = `r
        Knight = `k
        `t.board = (1,1) -> `r + (1,2) -> `k + (1,3) -> `r + (2,1) -> `r
    }
    
}

test suite for piece_captured {
    example rook_captures_knight is {some disj turnA, turnB:Turn | some k: Piece | piece_captured[turnA, k] and wellformed_turn[turnA] and wellformed_turn[turnB] and wellformed_pieces} for {
        Turn = `turnA + `turnB
        `turnA.next = `turnB
        Piece = `r + `k
        Rook = `r
        Knight = `k

        `turnA.board = (1,1) -> `r + (2,1) -> `k
        `turnB.board = (2,1) -> `r
    }

    example rook_captures_knight_illegal_move is {some disj turnA, turnB:Turn | some k: Piece | not piece_captured[turnA, k] and wellformed_turn[turnA] and wellformed_turn[turnB] and wellformed_pieces} for {
        Turn = `turnA + `turnB
        `turnA.next = `turnB
        Piece = `r + `k
        Rook = `r
        Knight = `k

        `turnA.board = (1,1) -> `r + (2,2) -> `k
        `turnB.board = (2,2) -> `r
    }

    example rook_captures_knight_but_knight_reappears is {some disj turnA, turnB, turnC:Turn | some k: Piece | not piece_captured[turnA, k] and wellformed_turn[turnA] and wellformed_turn[turnB] and wellformed_turn[turnC] and wellformed_pieces} for {
        Turn = `turnA + `turnB + `turnC
        `turnA.next = `turnB
        `turnB.next = `turnC
        Piece = `r + `k
        Rook = `r
        Knight = `k

        `turnA.board = (1,1) -> `r + (2,1) -> `k
        `turnB.board = (2,1) -> `r
        `turnC.board = (2,1) -> `r + (3,7) -> `k
    }
}

test suite for white_pawn_moves {
    example white_pawn_moves_wellformed is {some disj turnA, turnB:Turn | some p: Piece | wellformed_turn[turnA] and wellformed_turn[turnB] and wellformed_pieces and white_pawn_moves[turnA, p]} for {
        Turn = `turnA + `turnB
        `turnA.next = `turnB
        Piece = `p
        Pawn = `p
        Color = `white + `black
        White = `white
        Black = `black
        `p.color = `white
        `turnA.board = (1,3) -> `p
        `turnB.board = (1,2) -> `p
    }

    example white_pawn_captures is {some disj turnA, turnB:Turn | some disj p, p_o: Piece | wellformed_turn[turnA] and wellformed_turn[turnB] and wellformed_pieces and white_pawn_moves[turnA, p]} for {
        Turn = `turnA + `turnB
        `turnA.next = `turnB
        Piece = `p + `p_o
        Pawn = `p + `p_o
        Color = `white + `black
        White = `white
        Black = `black

        `p.color = `white
        `p_o.color = `black
        `turnA.board = (1,3) -> `p + (2,2) -> `p_o

        `turnB.board = (2,2) -> `p
    }
}

test suite for black_pawn_moves {
    example black_pawn_moves_wellformed is {some disj turnA, turnB:Turn | some p: Piece | wellformed_turn[turnA] and wellformed_turn[turnB] and wellformed_pieces and black_pawn_moves[turnA, p]} for {
        Turn = `turnA + `turnB
        `turnA.next = `turnB
        Piece = `p
        Pawn = `p
        Color = `white + `black
        White = `white
        Black = `black
        `p.color = `black
        `turnA.board = (1,2) -> `p
        `turnB.board = (1,3) -> `p
    }

    example black_pawn_captures is {some disj turnA, turnB:Turn | some disj p, p_o: Piece | wellformed_turn[turnA] and wellformed_turn[turnB] and wellformed_pieces and black_pawn_moves[turnA, p]} for {
        Turn = `turnA + `turnB
        `turnA.next = `turnB
        Piece = `p + `p_o
        Pawn = `p + `p_o
        Color = `white+ `black
        White = `white
        Black = `black

        `p.color = `black
        `p_o.color = `white
        `turnA.board = (2,2) -> `p + (1,3) -> `p_o

        `turnB.board = (1,3) -> `p
    }

    example black_pawn_captures_but_teleports is {some disj turnA, turnB:Turn | some disj p, p_o: Piece | wellformed_turn[turnA] and wellformed_turn[turnB] and wellformed_pieces and not black_pawn_moves[turnA, p]} for {
        Turn = `turnA + `turnB
        `turnA.next = `turnB
        Piece = `p + `p_o
        Pawn = `p + `p_o
        Color = `white+ `black
        White = `white
        Black = `black

        `p.color = `black
        `p_o.color = `white
        `turnA.board = (2,2) -> `p + (1,3) -> `p_o

        `turnB.board = (7,5) -> `p
    }
}

test suite for white_turn {
    example white_pawn_moves_wellformed_white_turn is {some disj turnA, turnB:Turn | some p: Piece | wellformed_turn[turnA] and wellformed_turn[turnB] and wellformed_pieces and white_pawn_moves[turnA, p] and white_turn[turnA, turnB]} for {
        Turn = `turnA + `turnB
        `turnA.next = `turnB
        Piece = `p
        Pawn = `p
        Color = `white + `black
        White = `white
        Black = `black
        `p.color = `white
        `turnA.board = (1,3) -> `p
        `turnB.board = (1,2) -> `p
    }

    example black_pawn_moves_wellformed_white_turn is {some disj turnA, turnB:Turn | some p: Piece | wellformed_turn[turnA] and wellformed_turn[turnB] and wellformed_pieces and white_pawn_moves[turnA, p] and not white_turn[turnA, turnB]} for {
        Turn = `turnA + `turnB
        `turnA.next = `turnB
        Piece = `p
        Pawn = `p
        Color = `white + `black
        White = `white
        Black = `black
        `p.color = `black
        `turnA.board = (1,2) -> `p
        `turnB.board = (1,3) -> `p
    }
}

test suite for black_turn {
    example black_pawn_moves_wellformed_black_turn is {some disj turnA, turnB:Turn | some p: Piece | wellformed_turn[turnA] and wellformed_turn[turnB] and wellformed_pieces and white_pawn_moves[turnA, p] and black_turn[turnA, turnB]} for {
        Turn = `turnA + `turnB
        `turnA.next = `turnB
        Piece = `p
        Pawn = `p
        Color = `white + `black
        White = `white
        Black = `black
        `p.color = `black
        `turnA.board = (1,2) -> `p
        `turnB.board = (1,3) -> `p
    }

    example white_pawn_moves_wellformed_black_turn is {some disj turnA, turnB:Turn | some p: Piece | wellformed_turn[turnA] and wellformed_turn[turnB] and wellformed_pieces and white_pawn_moves[turnA, p] and not black_turn[turnA, turnB]} for {
        Turn = `turnA + `turnB
        `turnA.next = `turnB
        Piece = `p
        Pawn = `p
        Color = `white + `black
        White = `white
        Black = `black
        `p.color = `white
        `turnA.board = (1,3) -> `p
        `turnB.board = (1,2) -> `p
    }
}