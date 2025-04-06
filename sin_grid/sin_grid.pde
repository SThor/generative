import nice.palettes.*;
import yash.oklab.*;

int rows, columns;
float cellHeight, cellWidth, minValue;
float topMargin, sideMargin;
float offsetX, offsetY;

void settings() {
  size(800, 800, P2D);

}

void setup() {
  Ok.p = this;
  noStroke();
  rectMode(CENTER);

  rows = 6;
  columns = 4;
}

void draw() {
  // compute cell & margins size
  cellWidth = width / (columns+2);
  cellHeight = height / (rows+2);

  minValue = min(cellWidth, cellHeight);
  cellWidth = minValue;
  cellHeight = minValue;

  topMargin = (height - (rows*cellHeight))/2;
  sideMargin = (width - (columns*cellWidth))/2;

  background(Ok.HSL(240, 50, 5));
  translate(sideMargin, topMargin);
  for (int r = 0; r < rows; ++r) {
    for (int c = 0; c < columns; ++c) {
      cell(c*cellWidth, r*cellHeight);      
    }
  }
}

void cell(float x, float y) {
  pushMatrix();
  translate(x + cellWidth/2, y + cellHeight/2);
  //rect(0, 0, cellWidth-5, cellHeight-5);
  offsetX = random(-3,3);
  offsetY = random(-3,3);

  for (int i = 0; i < 50; ++i) {
    translate(offsetX,offsetY);
    scale(0.95);
    fill(Ok.HSL(240, 50, map(i, 0, 50, 5, 100)));
    //rect(0, 0, cellWidth-20, cellHeight-20);
    circle(0, 0,cellHeight-20);
  }

  popMatrix();
}

void mouseClicked() {
  save(year()+"-"+month()+"-"+day()+"_"+year()+"-"+hour()+"-"+minute()+"-"+second()+"-"+".png");
}
