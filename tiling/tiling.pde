import paperandpencil.*;

PaperAndPencil pp;
float topMargin = 0, leftMargin = 0;
float xOffset = 340;
float yOffset = 310;
float minDiameter = 80;
float maxDiameter;
float x1, y1, x2, y2 = 0;
color pencilColor = color(0, 0, 0, 30);
int step = 0;
boolean printMode = false;

boolean flipCoin() {
  return random(1) > 0.5;
}

void settings() {
  size(1000, 1500, P2D);
  smooth(8);
}

void setup() {
  colorMode(HSB, 360, 100, 100, 100);
  init();
}

void init() {
  pp = new PaperAndPencil(this);
  stroke(0);
  if (printMode) {
    background(360);
    pencilColor = color(0, 0, 0, 0);
  } else {
    background(350, 100);
    pp.paper();
    pencilColor = color(0, 0, 0, 30);
  }
  pp.setPencilColor(pencilColor);
  pp.setPrintMode(printMode);
  fill(pencilColor);
}


void draw() {
}

void keyTyped() {
  if (key == 's' || key == 'S') {
    save(year()+"-"+month()+"-"+day()+"-"+hour()+"-"+minute()+"-"+second()+".png");
  }
  if (key=='p' || key == 'P') {
    printMode = !printMode;
    init();
  }
}
