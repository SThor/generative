import paperandpencil.*;
import yash.oklab.*; 

// Configuration parameters
final int WIDTH = 1000;
final int HEIGHT = 1000;
final int MARGIN = 80; // Margin around the grid
final int SPACING = 30; // Space between cells
final int NUM_CELLS = 4; // Number of cells in each row and column
final int CELL_SIZE = (WIDTH - 2 * MARGIN - (NUM_CELLS - 1) * SPACING) / NUM_CELLS; // Size of each cell
final float NOISE_SCALE = 0.008; // Scale for the noise function
final float GOLD_NOISE_SCALE = 0.02; // Scale for the gold noise function

int BACKGROUND_COLOR = color(350, 100); // Background color in HSB(360, 100, 100)
int OUTLINE_COLOR = color(0, 0, 0, 70); // Color for the outline of the rectangles
int CONTENT_COLOR = color(0, 0, 0, 30); // Color for the content inside the rectangles

// Global variables
String finalImagePath = null;
PaperAndPencil pp;

void settings() {
  size(WIDTH, HEIGHT, P2D);
  smooth(8);
  // Set up the Paper and Pencil library
  pp = new PaperAndPencil(this);
  Ok.p = this;
}

void setup() {
  colorMode(HSB, 360, 100, 100, 100);
  BACKGROUND_COLOR = color(350, 100); // Set the background color using HSB
  //BACKGROUND_COLOR = Ok.HSL(350, 100, 100); // Set the background color using OkLab
  OUTLINE_COLOR = color(0, 0, 0, 70); // Set the outline color using HSB
  CONTENT_COLOR = color(0, 0, 0, 30); // Set the content color using HSB
}

void drawRect(int col, int row) {
  float cellX = col * (CELL_SIZE + SPACING);
  float cellY = row * (CELL_SIZE + SPACING);
  pushMatrix();
  translate(cellX, cellY);
  translate(0, row * col * 3); // Translate based on row and column
  rotate(row * col * 0.015); // Rotate based on row and column

  // Draw patterns with the selected color
  pp.setPencilColor(CONTENT_COLOR);
  pp.setPencilSpread(1.5f);
  for (int x = 0; x < CELL_SIZE+1; x++) {
    for (int y = 0; y < CELL_SIZE+1; y++) {
      if ((col == 1 && row == 2)) {
        drawSilverBands(x, y);
      } else if ((col == 3 && row == 1)) {
        drawGoldBands(x, y);
      } else if ((col + row) % 2 == 0) {
        drawBands(x, y);
      } else {
        drawLines(x, y);
      }
    }
  }

  pp.setPencilSpread(2f);
  pp.setPencilColor(OUTLINE_COLOR);
  pp.rect(0, 0, CELL_SIZE, CELL_SIZE);

  popMatrix();
}

void drawGoldBands(float x, float y) {
  float goldNoise = noise(x * GOLD_NOISE_SCALE, y * GOLD_NOISE_SCALE + 1000); // Offset noise for gold effect
  // Use existing noise value to create metallic gold variations
  float hue = map(goldNoise, 0f, 1f, 40f, 60f);        // Vary between yellow-gold (45) and orange-gold (55)
  float brightness = map(goldNoise, 0f, 1f, 80f, 100f);  // Vary brightness 90-100 for metallic sheen
  pp.setPencilColor(color(hue, 100, brightness, 70));

  drawBands(x, y); // Draw the bands with the gold color
}

void drawSilverBands(float x, float y) {
  float silverNoise = noise(x * GOLD_NOISE_SCALE, y * GOLD_NOISE_SCALE + 2000); // Offset noise for silver effect
  // Use existing noise value to create metallic silver variations
  float brightness = map(silverNoise, 0f, 1f, 80f, 100f); // Vary brightness for metallic sheen
  pp.setPencilColor(color(240f, 4, brightness, 70)); // Slight blue hue and low saturation for silver

  drawBands(x, y); // Draw the bands with the silver color
}

void drawBands(float x, float y) {
  float noise = noise(x * NOISE_SCALE, y * NOISE_SCALE);
  int contourLevel = round(noise * 10); // Convert 0-1 to 0-10 and round

  if (contourLevel % 2 == 0) { // Only draw on even levels
    pp.dot(x, y);
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
    pp.dot(x, y);
    pp.dot(x, y);
    pp.dot(x, y);
  }
}

void draw() {
  background(BACKGROUND_COLOR);
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
  noiseSeed(frameCount);
  frameCount = 0;
  finalImagePath = null;
  loop();
}
