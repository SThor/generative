// Configuration parameters
final int WIDTH = 1000;
final int HEIGHT = 1000;
final float BLUR_AMOUNT = 1.0; // Adjust for stronger/weaker blur effect

// Graphics objects
PGraphics sourceBuffer;  // Buffer to hold original content
PGraphics displayBuffer; // Buffer that gets progressively blurred
PShader blurShader;      // Optional custom shader

// Global variables
String finalImagePath = null;

void settings() {
  size(WIDTH, HEIGHT, P2D);
}

void setup() {
  colorMode(RGB, 255, 255, 255, 100);
  
  // Create our buffers with proper initialization
  sourceBuffer = createGraphics(WIDTH, HEIGHT, P2D);
  displayBuffer = createGraphics(WIDTH, HEIGHT, P2D);
  
  // Initialize both buffers with background
  sourceBuffer.beginDraw();
  sourceBuffer.colorMode(RGB, 255, 255, 255, 100);
  sourceBuffer.background(0);
  sourceBuffer.endDraw();
  
  displayBuffer.beginDraw();
  displayBuffer.background(0);
  displayBuffer.endDraw();
  
  // Optional: Load and configure blur shader
  blurShader = loadShader("blur.glsl");
  blurShader.set("resolution", float(WIDTH), float(HEIGHT));
  blurShader.set("kernelSize", 7);
  
  // Draw initial content directly to display buffer
  displayBuffer.beginDraw();
  displayBuffer.fill(255, 100, 100);
  displayBuffer.noStroke();
  displayBuffer.ellipse(width/2, height/2, 400, 400);
  displayBuffer.endDraw();
  
  // Clear the main canvas
  background(0);
}

void draw() {
  // Display the current state of our buffer
  image(displayBuffer, 0, 0);
  
  // Apply blur to the display buffer
  displayBuffer.beginDraw();
  
  // Use built-in blur filter
  // displayBuffer.filter(BLUR, BLUR_AMOUNT);  
  
  // Alternative: Use custom shader
  displayBuffer.filter(blurShader);
  
  displayBuffer.endDraw();
  
  // Add frame counter overlay
  fill(0);
  rect(0, 0, 200, 20);
  fill(255);
  text("Frame: " + frameCount, 10, 20);
  
  if (false) { // Replace with your condition to stop drawing
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