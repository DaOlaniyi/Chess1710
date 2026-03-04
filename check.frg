#lang forge/froglet
open "chess.frg"

////////// ATTACK PREDS //////////

pred is_pawn_check[t: Turn, p: Piece, k: Piece, r, c: Int] {
    // White moves toward subtract[c,1], so attacks diagonally that direction
    (p.color =  White)   => 
    {
        t.board[add[r,1]][subtract[c,1]] = k or
        t.board[subtract[r,1]][subtract[c,1]] = k
    } else 
    
    {
        // Black moves toward add[c,1], attacks diagonally that direction
        t.board[add[r,1]][add[c,1]] = k or
        t.board[subtract[r,1]][add[c,1]] = k
    }
}

pred is_knight_check[t: Turn, p: Piece, k: Piece, r, c: Int] {
    t.board[add[r,1]][add[c,2]]  = k or
    t.board[subtract[r,1]][add[c,2]] = k or
    t.board[add[r,1]][subtract[c,2]]  = k or
    t.board[subtract[r,1]][subtract[c,2]] = k or

    t.board[add[r,2]][add[c,1]] = k or
    t.board[subtract[r,2]][add[c,1]]  = k or
    t.board[add[r,2]][subtract[c,1]]  = k or
    t.board[subtract[r,2]][subtract[c,1]] = k
}

pred is_rook_check[t: Turn, p: Piece, k: Piece, r, c: Int] {
    some kr, kc: Int | {

        t.board[kr][kc] = k
        (kr = r or kc = c)
    }
}

pred is_bishop_check[t: Turn, p: Piece, k: Piece, r, c: Int] {
    some kr, kc, d: Int | {

        t.board[kr][kc] = k

        (kr = add[r,d] or kr = subtract[r,d])//check p. example
        
        (kc =  add[c,d] or kc = subtract[c,d])
    }
}

pred is_queen_check[t: Turn, p: Piece, k: Piece, r, c: Int] {
    is_rook_check[t, p,  k, r, c] or
    is_bishop_check[t, p, k, r, c]
}

////////// CHECK //////////

pred in_check[t: Turn, k: King] {
    some r, c: Int | some p: Piece | {
        t.board[r][c] = p
        p.color != k.color
        (p in Pawn)  => is_pawn_check[t, p, k, r, c]
        (p in Knight) => is_knight_check[t, p, k, r, c]
      (p in Rook)   => is_rook_check[t, p, k, r, c]
        (p in Bishop) => is_bishop_check[t, p, k, r, c]
        (p in Queen)  =>  is_queen_check[t, p, k, r, c]
    }
}

////////// CHECKMATE //////////

// true if square (nr,nc) is attacked by any enemy of friendly_col in turn t
pred square_attacked[t: Turn, nr, nc: Int, friendly_col: Color] {
    some pr, pc: Int | some p: Piece | {
        t.board[pr][pc] = p
        p.color != friendly_col
        (p in Pawn and p.color = White) => {
            (nr = add[pr,1] and nc = subtract[pc,1]) or
            (nr = subtract[pr,1] and nc = subtract[pc,1])
        }
        (p in Pawn and p.color = Black) => {
            (nr = add[pr,1] and nc = add[pc,1]) or
            (nr = subtract[pr,1] and nc = add[pc,1])
        }
        (p in Knight) => {
            (nr = add[pr,1] and nc = add[pc,2])      or
            (nr = subtract[pr,1] and nc = add[pc,2])      or
            (nr = add[pr,1] and nc = subtract[pc,2]) or
            (nr = subtract[pr,1] and nc = subtract[pc,2]) or
            (nr = add[pr,2] and nc = add[pc,1])      or
            (nr = subtract[pr,2] and nc = add[pc,1])      or
            (nr = add[pr,2] and nc = subtract[pc,1]) or
            (nr = subtract[pr,2] and nc = subtract[pc,1])
        }
        (p in Rook)   => { nr = pr or nc = pc }
        (p in Bishop) => { some d: Int | {
            (nr = add[pr,d] or nr = subtract[pr,d]) and
            (nc = add[pc,d] or nc = subtract[pc,d])
        }}
        (p in Queen)  => {
            (nr = pr or nc = pc) or
            {some d: Int | {
                (nr = add[pr,d] or nr = subtract[pr,d]) and
                (nc = add[pc,d] or nc = subtract[pc,d])
            }}
        }
        (p in King)   => {
            (nr = add[pr,1] or nr = pr or nr = subtract[pr,1]) and
            (nc = add[pc,1] or nc = pc or nc = subtract[pc,1]) and
            not (nr = pr and nc = pc)
        }
    }
}

// King has no escape: every square it could  step to is either blocked by a friendly or already attacked by an opponnent
pred king_has_no_escape[t: Turn, k: King] {
    some kr, kc: Int | t.board[kr][kc] = k and {
        all nr,  nc: Int | {

            nr >= 0  and nr <= 7 and
            nc >= 0 and nc <= 7 and
            
            not (nr = kr and nc = kc) and
             (nr = add[kr,1] or nr = kr or nr = subtract[kr,1]) and
            (nc = add[kc,1] or nc = kc or nc = subtract[kc,1])
        } => {
            // Blocked by own piece OR attacked by enemy
            (some t.board[nr][nc] and t.board[nr][nc].color = k.color)
            or
            square_attacked[t, nr, nc, k.color]
        }
    }
}

// Checkmate: king is in check AND has no escape square
pred is_checkmate[t: Turn, col: Color] {
    some k: King | {
        k.color = col
        in_check[t, k]
        king_has_no_escape[t, k]
    }
}

////////// examples //////////

//ex 1: BASic checkmate
pred checkmate_black {
    some t: Turn | {
        wellformed_pieces
        wellformed_turn[t]
        is_checkmate[t, Black]
    }
}

// run checkmate_black for 1 Turn, 4 Piece, 4 Int


// exx 2: White is the one getting checkmate
pred checkmate_white {
    some t: Turn | {
        wellformed_pieces
        wellformed_turn[t]
        is_checkmate[t, White]
    }
}
// run checkmate_white for 1 Turn, 4 Piece, 4 Int

// ex 3: non-mate Check (k has an escape)
pred check_not_checkmate {
    some t: Turn | some k: King | {
        wellformed_pieces
        wellformed_turn[t]
        k.color = Black
        in_check[t, k]
        not is_checkmate[t, Black]
    }
}
// run check_not_checkmate for 1 Turn, 4 Piece, 4 Int