float topMargin = 0, leftMargin = 0;
float xOffset = 340;
float yOffset = 310;
float minDiameter = 80;
float maxDiameter;
float x1, y1, x2, y2 = 0;
color pencilColor = color(0, 0, 0, 30);
int step = 0;
boolean printMode = false;

void paper() {
  noStroke();
  for (int i = 0; i < 100000; ++i) {
    fill(random(360), random(100), random(100), random(20));
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


void pencilLine(float x1, float y1, float x2, float y2) {
  pencilLine(x1, y1, x2, y2, false);
}

void pencilLine(float x1, float y1, float x2, float y2, boolean adjustForLength) {
  noStroke();
  float x, y;
  float increment = 0.0001;
  if (adjustForLength) {
    increment = 0.15 / dist(x1, y1, x2, y2);
  }
  for (float amt = 0; amt < 1; amt += increment) {
    x = lerp(x1, x2, amt);
    y = lerp(y1, y2, amt);
    //circle(x,y,amt*100);
    if (x>=leftMargin && x<=width-leftMargin && y>=topMargin && y<=height-topMargin)
      circle(x+random(2), y+random(2), random(2));
  }
}

void pencilCircle(float centerX, float centerY, float diameter) {
  pencilArc(centerX, centerY, diameter, 0, TWO_PI);
}

void pencilCircle(float centerX, float centerY, float diameter, boolean fade) {
  pencilArc(centerX, centerY, diameter, 0, TWO_PI, fade);
}

void pencilArc(float centerX, float centerY, float diameter, float startAngle, float endAngle) {
  pencilArc(centerX, centerY, diameter, startAngle, endAngle, false);
}

public static void pencilArc(float centerX, float centerY, float diameter, float startAngle, float endAngle, boolean fade) {
  float x, y;
  for (float theta = startAngle; theta < endAngle; theta+=0.3/diameter) {
    if (fade) {
      fill(hue(pencilColor), saturation(pencilColor), brightness(pencilColor), alpha(pencilColor) * (theta-startAngle)/(endAngle - startAngle));
    }
    x= centerX + diameter/2*cos(theta);
    y= centerY + diameter/2*sin(theta);
    if (x>=leftMargin && x<=width-leftMargin && y>=topMargin && y<=height-topMargin) {
      circle(x+random(2), y+random(2), random(2));
    }
  }
}

boolean flipCoin() {
  return random(1) > 0.5;
}

void fillPencilCircle(float centerX, float centerY, float diameter) {
  float increment = printMode ? 1.3 : 1.2;
  for (float d = 2; d<diameter; d+=increment) {
    pencilCircle(centerX, centerY, d);
  }
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
  stroke(0);
  if (printMode) {
    background(360);
    pencilColor = color(0, 0, 0, 0);
  } else {
    background(350, 100);
    paper();
    pencilColor = color(0, 0, 0, 30);
  }
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
