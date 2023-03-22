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

float offset, reach;

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

  increment = 0.01;
  maskIncrement = 0.01;
  zincrement = 0.01;
  gradientEnd = 100;
  gradientStart = 25;
  offset = random(260);
  reach = random(100);
  colorIndex = 0;
}

void draw() {
  if (finished) {
    return;
  }
  if (started) {
    // Optional: adjust noise detail here
    noiseDetail(8,0.65f);
    
    loadPixels();
    float xMask, yMask;
    
    mask = new color[width*height];
    if (gradientEnd + z < (width/2)) {
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
        // mask[x+y*width] = color(map(xMask, -1, 1, 0, 360));
        // if (noise > map(y-z*100, 0, height, -1, 1) || noise > xMask) {
        //   mask[x+y*width] = color(0);
        // } else {
        //   mask[x+y*width] = color(255);
        // }
        if (noise > yMask || noise > xMask) {
          mask[x+y*width] = color(0);
        } else {
          mask[x+y*width] = color(255);
        }
        

        // TODO:
        /*
          - trois carrés alignés verticalement : 1er et 3e en miroir:
            - faire varier le seuil pour dessiner le bruit verticalement, en fonction de y
            - utiliser un bruit comme masque pour savoir où dessiner
            - dessiner juste des ronds au crayon, positions aléatoires, (densité variable en fonction de y ?)
            - couleur des ronds voire de leurs points en fonction d'un autre bruit plus dense, en dégradé
          - aucune idée pour le carré central, mais très coloré et plein
        */
      }
    }

    // System.arraycopy(mask, 0, pixels, 0, mask.length);

    for (int x = 0; x < width; x++) {
      for (int y = 0; y < height; y++) {
        float noise = (float)noiseGenerator.noise(x*increment,y*increment,z+100);
        
        if (mask[x+y*width] != color(0)) {
          pixels[x+y*width] = lerpColor(palette[colorIndex], palette[(colorIndex+1)%palette.length], noise);
        } else {
          //pixels[x+y*width] = palette[3];
        }
      }
    }
    
    updatePixels(); 
    
    z += zincrement;

    if(frameCount%20 == 0){
      colorIndex = (++colorIndex)%palette.length;
    }
  } else {

    paletteWidth = width / palette.length;
    for(int i=0; i<palette.length; i++) {
      fill(palette[i]);
      rect(i*paletteWidth, 0, (i+1)*paletteWidth, height);
    }

    // for (int i=0; i<50; i++) {
      // stroke(Ok.HSL(offset+2*i, 100, 80));
      // stroke(color(map(i, 0, 50, offset, offset+reach), 100, 80));
      //line(i,0,i,10);
    // }
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
    //background(palette[2]);
  }
}

void keyPressed() {
  palette = paletteGenerator.getPalette();
  offset = random(260);
  reach = random(100);
}
