import nice.palettes.*;
import yash.oklab.*;
import toxi.math.noise.*;

ColorPalette paletteGenerator;
int[] palette;
SimplexNoise noiseGenerator;

float increment, maskIncrement;
// The noise function's 3rd argument, a global variable that increments once per cycle
float z = 0.0;  
// We will increment zoff differently than xoff and yoff
float zincrement;

float gradientEnd, gradientStart;

color[] mask;

int colorIndex;

boolean started = false;
boolean finished = false;

int paletteWidth;

void settings() {
  size(800, 800, P2D);
}

void setup() {
  // colorMode(HSB, 360, 100, 100);
  //blendMode(ADD);
  background(0);
  noStroke();
  frameRate(15);
  
  
  // Initialize it, passing a reference to the current PApplet 
  paletteGenerator = new ColorPalette(this);
  
  // Get a random color paletteGenerator
  palette = paletteGenerator.getPalette();
  printArray(palette);
  
  Ok.p = this;

  increment = width/800000f;
  maskIncrement = width/800000f;
  zincrement = width/160000f;
  gradientEnd = width/8f;
  gradientStart = width/32f;
  colorIndex = 0;
}

void draw() {
  if (finished) {
    return;
  }
  if (started) {
    // Optional: adjust noise detail here
    noiseDetail(floor(width/100f), width/1230f);
    
    loadPixels();
    float xMask, yMask;
    
    mask = new color[width*height];
    if (gradientEnd + z < (width/2f)) {
      gradientEnd += z;
    } else if (gradientStart + z < gradientEnd) {
      gradientStart += z;
    } else {
      finished = true;
    }
    // For every x,y coordinate in a 2D space, calculate a mask value
    for (int x = 0; x < width; x++) {
      for (int y = 0; y < height; y++) {
        
        // Calculate noise and scale by 255
        float noise = (float)noiseGenerator.noise(x*maskIncrement,y*maskIncrement,z);

        if (x < gradientStart) {
          xMask = -1;
        } else if (x < gradientEnd) {
          xMask = map(x, gradientStart, gradientEnd, -1, 1);
        } else if (x > width - gradientStart) {
          xMask = -1;
        } else if (x > width - gradientEnd - gradientStart) {
          xMask = map(x, width - gradientEnd - gradientStart, width - gradientStart, 1, -1);
        } else {
          xMask = 1;
        }

        if (y < gradientStart) {
          yMask = -1;
        } else if (y < gradientEnd) {
          yMask = map(y, gradientStart, gradientEnd, -1, 1);
        } else if (y > height - gradientStart) {
          yMask = -1;
        } else if (y > height - gradientEnd - gradientStart) {
          yMask = map(y, height - gradientEnd - gradientStart, height - gradientStart, 1, -1);
        } else {
          yMask = 1;
        }
        
        if (noise < yMask && noise < xMask) {
          float noise2 = (float)noiseGenerator.noise(x*increment,y*increment,z+(width/8f));
          pixels[x+y*width] = lerpColor(palette[colorIndex], palette[(colorIndex+1)%palette.length], noise2);
        }
      }
    }
    
    updatePixels(); 
    
    z += zincrement;

    if(frameCount%(width/40f) == 0){
      colorIndex = (++colorIndex)%palette.length;
    }
  } else { // not started
    paletteWidth = width / palette.length;
    for(int i=0; i<palette.length; i++) {
      fill(palette[i]);
      rect(i*paletteWidth, 0, (i+1)*paletteWidth, height);
    }
  }
}

void mouseClicked() {
  if (started) {
    boolean wasFinished = finished;
    finished = false;
    save(year()+"-"+month()+"-"+day()+"_"+year()+"-"+hour()+"-"+minute()+"-"+second()+"-"+".png");
    finished = wasFinished;
  } else {
    started = true;
  }
}

void keyPressed() {
  palette = paletteGenerator.getPalette();
}
