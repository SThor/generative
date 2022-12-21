float margin = 300;
float diameter = 200;
float x = margin, y = margin;
float step = 2;
float xStep = 0, yStep = step;
float hue;
float hueStep;
float opacity = 2;

color pencilColor = color(0, 0, 0, 30);
float leftMargin = 0;
float topMargin = 0;
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

void fillPencilCircle(float centerX, float centerY, float diameter) {
  //float increment = printMode ? 1.3 : 1.2;
  float increment = 3;
  for (float d = 2; d<diameter; d+=increment) {
    pencilCircle(centerX, centerY, d);
  }
}

void pencilCircle(float centerX, float centerY, float diameter) {
  pencilArc(centerX, centerY, diameter, 0, TWO_PI);
}

void pencilArc(float centerX, float centerY, float diameter, float startAngle, float endAngle) {
  pencilArc(centerX, centerY, diameter, startAngle, endAngle, false);
}

void pencilArc(float centerX, float centerY, float diameter, float startAngle, float endAngle, boolean fade) {
  noStroke();
  float x, y;
  color end = color(0, 0, 0, 0);
  //for (float theta = startAngle; theta < endAngle; theta+=0.3/diameter) {
  for (float theta = startAngle; theta < endAngle; theta+=3/diameter) {
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

void settings() {
  size(1500, 1000, P2D);
  smooth(8);
}

void setup() {
  colorMode(HSB, 360, 100, 100, 100);
  blendMode(ADD);
  background(240, 100, 5);
  //background(350, 100);
  noStroke();
  //paper();
  hueStep = random(0.5);
  println("hueStep " + hueStep);
  hue = random(360);
  println("hue " + hue);
  fill(hue, 100, 80, opacity);
}

void draw() {
  //circle(x,y,diameter);
  fillPencilCircle(x, y, diameter);
  y += yStep;
  x += xStep;

  //hue = (hue + 1)%360;
  //fill(hue, 100, 60, 5);

  if (y > height - margin) {
    yStep = -step;
    //xStep = step/1.5;
    xStep += random(0.5);
    hue = (hue + random(360))%360;
    fill(hue, 100, 80, opacity);
  }

  if (y < margin) {
    yStep = step;
    xStep += random(0.5);
    hue = (hue + random(360))%360;
    fill(hue, 100, 80, opacity);
  }

  if (x > width - margin) {
    save(year()+"-"+month()+"-"+day()+"-"+hour()+"-"+minute()+"-"+second()+".png");
    noLoop();
  }
}

void keyTyped() {
  if (key == 's' || key == 'S') {
    save(year()+"-"+month()+"-"+day()+"-"+hour()+"-"+minute()+"-"+second()+".png");
  }
}
