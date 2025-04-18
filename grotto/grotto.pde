// Configuration parameters
final int WIDTH = 1000;
final int HEIGHT = 1000;
final float NOISE_SCALE = 0.5;
final float NOISE_AMPLITUDE = 100;
final int BASE_RADIUS = 130;
final int PARTICLES_PER_FRAME = 10000;
final float SPRAY_RADIUS = 2;
final int RIDGES = 3;

// Global variables
String finalImagePath = null;
float m_noiseOffset = 0;

void settings() {
  size(WIDTH, HEIGHT, P2D);
  smooth(8);
}

void setup() {
  colorMode(RGB, 255, 255, 255);
  background(0);
  noiseDetail(4, 0.5);
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
  float dist = dist(x, y, width/2, height/2);
  return dist < radius;
}

void drawRidge(float radius, float noiseOffset) {
  for (int i = 0; i < PARTICLES_PER_FRAME;) {
    // Focus particles around the circle boundary for efficiency
    float angle = random(TWO_PI);
    float noisyRadius = noisyRadius(radius, angle, noiseOffset);
    float finalRadius = noisyRadius + randomGaussian() * NOISE_AMPLITUDE * 0.5;
    float rx = width/2 + cos(angle) * finalRadius;
    float ry = height/2 + sin(angle) * finalRadius;
    if (insideRadius(rx, ry, noisyRadius)) {
      continue;
    }
    circle(rx + random(0, SPRAY_RADIUS), 
            ry + random(0, SPRAY_RADIUS), 
            random(2, 3));
    i++;
  }
}

void draw() {
  // Draw background with low opacity to create a fading effect
  fill(0);
  rect(0, 0, width, height);
  // Draw particles
  noStroke();
  fill(255, 50); // Low opacity white
  
  for (int i = 0; i < RIDGES; i++) {
    drawRidge(BASE_RADIUS + 100 * i, m_noiseOffset + 10 * i);
  }
  
  m_noiseOffset += 0.005;
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
  loop();
}
