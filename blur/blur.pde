// Configuration parameters
final int WIDTH = 1000;
final int HEIGHT = 1000;

// Global variables
String finalImagePath = null;
PShader blurShader;

void settings() {
  size(WIDTH, HEIGHT);
}

void setup() {
  colorMode(RGB, 255, 255, 255, 100);
  background(0);

  fill(255, 100, 100);
  ellipse(width/2, height/2, 400, 400);
}

void draw() {
  filter(BLUR);

  fill(0);
  rect(0, 0, 200, 20);
  fill(255);
  text(""+frameCount, 10, 20);

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
