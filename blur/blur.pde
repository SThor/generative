// Configuration parameters
final int WIDTH = 1000;
final int HEIGHT = 1000;

// Graphics objects
PGraphics sourceBuffer;  // Buffer to hold original content
PGraphics displayBuffer; // Buffer that gets progressively blurred
PShader blurShader;      // Single circular blur shader

// Global variables
String finalImagePath = null;
long seed = 0; // Seed for reproducibility

void settings() {
  size(WIDTH, HEIGHT, P2D);
}

void setRandomSeed() {
  seed = System.currentTimeMillis();
  randomSeed(seed);
  noiseSeed(seed);
}

void setup() {
  colorMode(HSB, 360, 100, 100, 100);
  setRandomSeed();
  
  // Create our buffers with proper initialization
  sourceBuffer = createGraphics(WIDTH, HEIGHT, P2D);
  displayBuffer = createGraphics(WIDTH, HEIGHT, P2D);
  
  // Initialize both buffers with background
  sourceBuffer.beginDraw();
  sourceBuffer.colorMode(HSB, 360, 100, 100, 100);
  sourceBuffer.background(0);
  sourceBuffer.endDraw();
  
  displayBuffer.beginDraw();
  displayBuffer.colorMode(HSB, 360, 100, 100, 100);
  displayBuffer.background(0);
  displayBuffer.endDraw();
  
  // Load and configure circular blur shader
  blurShader = loadShader("blur.glsl");
  blurShader.set("resolution", float(WIDTH), float(HEIGHT));
  blurShader.set("kernelSize", 7); // Less prominent blur
  blurShader.set("sigmaFactor", 0.1); // Default softness, now adjustable
  
  // Draw initial content directly to display buffer
  // displayBuffer.beginDraw();
  // displayBuffer.fill(255, 100, 100);
  // displayBuffer.noStroke();
  // displayBuffer.ellipse(width/2, height/2, 400, 400);
  // displayBuffer.endDraw();
  
  // Clear the main canvas
  background(0);
}

void draw() {
  // Display the current state of our buffer
  image(displayBuffer, 0, 0);

  displayBuffer.beginDraw();
  float padding = 60; // Padding from all sides
  float rectWidth = width / 4;
  float rectHeight = height / 4;
  float rectY = padding + frameCount; // Start at padding, move down
  float hue = (frameCount * 0.1) % 360; // Animate hue over time
  // Oscillate horizontally with sin, amplitude decreases as it moves down
  float progress = (rectY - padding) / (height - 2 * padding - rectHeight); // 0 at top, 1 at bottom
  float amp = lerp((width - 2 * padding - rectWidth) / 2, 0, progress); // amplitude shrinks to 0
  float osc = sin(frameCount * 0.03);
  float centerX = width / 2 + osc * amp;
  displayBuffer.pushMatrix();
  displayBuffer.translate(centerX, rectY + rectHeight / 2);
  displayBuffer.fill(hue, 80, 100, 100);
  displayBuffer.noStroke();
  displayBuffer.rect(-rectWidth / 2, -rectHeight / 2, rectWidth, rectHeight, 20);
  displayBuffer.popMatrix();
  displayBuffer.filter(blurShader);
  displayBuffer.endDraw();

  // Add frame counter overlay
  fill(0);
  rect(0, 0, 200, 20);
  rect(width-250, 0, 250, 20); // For seed display
  fill(255);
  text("Frame: " + frameCount, 10, 20);
  text("Seed: " + seed, width-240, 20);
  
  if (rectY + rectHeight > height - padding) { // Stop when bottom of rect reaches bottom padding
    // Save final frame to a temporary file
    finalImagePath = "final_frame_temp.png";
    save(finalImagePath);
    noLoop();
    return;
  }
}

void keyPressed() {
  if (key == 's' || key == 'S') {
    saveImage();
  } else if (key == ENTER || key == '\n') {
    resetSketch();
  } else if (key == 'r' || key == 'R') {
    // Reset to a blank canvas
    displayBuffer.beginDraw();
    displayBuffer.background(0);
    displayBuffer.endDraw();
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
  setRandomSeed();
  // Reset to a blank display buffer
  displayBuffer.beginDraw();
  displayBuffer.background(0);
  
  // Redraw initial circle
  displayBuffer.fill(255, 100, 100);
  displayBuffer.noStroke();
  displayBuffer.ellipse(width/2, height/2, 400, 400);
  displayBuffer.endDraw();
  
  // Reset counters and flags
  frameCount = 0;
  finalImagePath = null;
  loop();
}

// Add new content on mouse click without resetting blur
void mousePressed() {
  // Draw directly to display buffer (don't use the source buffer)
  displayBuffer.beginDraw();
  displayBuffer.fill(random(100, 255), random(100, 255), random(100, 255));
  displayBuffer.noStroke();
  displayBuffer.ellipse(mouseX, mouseY, 100, 100);
  displayBuffer.endDraw();
}