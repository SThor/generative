int gridWidth, gridHeight;
float cellWidth;
float topMargin, leftMargin;
float spacing;

Cell[] cells;

void paper() {
  noStroke();
  for (int i = 0; i < 100000; ++i) {
    fill(random(360), random(100), random(100), random(30));
    float x = random(width);
    float y = random(height);
    circle(x, y, random(2));
  }	
  loadPixels();
  for ( int i=0; i<pixels.length; i+=1) {
    pixels[i] = lerpColor(pixels[i], color(360), random(.5));
  }
  updatePixels();
}

void settings() {
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

void setup() {
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

void mouseReleased() {
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

void draw() {
}
