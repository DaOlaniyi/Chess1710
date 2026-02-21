const stage = new Stage()
const turn = instance.signature('Turn').atoms()[0]
const boardinfo = instance.field('board')
stage.add(new TextBox({
  text: `${turn.join(boardinfo)}`, 
  coords: {x:300, y:300},
  color: 'pink',
  fontSize: 16
}))

const squareSize = 25


// TODO: offset boards by constant for turns, label them, and add piece values.
for (i=0; i < 64; i++){
    x_pos = i % 8
    y_pos = (i / 8) | 0
    color = 'white'
    if((x_pos + y_pos) % 2 == 0){
        color = 'black'
    }
    x_pos *= squareSize
    y_pos *= squareSize
    
    stage.add(new Rectangle({
    height: squareSize,
    width: squareSize,
    coords: {x: x_pos, y: y_pos},
    color: color
}))
}
stage.render(svg, document)