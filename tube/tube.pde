float cellWidth = 70;
color backgroundColor;
color topColor;

float topMargin = 0, leftMargin = 0;
float xOffset = 340;
float yOffset = 310;
float minDiameter = 80;
float maxDiameter;
float x1, y1, x2, y2 = 0;
//color pencilColor = color(0, 0, 0, 30);
color pencilColor = color(0, 0, 0, 0);
int step = 0;
boolean printMode = true;

float pileHeight = 200;
float levelStep = 1;

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
  noStroke();
  float x, y;
  float increment = 0.0001;
  increment = 0.15 / dist(x1, y1, x2, y2);
  for (float amt = 0; amt < 1; amt += increment) {
    x = lerp(x1, x2, amt);
    y = lerp(y1, y2, amt);
    //circle(x,y,amt*100);
    if (x>=leftMargin && x<=width-leftMargin && y>=topMargin && y<=height-topMargin)
      circle(x+random(2), y+random(2), random(2));
  }
}

void settings() {
  size(1000, 1000, P2D);
  smooth(8);
}

void setup() {
  colorMode(HSB, 360, 100, 100, 100);
  if (!printMode) {
    background(350, 100);
    paper();
    pencilColor = color(0, 0, 0, 20);
  } else {
    background(360);
    pencilColor = color(0, 0, 0, 0);
  }

  fill(pencilColor);
  noStroke();


  float x, y;
  float startAngle = 0;
  float endAngle = TWO_PI;
  float centerX = width/2;
  float centerY = height/2 - pileHeight/1.5;
  float diameter = width/3;
  float currentCenterY;
  float layerProgress;
  float noise;
  float opacity;
  for (float level = 0; level < pileHeight; level+=4*(0.1+level/pileHeight)) {
    currentCenterY = centerY + level;
    layerProgress = (pileHeight-level)/pileHeight;
    if (layerProgress < 0.05)
      layerProgress = 0.05;
    for (float theta = startAngle; theta < endAngle; ) {
      noise = noise(cos(theta)+sin(theta), level/75)*100;
      opacity = layerProgress/noise;
      fill(color(0, 0, 0, 10+opacity*200));
      x= centerX + diameter/2*cos(theta);
      y= currentCenterY + diameter/5*sin(theta);
      y += noise*1.15;
      if (x>=leftMargin && x<=width-leftMargin && y>=topMargin && y<=height-topMargin) {
        circle(x+random((2+level/pileHeight)), y+random((2+level/pileHeight)), random(2)+1);
      }

      //if (level > 5) {
      //theta+= (3+random(5))/diameter;
      theta += 10*(0.1+level/pileHeight)/diameter;
      //theta+= (1/layerProgress)/diameter;
      //} else {
      //  theta+=(random(2.5))/diameter;
      //}
    }
  }
}

void draw() {
}

void keyTyped() {
  if (key == 's' || key == 'S') {
    save(year()+"-"+month()+"-"+day()+"-"+hour()+"-"+minute()+"-"+second()+".png");
  }
}
