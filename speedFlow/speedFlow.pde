// Configuration parameters
final int WIDTH = 1000;
final int HEIGHT = 1000;

// Global variables
String finalImagePath = null;
long flowSeed = 0; // Seed for the random number generator

void settings() {
  size(WIDTH, HEIGHT, P2D);
  smooth(8);
}

void setup() {
  colorMode(RGB, 255, 255, 255);
  resetSketch();
}

void setNewSeed() {
  flowSeed = System.currentTimeMillis();
  noiseSeed(flowSeed);
  randomSeed(flowSeed);
}

void draw() {
  // Your generative art code here

  // Affichage de la seed en haut à gauche, discret
  fill(255, 180); // Blanc légèrement transparent
  textAlign(LEFT, TOP);
  textSize(9);
  text("s:" + flowSeed, 6, 6);

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
  } else if (key == 'n' || key == 'N') {
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
  setNewSeed();
  background(0);
  frameCount = 0;
  finalImagePath = null;
  loop();
}
