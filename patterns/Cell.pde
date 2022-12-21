public enum CellType {
  BLANK, RECT, FILL, LINES;
  public static CellType getRandom() {
    return values()[(int) (Math.random() * values().length)];
  }
}

class Cell {
  float cellWidth;
  CellType type;

  Cell(float cellWidth) {
    this.cellWidth = cellWidth;
    this.type = CellType.getRandom();
  }

  void display() {
    switch(type) {
    case RECT:
      stroke(300);
      noFill();
      rect(0, 0, cellWidth, cellWidth);
      break;

    case FILL:
      noStroke();
      fill(random(200, 300));
      rect(0, 0, cellWidth, cellWidth);
      break;

    case LINES:
      /*stroke(0);
      noFill();
      circle(cellWidth/2, cellWidth/2, cellWidth);*/

      int spacing = int(random(4,cellWidth/4));
      float slope = float(nf(random(-3f,3f),0,1).replace(",","."));

      /*fill(0);
      stroke(0);
      text(""+slope, 0,0);*/

      noStroke();
      fill(0);
      for (float y = 0; y < cellWidth; y+=0.5) {
        for (float x = 0; x < cellWidth; x+=0.5) {
          if((y - slope*x)%spacing == 0f) {
            circle(x,y,1);
          }
        }
      }

    default:
      break;
    }
  }
}
