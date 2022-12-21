float cellWidth = 70;
color backgroundColor;
color topColor;

float increment = 0.2;
// The noise function's 3rd argument, a global variable that increments once per cycle
float zoff = 0.0;
// We will increment zoff differently than xoff and yoff
float zincrement = 0.02;

void settings() {
  size(1500, 1000, P2D);
  smooth(8);
}

void setup() {
  colorMode(HSB, 360, 100, 100, 100);
  blendMode(ADD);
  backgroundColor = color(240, 100, 5);
  topColor = color(50, 100, 100);
  background(backgroundColor);
  fill(topColor);
}

void draw() {
  //for (float x = 0; x<width; x++) {
  //  for (float y = 0; y<height; y++) {
  //    fill(lerpColor(backgroundColor, topColor, noise(x,y));
  //    square(x,y,1);
  //  }
  //}
  // Optional: adjust noise detail here
  // noiseDetail(8,0.65f);

  loadPixels();

  float xoff = 0.0; // Start xoff at 0

  // For every x,y coordinate in a 2D space, calculate a noise value and produce a brightness value
  for (int x = 0; x < width; x++) {
    if (x%cellWidth == 0)
      xoff += increment;   // Increment xoff
    float yoff = 0.0;   // For every xoff, start yoff at 0
    for (int y = 0; y < height; y++) {
      if (y%cellWidth == 0)
        yoff += increment; // Increment yoff

      // Calculate noise and scale by 100
      float bright = noise(xoff, yoff, zoff)*100;

      // Try using this line instead
      //float bright = random(0,255);

      // Set each pixel onscreen to a grayscale value
      pixels[x+y*width] = color(bright);
    }
  }
  updatePixels();

  zoff += zincrement; // Increment zoff
}

void keyTyped() {
  if (key == 's' || key == 'S') {
    save(year()+"-"+month()+"-"+day()+"-"+hour()+"-"+minute()+"-"+second()+".png");
  }
}
