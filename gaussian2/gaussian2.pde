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

float xGradientMargin;

color[] mask;

void settings() {
  size(800, 800, P2D);
}

void setup() {
  colorMode(HSB, 360, 100, 100);
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
  xGradientMargin = 100;
  offset = random(260);
  reach = random(100);
}

void draw() {  
  // Optional: adjust noise detail here
  noiseDetail(8,0.65f);
  
  loadPixels();
  float xMask;
  
  mask = new color[width*height];
  // For every x,y coordinate in a 2D space, calculate a mask value
  for (int x = 0; x < width; x++) {
    for (int y = 0; y < height; y++) {
      
      // Calculate noise and scale by 255
      float noise = (float)noiseGenerator.noise(x*maskIncrement,y*maskIncrement,z);

      if (x < xGradientMargin) {
        xMask = map(x, 0, xGradientMargin, -1.5, 1);
      } else if (x > width - xGradientMargin) {
        xMask = map(x, width - xGradientMargin, width, 1, -1.5);
      } else {
        xMask = 1;
      }
      // mask[x+y*width] = color(map(xMask, -1, 1, 0, 360));
      if (noise > map(y, 0, height, -1, 1.3) || noise > xMask) {
        mask[x+y*width] = color(360);
      } else {
        mask[x+y*width] = color(0);
      }


      // Set each pixel onscreen to a grayscale value
      // pixels[x+y*width] = color(bright*360, bright*100, bright*100);
      // pixels[x+y*width] = lerpColor(palette[0], palette[2], noise);

      // TODO:
      /*
        - trois carrés alignés verticalement : 1er et 3e en miroir:
          - faire varier le seuil pour dessiner le bruit verticalement, en fonction de y
          - utiliser un bruit comme masque pour savoir où dessiner
          - dessiner juste des ronds au crayon, positions aléatoires, (densité variable en fonction de y ?)
          - couleur des ronds voire de leurs points en fonction d'un autre bruit plus dense, en dégradé
        - aucune idée pour le carré central, mais très coloré et plein
      */

      // pixels[x+y*width] = Ok.HSL(map(noise, 0.2, 0.8, offset, offset+100), 100, 80);
      // if (noise < 0.2) {
      //   pixels[x+y*width] = color(offset, 100, 80);
      // } else if (noise > 0.8) {
      //   pixels[x+y*width] = color(offset+reach, 100, 80);
      // } else {
      //   pixels[x+y*width] = color(map(noise, 0.2, 0.8, offset, offset+reach), 100, 80);
      // }

      // if (noise < 0.2) {
      //   pixels[x+y*width] = lerpColor(palette[0], palette[1], map(noise, 0.1, 0.1001, 0, 1));
      // } else if (noise >= 0.2 && noise < 0.4) {
      //   pixels[x+y*width] = lerpColor(palette[1], palette[2], map(noise, 0.3, 0.3001, 0, 1));
      // } else if (noise >= 0.4 && noise < 0.6) {
      //   pixels[x+y*width] = lerpColor(palette[2], palette[3], map(noise, 0.5, 0.5001, 0, 1));
      // } else {
      //   pixels[x+y*width] = lerpColor(palette[3], palette[4], map(noise, 0.6, 1, 0, 1));
      // }
      
      // if (noise > 0.1 && noise < 0.3) {
      //   pixels[x+y*width] = palette[0];
      // } else if (noise > 0.4 && noise < 0.6) {
      //   pixels[x+y*width] = palette[1];
      // } else if (noise > 0.6 && noise < 0.9) {
      //   pixels[x+y*width] = palette[2];
      // } else {
      //   pixels[x+y*width] = palette[3];}
    }
  }

  // System.arraycopy(mask, 0, pixels, 0, mask.length);

  for (int x = 0; x < width; x++) {
    for (int y = 0; y < height; y++) {
       // Calculate noise and scale by 255
      float noise = (float)noiseGenerator.noise(x*increment,y*increment,z+100);
      
      // Set each pixel onscreen to a grayscale value
      if (mask[x+y*width] == color(0)) {
        pixels[x+y*width] = lerpColor(palette[0], palette[2], noise);
      } else {
        pixels[x+y*width] = palette[3];
      }
    }
  }

  /*
  // For every x,y coordinate in a 2D space, calculate a noise value and produce a brightness value
  for (int x = 0; x < width; x++) {
    for (int y = 0; y < height; y++) {
       // Calculate noise and scale by 255
      float noise = (float)noiseGenerator.noise(x*increment,y*increment,z+100);
      
      // Set each pixel onscreen to a grayscale value
      if (noise > 0.6 && noise < 0.9) {
        pixels[x+y*width] += palette[0];
      } else {
        pixels[x+y*width] += palette[2];
      }
    }
  }

  
  // For every x,y coordinate in a 2D space, calculate a noise value and produce a brightness value
  for (int x = 0; x < width; x++) {
    for (int y = 0; y < height; y++) {
       // Calculate noise and scale by 255
      float noise = (float)noiseGenerator.noise(x*increment,y*increment,z+200);
      
      // Set each pixel onscreen to a grayscale value
      if (noise > 0.1 && noise < 0.2) {
        pixels[x+y*width] -= palette[1];
      } else {
        pixels[x+y*width] -= palette[3];
      }
    }
  }
  */
  updatePixels(); 
  
  z += zincrement; 

  // for(int i=0; i<palette.length; i++) {
  //   fill(palette[i]);
  //   rect(i*10, 0, 10, 10);
  // }

  for (int i=0; i<50; i++) {
    // stroke(Ok.HSL(offset+2*i, 100, 80));
    // stroke(color(map(i, 0, 50, offset, offset+reach), 100, 80));
    //line(i,0,i,10);
  }
}

void mouseClicked() {
  save(year()+"-"+month()+"-"+day()+"_"+year()+"-"+hour()+"-"+minute()+"-"+second()+"-"+".png");
}

void keyPressed() {
  palette = paletteGenerator.getPalette();
  offset = random(260);
  reach = random(100);
}
