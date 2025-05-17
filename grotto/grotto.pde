import yash.oklab.*;  

// Configuration parameters
final int WIDTH = 1000;
final int HEIGHT = 1000;
final float NOISE_SCALE = 0.5;
final float NOISE_AMPLITUDE = 100;
final int BASE_RADIUS = 130;
final int PARTICLES_PER_FRAME = 10000;
final float SPRAY_RADIUS = 2;
final int RIDGES = 3;
final int centerX = WIDTH / 2;
final int centerY = HEIGHT / 2;
final int BACKGROUND = 0;

// Global variables
String finalImagePath = null;
float m_noiseOffset = 0;
float m_hue = 0;
int m_fillColor = 0;

void settings() {
  size(WIDTH, HEIGHT, P2D);
  smooth(8);
}

void setup() {
  colorMode(RGB, 255, 255, 255);
  noiseDetail(4, 0.5);
  Ok.p = this;
  resetSketch();
}

float noisyRadius(float baseRadius, float angle, float noiseOffset) {
  // Convert angle to polar coordinates relative to center
  float xoff = cos(angle) + 1;
  float yoff = sin(angle) + 1;
  
  // Calculate the noisy radius at this angle
  return baseRadius + map(noise(xoff * NOISE_SCALE, yoff * NOISE_SCALE, noiseOffset), 0, 1, -NOISE_AMPLITUDE, NOISE_AMPLITUDE);
}

boolean insideRadius(float x, float y, float radius) {
  // Check if the point (x, y) is outside the radius
  float dist = dist(x, y, centerX, centerY);
  return dist < radius;
}

void drawRidge(float radius, float noiseOffset) {
  loadPixels();
  for (int x = 0; x < width; x++) {
    for (int y = 0; y < height; y++) {
      float dx = x - centerX;
      float dy = y - centerY;
      

      float angle = atan2(dy, dx);
      float dist = sqrt(dx*dx + dy*dy);
      
      float noisyRadius = noisyRadius(radius, angle, noiseOffset);
      float distFromBoundary = abs(dist - noisyRadius);

      if (insideRadius(x, y, noisyRadius)) {
        continue;
      }
      
      // Create smooth falloff
      float intensity = constrain(map(distFromBoundary, 0, 2*NOISE_AMPLITUDE, 1, 0), 0, 1);
      //intensity = intensity * intensity; // Square for smoother falloff
      
      int loc = x + y * width;
      pixels[loc] = lerpColor(BACKGROUND, m_fillColor, intensity * 0.4);
    }
  }
  updatePixels();
  for (int i = 0; i < PARTICLES_PER_FRAME;) {
    // Focus particles around the circle boundary for efficiency
    float angle = random(TWO_PI);
    float noisyRadius = noisyRadius(radius, angle, noiseOffset);
    float finalRadius = noisyRadius + randomGaussian() * NOISE_AMPLITUDE * 0.5;
    float rx = centerX + cos(angle) * finalRadius;
    float ry = centerY + sin(angle) * finalRadius;
    if (insideRadius(rx, ry, noisyRadius)) {
      continue;
    }
    circle(rx + randomGaussian() * SPRAY_RADIUS, 
           ry + randomGaussian() * SPRAY_RADIUS, 
           random(2, 3));
    i++;
  }
}

void draw() {
  // Draw background with low opacity to create a fading effect
  fill(BACKGROUND);
  rect(0, 0, width, height);
  // Draw particles
  noStroke();
  
  for (int i = 0; i < RIDGES; i++) {
    // H = Hue (0-360), S = Saturation (0-100), V = Value (0-100), L = Lightness (0-100) (unused here), A = Alpha (0-100).
    // Set the fill color using the Ok.HSV function, which converts HSV values to a color
    m_fillColor = Ok.HSV(
      m_hue, // Hue: the base hue value, which is randomized in resetSketch()
      80, // ((float)i + 1.0f / (float)RIDGES) * 100.0f, // Saturation: increases with each ridge, creating a gradient effect
      ((float)i + 1.0f / (float)RIDGES) * 100.0f, // Brightness: also increases with each ridge for a similar gradient effect
      30 // Alpha: transparency level, set to 30 for a subtle blending effect
    );
    fill(m_fillColor);
    drawRidge(BASE_RADIUS + 100 * i, m_noiseOffset + 10 * i);
  }
  
  m_noiseOffset += 0.05;
}

void keyPressed() {
  if (key == 's' || key == 'S') {
    saveImage();
  } else if (key == ENTER || key == '\n') {
    resetSketch();
  }
}

void saveImage() {
  String filename = year() + "-" + month() + "-" + day() + "-" + hour() + "-" + minute() + "-" + second() + ".png";
  if (finalImagePath != null) {
    // Copy the temporary file to the new filename
    File source = new File(sketchPath(finalImagePath));
    File dest = new File(sketchPath(filename));
    try {
      java.nio.file.Files.copy(source.toPath(), dest.toPath());
    } catch (IOException e) {
      println("Error saving file: " + e.getMessage());
    }
  } else {
    save(filename);
  }
}

void resetSketch() {
  background(0);
  frameCount = 0;
  finalImagePath = null;
  m_hue = random(360.0f);
  loop();
}
