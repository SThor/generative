// === CONFIGURATION ===
final int WIDTH = 800;
final int HEIGHT = 800;
final color BACKGROUND_COLOR = color(220, 220, 240); // Gris clair - changez ici !

// Animation parameters
final float SHAPE_SIZE = 60;
final float SPEED = 2.0;
final float OSCILLATION_AMPLITUDE = 200;
final float OSCILLATION_SPEED = 0.02;
final float HUE_SPEED = 1.5;

// === VARIABLES ===
PGraphics canvas;
PShader blurShader;
float yPos = 0;
int frameCounter = 0;
long seed;
boolean firstFrame = true;

void settings() {
  size(WIDTH, HEIGHT, P2D);
}

void setup() {
  colorMode(HSB, 360, 100, 100);
  
  // Generate seed
  seed = System.currentTimeMillis();
  randomSeed(seed);
  noiseSeed(seed);
  
  // Create canvas
  canvas = createGraphics(WIDTH, HEIGHT, P2D);
  canvas.colorMode(HSB, 360, 100, 100);
  
  // Load blur shader
  blurShader = loadShader("blur.glsl");
  blurShader.set("resolution", float(WIDTH), float(HEIGHT));
  
  // Set background color in shader (convert to RGB 0-1)
  float r = red(BACKGROUND_COLOR) / 255.0;
  float g = green(BACKGROUND_COLOR) / 255.0; 
  float b = blue(BACKGROUND_COLOR) / 255.0;
  blurShader.set("bgColor", r, g, b);
  
  println("Seed: " + seed);
}

void draw() {
  // Update position
  yPos += SPEED;
  frameCounter++;
  
  // Calculate shape position
  float oscillation = sin(frameCounter * OSCILLATION_SPEED);
  float xPos = WIDTH/2 + oscillation * OSCILLATION_AMPLITUDE;
  
  // Calculate color (rainbow cycle)
  float hue = (frameCounter * HUE_SPEED) % 360;
  
  // Draw on canvas
  canvas.beginDraw();
  canvas.colorMode(HSB, 360, 100, 100);
  
  // Only clear background on first frame
  if (firstFrame) {
    canvas.background(BACKGROUND_COLOR);
    firstFrame = false;
  }
  
  // Draw the shape
  canvas.noStroke();
  canvas.fill(hue, 80, 95);
  canvas.ellipse(xPos, yPos, SHAPE_SIZE, SHAPE_SIZE);
  
  canvas.endDraw();
  
  // Apply blur to entire canvas AFTER drawing
  canvas.filter(blurShader);
  
  // Display result
  image(canvas, 0, 0);
  
  // Display info
  fill(0);
  text("Frame: " + frameCounter, 10, 20);
  text("Seed: " + seed, 10, 40);
  
  // Reset when shape goes off screen
  if (yPos > HEIGHT + SHAPE_SIZE) {
    resetAnimation();
  }
}

void resetAnimation() {
  yPos = -SHAPE_SIZE;
  frameCounter = 0;
  firstFrame = true;
  
  // Generate new seed
  seed = System.currentTimeMillis();
  randomSeed(seed);
  noiseSeed(seed);
  println("New seed: " + seed);
}

void keyPressed() {
  if (key == 'r' || key == 'R') {
    resetAnimation();
  } else if (key == 's' || key == 'S') {
    saveFrame("motion_blur_####.png");
    println("Frame saved!");
  }
}