import paperandpencil.*;

// Configuration parameters
final int WIDTH = 1000;
final int HEIGHT = 1000;
final int MARGIN = 50;
final int SPACING = 20; // Space between cells
final int NUM_CELLS = 4; // Number of cells in each row and column
final int CELL_SIZE = (WIDTH - 2 * MARGIN - (NUM_CELLS - 1) * SPACING) / NUM_CELLS; // Size of each cell
final int OUTLINE_COLOR = color(0, 0, 0, 70); // Color for the outline of the rectangles
final float NOISE_SCALE = 0.008; // Scale for the noise function

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
  colorMode(HSB, 360, 100, 100, 100);
}

void drawRect(int col, int row) {
  float cellX = col * (CELL_SIZE + SPACING);
  float cellY = row * (CELL_SIZE + SPACING);
  pushMatrix();
  translate(cellX, cellY);
  pp.setPencilColor(OUTLINE_COLOR);
  pp.rect(0, 0, CELL_SIZE, CELL_SIZE);

  for (int x = 0; x < CELL_SIZE+1; x++) {
    for (int y = 0; y < CELL_SIZE+1; y++) {
      if ((col + row) % 2 == 0) {
        drawBands(x, y);
      } else {
        drawLines(x, y);
      }
    }
  }
  popMatrix();
}

void drawBands(float x, float y) {
  float noise = noise(x * NOISE_SCALE, y * NOISE_SCALE);
  int contourLevel = round(noise * 10); // Convert 0-1 to 0-10 and round
      
  if (contourLevel % 2 == 0) { // Only draw on even levels
    pp.setPencilColor(color(0, 0, 0, noise * 100)); // Set color based on noise
    // pp.setPencilSpread(1);
    pp.dot(x, y);
  }
}

void drawLines(float x, float y) {
  float noise = noise(x * NOISE_SCALE, y * NOISE_SCALE);
  float noiseRight = noise((x + 1) * NOISE_SCALE, y * NOISE_SCALE);
  float noiseDown = noise(x * NOISE_SCALE, (y + 1) * NOISE_SCALE);
  
  int currentLevel = round(noise * 10);
  int rightLevel = round(noiseRight * 10);
  int downLevel = round(noiseDown * 10);
  
  // Draw a dot if we're on a contour line boundary
  if (currentLevel != rightLevel || currentLevel != downLevel) {
    pp.setPencilColor(color(0, 0, 0, 70));
    pp.setPencilSpread(2f);
    pp.dot(x, y);
  }
}

void draw() {
  background(350, 100);
  pp.paper();
  pushMatrix();
  translate(MARGIN, MARGIN);

  // Draw a grid of rectangles
  for (int row = 0; row < NUM_CELLS; row++) {
    for (int col = 0; col < NUM_CELLS; col++) {
      drawRect(col, row);
    }
  }
  popMatrix();
  
  if (true) {
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
  frameCount = 0;
  finalImagePath = null;
  loop();
}
