import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class patterns extends PApplet {

int gridWidth, gridHeight;
float cellWidth;
float topMargin, leftMargin;
float spacing;

Cell[] cells;

public void paper() {
  noStroke();
  for (int i = 0; i < 100000; ++i) {
    fill(random(360), random(100), random(100), random(30));
    float x = random(width);
    float y = random(height);
    circle(x, y, random(2));
  }	
  loadPixels();
  for ( int i=0; i<pixels.length; i+=1) {
    pixels[i] = lerpColor(pixels[i], color(360), random(.5f));
  }
  updatePixels();
}

public void settings() {
  size(1050, 1300, P2D);
  smooth(8);
  gridWidth = 4;
  gridHeight = 5;
  spacing = height/50;
  cellWidth = min(width, height)/5;

  cells = new Cell[gridHeight*gridWidth];

  topMargin = (height - (gridHeight*(cellWidth+spacing)-spacing))/2;
  leftMargin = (width - (gridWidth*(cellWidth+spacing)-spacing))/2;
}

public void setup() {
  colorMode(HSB, 360, 100, 100, 100);
  background(350,100);
  stroke(0);

  translate(leftMargin, topMargin);
  for (int y = 0; y < gridHeight; ++y) {
    for (int x = 0; x < gridWidth; ++x) {
      cells[y*gridWidth+x] = new Cell(cellWidth);
      cells[y*gridWidth+x].display();
      /*fill(y*100);
      rect(0,0,cellWidth,cellWidth);*/
      translate(cellWidth+spacing, 0);
    }
    translate(-gridWidth*(cellWidth+spacing), cellWidth+spacing);
  }
  translate(0, -gridHeight*(cellWidth+spacing));
  translate(-leftMargin, -topMargin);
  //paper();
}

public void mouseReleased() {
	background(350,100);
	stroke(0);

	cells = new Cell[gridHeight*gridWidth];
	translate(leftMargin, topMargin);
	for (int i = 0; i < gridHeight; ++i) {
		for (int j = 0; j < gridWidth; ++j) {
			cells[i*gridWidth+j] = new Cell(cellWidth);
			cells[i*gridWidth+j].display();
			translate(cellWidth+spacing, 0);
		}
		translate(-gridWidth*(cellWidth+spacing), cellWidth+spacing);
	}
	translate(0, -gridHeight*(cellWidth+spacing));
	translate(-leftMargin, -topMargin);
	paper();
}

public void draw() {
}
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

  public void display() {
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

      int spacing = PApplet.parseInt(random(4,cellWidth/4));
      float slope = PApplet.parseFloat(nf(random(-3f,3f),0,1).replace(",","."));

      /*fill(0);
      stroke(0);
      text(""+slope, 0,0);*/

      noStroke();
      fill(0);
      for (float y = 0; y < cellWidth; y+=0.5f) {
        for (float x = 0; x < cellWidth; x+=0.5f) {
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
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "patterns" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
