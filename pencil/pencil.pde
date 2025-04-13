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

void angles() {
  //fill(random(360), random(100), random(100), 2);
  fill(0, 0, 0, 50);
  float x, y;
  float r = 2000;
  float offset = topMargin;
  float x0 = offset, y0 = offset;
  for (float theta = 0; theta<QUARTER_PI; theta+=0.008) {
    x=x0 + r*cos(theta);
    y=y0 + r*sin(theta);
    pp.pencilLine(x0, y0, x, y, false);
  }
  x0 = width - offset;
  y0 = height - offset;
  for (float theta = PI; theta<(PI+QUARTER_PI); theta+=0.008) {
    x=x0 + r*cos(theta);
    y=y0 + r*sin(theta);
    pp.pencilLine(x0, y0, x, y, false);
  }
  //pencilLine(offset, offset, offset, height - offset); //left
  //pencilLine(width - offset, offset, width - offset, height - offset); //right

  //pencilLine(offset, offset, width - offset, offset); //top
  //pencilLine(offset, height - offset, width - offset, height - offset); //bottom
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

  //fill(random(360), random(100), random(100), 2);
  fill(pencilColor);

  pp.pencilLine(xOffset, yOffset - 200, xOffset, height - yOffset + 45, false); //left
  pp.pencilLine(width - xOffset, yOffset - 90, width - xOffset, height - yOffset + 250, false); //right
  pp.pencilLine(xOffset - 50, yOffset, width - xOffset + 30, yOffset, false); //top
  pp.pencilLine(xOffset - 13, height - yOffset, width - xOffset + 8, height - yOffset, false); //bottom

  float constantStep, variableStep;
  if (printMode) {
    constantStep = 7;
    variableStep = 4;
  } else {
    constantStep = 5;
    variableStep = 5;
  }
  
  float d = minDiameter;
  maxDiameter = width - xOffset * 2;
  while (d < maxDiameter) {
    fill(pencilColor);
    pp.pencilCircle(width/2, height/2, d, false);
    if (!printMode)
      pp.pencilArc(width/2, height/2, d, PI - random(QUARTER_PI), PI + random(QUARTER_PI), true);
    //i += 0.2;
    //d += 5 + noise(i) * 5;
    d += constantStep + random(variableStep);
  }

  d = minDiameter;
  while (d < maxDiameter) {
    fill(pencilColor);
    pp.pencilCircle(width/2, yOffset + maxDiameter/2, d, false);
    if (!printMode)
      pp.pencilArc(width/2, yOffset + maxDiameter/2, d, PI - random(QUARTER_PI), PI + random(QUARTER_PI), true);
    //i += 0.2;
    //d += 5 + noise(i) * 5;
    d += constantStep + random(variableStep);
  }

  d = minDiameter;
  while (d < maxDiameter) {
    fill(pencilColor);
    pp.pencilCircle(width/2, height - yOffset - maxDiameter/2, d, false);
    if (!printMode)
      pp.pencilArc(width/2, height - yOffset - maxDiameter/2, d, PI - random(QUARTER_PI), PI + random(QUARTER_PI), true);
    //i += 0.2;
    //d += 5 + noise(i) * 5;
    d += constantStep + random(variableStep);
  }
}

boolean flipCoin() {
  return random(1) > 0.5;
}

void randomFills() {
  if (flipCoin())
    pp.fillPencilCircle(width/2, height/2, minDiameter);
  if (flipCoin())
    pp.fillPencilCircle(width/2, yOffset + maxDiameter/2, minDiameter);
  if (flipCoin())
    pp.fillPencilCircle(width/2, height - yOffset - maxDiameter/2, minDiameter);
  if (flipCoin())
    fillOutside(width/2, yOffset + maxDiameter/2, maxDiameter, PI, TWO_PI);
  if (flipCoin())
    fillOutside(width/2, height - yOffset - maxDiameter/2, maxDiameter, 0, PI);
  if (flipCoin())
    fillCenterOutside();
}

void fillCircles() {
  fillPencilCircle(width/2, height/2, minDiameter);
  fillPencilCircle(width/2, yOffset + maxDiameter/2, minDiameter);
  fillPencilCircle(width/2, height - yOffset - maxDiameter/2, minDiameter);
}

void fillPencilCircle(float centerX, float centerY, float diameter) {
  float increment = printMode ? 1.3 : 1.2;
  for (float d = 2; d<diameter; d+=increment) {
    pp.pencilCircle(centerX, centerY, d, false);
  }
}

void fillOutsides() {
  fillOutside(width/2, yOffset + maxDiameter/2, maxDiameter, PI, TWO_PI);
  fillOutside(width/2, height - yOffset - maxDiameter/2, maxDiameter, 0, PI);
}

void fillOutside(float centerX, float centerY, float diameter, float startAngle, float endAngle) {
  noStroke();
  float x, y;
  float increment = printMode ? 1.3 : 1.2;
  for (float d = diameter; d<(diameter*2); d+=increment) {
    for (float theta = startAngle; theta < endAngle; theta+=0.3/diameter) {
      x= centerX + d/2*cos(theta);
      y= centerY + d/2*sin(theta);
      if ( x>centerX-diameter/2
        && x<centerX+diameter/2
        && y>centerY-diameter/2
        && y<centerY+diameter/2) {
        circle(x+random(2), y+random(2), random(2));
      }
    }
  }
}

void fillCenterOutside() {
  float increment = printMode ? 0.2 : 0.32;
  for (float x=xOffset; x<width-xOffset; x+=increment) {
    for (float y=yOffset + maxDiameter/2; y<height - yOffset - maxDiameter/2; y+=increment) {
      if ( pow(x - width/2, 2) + pow(y - height/2, 2) >= pow(maxDiameter/2, 2)
        && pow(x - width/2, 2) + pow(y - (yOffset + maxDiameter/2), 2) >= pow(maxDiameter/2, 2)
        && pow(x - width/2, 2) + pow(y - (height - yOffset - maxDiameter/2), 2) >= pow(maxDiameter/2, 2)) {
        circle(x+random(2), y+random(2), random(2));
      }
    }
  }
}

void mousePressed() {
  x1 = mouseX;
  y1 = mouseY;
  x2 = mouseX;
  y2 = mouseY;
}

void mouseDragged() {
  x2 = mouseX;
  y2 = mouseY;
}

void mouseReleased() {
  fill(pencilColor);
  pp.pencilLine(x1, y1, x2, y2, false);
}


void draw() {
}

void keyTyped() {
  if (key == 's' || key == 'S') {
    save(year()+"-"+month()+"-"+day()+"-"+hour()+"-"+minute()+"-"+second()+".png");
  }
  if (key == '+') {
    switch (step) {
    case 0:
      fillCircles();
      break;
    case 1:
      fillOutsides();
      break;
    case 2:
      fillCenterOutside();
      break;
    }
    step++;
  }
  if (key=='f' || key == 'F') {
    randomFills();
  }
  if (key=='r' || key == 'R') {
    init();
    randomFills();
  }
  if (key=='p' || key == 'P') {
    printMode = !printMode;
    init();
    randomFills();
  }
}
