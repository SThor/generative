import paperandpencil.*;

// Configuration parameters
final int WIDTH = 1000;
final int HEIGHT = 1000;

// Global variables
String finalImagePath = null;
PaperAndPencil pp;

void settings() {
  size(WIDTH, HEIGHT, P2D);
  smooth(8);
  // Set up the Paper and Pencil library
  pp = new PaperAndPencil(this);
}

void setup() {
  colorMode(RGB, 255, 255, 255);
  background(0);

  // Draw a grid of rectangles
  for (int i = 0; i < width; i += 50) {
    for (int j = 0; j < height; j += 50) {
      pp.setPencilColor(color(random(255), random(255), random(255), random(100, 255)));
      pp.rect(i, j, 50, 50);
    }
  }
}

void draw() {

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
