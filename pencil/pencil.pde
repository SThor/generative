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

void pencilArc(float centerX, float centerY, float diameter, float startAngle, float endAngle, boolean fade) {
  noStroke();
  float x, y;
  color end = color(0, 0, 0, 0);
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
    pencilLine(x0, y0, x, y);
  }
  x0 = width - offset;
  y0 = height - offset;
  for (float theta = PI; theta<(PI+QUARTER_PI); theta+=0.008) {
    x=x0 + r*cos(theta);
    y=y0 + r*sin(theta);
    pencilLine(x0, y0, x, y);
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
  stroke(0);
  if (printMode) {
    background(360);
    pencilColor = color(0, 0, 0, 0);
  } else {
    background(350, 100);
    paper();
    pencilColor = color(0, 0, 0, 30);
  }

  //fill(random(360), random(100), random(100), 2);
  fill(pencilColor);

  pencilLine(xOffset, yOffset - 200, xOffset, height - yOffset + 45, true); //left
  pencilLine(width - xOffset, yOffset - 90, width - xOffset, height - yOffset + 250, true); //right
  pencilLine(xOffset - 50, yOffset, width - xOffset + 30, yOffset, true); //top
  pencilLine(xOffset - 13, height - yOffset, width - xOffset + 8, height - yOffset, true); //bottom

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
    pencilCircle(width/2, height/2, d);
    if (!printMode)
      pencilArc(width/2, height/2, d, PI - random(QUARTER_PI), PI + random(QUARTER_PI), true);
    //i += 0.2;
    //d += 5 + noise(i) * 5;
    d += constantStep + random(variableStep);
  }

  d = minDiameter;
  while (d < maxDiameter) {
    fill(pencilColor);
    pencilCircle(width/2, yOffset + maxDiameter/2, d);
    if (!printMode)
      pencilArc(width/2, yOffset + maxDiameter/2, d, PI - random(QUARTER_PI), PI + random(QUARTER_PI), true);
    //i += 0.2;
    //d += 5 + noise(i) * 5;
    d += constantStep + random(variableStep);
  }

  d = minDiameter;
  while (d < maxDiameter) {
    fill(pencilColor);
    pencilCircle(width/2, height - yOffset - maxDiameter/2, d);
    if (!printMode)
      pencilArc(width/2, height - yOffset - maxDiameter/2, d, PI - random(QUARTER_PI), PI + random(QUARTER_PI), true);
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
    fillPencilCircle(width/2, height/2, minDiameter);
  if (flipCoin())
    fillPencilCircle(width/2, yOffset + maxDiameter/2, minDiameter);
  if (flipCoin())
    fillPencilCircle(width/2, height - yOffset - maxDiameter/2, minDiameter);
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
    pencilCircle(centerX, centerY, d);
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
  pencilLine(x1, y1, x2, y2, true);
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
