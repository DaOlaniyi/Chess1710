const stage = new Stage()   
const turns = instance.signature('Turn').atoms()  
const boardinfo = instance.field('board')  
const boarddd = turns[0].join(boardinfo)  
// const tuples = instance.field('board')  
// const boardtuples = boardinfo.  
// board1 = boardinfo.atoms()  
text = `${boarddd}`  
   
stage.add(new TextBox({   
  text: text,    
  coords: {x:300, y:300},   
  color: 'pink',   
  fontSize: 16   
}))   
   
const squareSize = 25   
turnOffset = squareSize*10  
numberofturns = turns.length  
 
stage.add(new TextBox({   
  text: numberofturns,    
  coords: {x:300, y:350},   
  color: 'pink',   
  fontSize: 16   
}))   
  
for(j = 0; j < numberofturns; j++){  
// TODO: offset boards by constant for turns, label them, and add piece values.   
    for (i=0; i < 64; i++){   
  
          
  
        x_pos_i = i % 8   
        y_pos_i = (i / 8) | 0   
        color = 'white'   
        if((x_pos_i + y_pos_i) % 2 == 0){   
            color = 'black'   
        }   
        x_pos = x_pos_i * squareSize + turnOffset*j  
        y_pos = y_pos_i * squareSize   
  
        stage.add(new Rectangle({   
        height: squareSize,   
        width: squareSize,   
        coords: {x: x_pos, y: y_pos},   
        color: color   
        }))   
  
        try{  
            pieceColor = `${turns[j].board[x_pos_i][y_pos_i].join(instance.field("color"))}`  
            pieceAtom = `${turns[j].board[x_pos_i][y_pos_i]}` 

            if(String(pieceColor).length > 0){
                if(String(pieceColor) == "Black0"){
                    stage.add(new TextBox({   
                    text: pieceAtom,    
                    coords: {x:x_pos + squareSize/2, y:y_pos + squareSize/2},   
                    color: 'purple',   
                    fontSize: 6 
                    }))   
                }else{
                    stage.add(new TextBox({   
                    text: pieceAtom,    
                    coords: {x:x_pos + squareSize/2, y:y_pos + squareSize/2},   
                    color: 'lime',   
                    fontSize: 6 
                    }))   

                }
            }else{
                pieceAtom = ""
            }
            //pieceColor = text.field('color')  
          
            
  
        }finally{}  
          
          
    }   
}  
stage.render(svg, document)