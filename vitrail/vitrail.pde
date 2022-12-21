float topMargin = 0, leftMargin = 0;
float xOffset = 340;
float yOffset = 310;
float minDiameter = 80;
float maxDiameter;
float x1, y1, x2, y2 = 0;
//color pencilColor = color(0, 0, 0, 30);
color pencilColor = color(0, 0, 0, 0);
int step = 2;
int substep = 2;
float radius = 400;

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
  pencilLine(x1, y1, x2, y2, true);
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
      fill(0, 0, 0, 30 * (theta-startAngle)/(endAngle - startAngle));
    }
    x= centerX + diameter/2*cos(theta);
    y= centerY + diameter/2*sin(theta);
    if (x>=leftMargin && x<=width-leftMargin && y>=topMargin && y<=height-topMargin) {
      circle(x+random(2), y+random(2), random(2));
    }
  }
}

float triangleHeight(float base) {
  return sqrt(3.0)*base/2.0;
}

float triangleHeight(float base, float side) {
  return sqrt(4*sq(side)-sq(base))/2;
}

void settings() {
  size(1000, 1500, P2D);
  smooth(8);
}

void mainStep() {
  background(360);
  //gothicArc(width/2, height/2, radius, true, radius, false);
  //generateInteriorArcs(step);

  gothicArc(width/2, height/2, radius, true, radius, step, substep);
}

void setup() {
  colorMode(HSB, 360, 100, 100, 100);
  //background(350, 100);
  stroke(0);
  //paper();
  fill(pencilColor);
  mainStep();
}

void simpleRosace(float centerX, float centerY, float diameter, int subcircles, float startAngle) {
  pencilCircle(centerX, centerY, diameter);
  float angle = TWO_PI/subcircles;
  float subdiameter = diameter/2;
  float x, y, subAngle;
  for (int i=0; i<subcircles; i++) {
    subAngle = startAngle + i*angle;
    x = centerX + subdiameter/2*cos(subAngle);
    y = centerY + subdiameter/2*sin(subAngle);
    pencilArc(x, y, subdiameter, subAngle - HALF_PI - PI/6, subAngle + HALF_PI + PI/6);
  }
}

void gothicArc(float centerX, float centerY, float radius, boolean showTail, float tail, int subdivisions) {
  gothicArc(centerX, centerY, radius, showTail, tail, subdivisions, 0);
}

void gothicArc(float centerX, float centerY, float radius, boolean showTail, float tail, int subdivisions, int recursion) {
  gothicArc(centerX, centerY, radius, showTail, tail, recursion == 0);
  if (recursion > 0) {
    float origin = centerX-radius/2;
    float subradius = radius/subdivisions;
    for (int i=0; i<subdivisions; i++) {
      gothicArc(origin + (i+0.5)*subradius, height/2, subradius, i%2==0, tail, (recursion > 0) ? step : 0, recursion - 1);
    }
    simpleRosace(centerX, centerY - triangleHeight(radius, 0.75*radius), radius/2, 4, 3*HALF_PI);
  } else {
    fill(0, 0, 0, 20);
    float x, y, a, b, x1, y1, y2;
    a = -1.5;
    for (float centerOffset = -radius; centerOffset < tail + radius; centerOffset += 40) {
      x = centerX;
      y = centerY + centerOffset;
      b = y - a * x;
      x1 = x + radius/2;
      y1 = a * x1+b;
      x2 = x - radius/2;
      y2 = a * x2+b;
      pencilLine(x1, y1, x2, y2);
    }
    a = -a;
    for (float centerOffset = -radius; centerOffset < tail + radius; centerOffset += 40) {
      x = centerX;
      y = centerY + centerOffset;
      b = y - a * x;
      x1 = x + radius/2;
      y1 = a * x1+b;
      x2 = x - radius/2;
      y2 = a * x2+b;
      pencilLine(x1, y1, x2, y2);
    }
    fill(pencilColor);
  }
}

void gothicArc(float centerX, float centerY, float radius, boolean showTail, float tail, boolean subarcs) {
  if (showTail) {
    pencilLine(centerX - radius/2, centerY, centerX - radius/2, centerY + tail);
    pencilLine(centerX + radius/2, centerY, centerX + radius/2, centerY + tail);
  }

  pencilArc(centerX - radius/2, centerY, 2*radius, -PI/3, 0);
  pencilArc(centerX + radius/2, centerY, 2*radius, PI, PI+PI/3);

  if (subarcs) {
    pencilArc(centerX, centerY, radius, PI, PI+PI/3);
    pencilArc(centerX + radius/4, centerY - triangleHeight(radius/2), radius, PI, PI+PI/3);
    pencilArc(centerX - radius/4, centerY - triangleHeight(radius/2), radius, -PI/3, 0);
    pencilArc(centerX, centerY, radius, -PI/3, 0);
  }
}

void generateInteriorArcs(int qty) {
  float origin = (width-radius)/2;
  float subradius = radius/qty;
  for (int i=0; i<qty; i++) {
    gothicArc(origin + (i+0.5)*subradius, height/2, subradius, false, radius, substep);
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
  //pencilLine(x1, y1, x2, y2, true);
}


void draw() {
}

void keyTyped() {
  if (key == 's' || key == 'S') {
    save(year()+"-"+month()+"-"+day()+"-"+hour()+"-"+minute()+"-"+second()+".png");
  }
  if (key == '+') {
    step++;
  }
  if (key == '-') {
    step--;
  }
  if (key == 'p') {
    substep++;
  }
  if (key == 'm') {
    substep--;
  }
  mainStep();
}
