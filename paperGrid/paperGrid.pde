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
final float CROSSHATCH_SPACING_LOW = 5; // Spacing between crosshatch lines
final float CROSSHATCH_SPACING_HIGH = 15; // Spacing between crosshatch lines
final float SPIRAL_ARMS = 15; // Number of arms in the spiral

final int VARIATION_GOLD = 0;
final int VARIATION_SILVER = 1;
final int VARIATION_BANDS = 2;
final int VARIATION_LINES = 3;
final int VARIATION_RANDOM = 4;
final int VARIATION_BLOOD = 5;
final int VARIATION_ACID = 6;
final int VARIATION_RANDOM_LOW = 7;
final int VARIATION_CROSSHATCH_LOW = 8;
final int VARIATION_CROSSHATCH_HIGH = 9;
final int VARIATION_RIPPLE = 10;
final int VARIATION_SPIRAL = 11;

// Line drawing configuration
final float LINE_SPREAD = 3.0f;
final int NUM_LINE_POINTS = 5;
final int NUM_PASSES = 5;

// Class to track special cell information
class SpecialCell {
  float centerX, centerY;
  int variation;
  
  SpecialCell(float x, float y, int v) {
    centerX = x;
    centerY = y;
    variation = v;
  }
}

// Global variables
String finalImagePath = null;
PaperAndPencil pp;
ArrayList<Integer> availableVariations;
ArrayList<SpecialCell> specialCells;
boolean showLine; // Flag to control which effect is shown
PGraphics mask; // Mask for the Paper and Pencil library
long seed = 0; // Seed for the random number generator
boolean debug = false; // Debug mode to simplify drawing

int BACKGROUND_COLOR = color(350, 100); // Background color in HSB(360, 100, 100)
int OUTLINE_COLOR = color(0, 0, 0, 70); // Color for the outline of the rectangles
int CONTENT_COLOR = color(0, 0, 0, 30); // Color for the content inside the rectangles

float RIPPLE_SCALE = 1.0;

void settings() {
  size(WIDTH, HEIGHT, P2D);
  smooth(8);
  // Set up the Paper and Pencil library
  pp = new PaperAndPencil(this);
  Ok.p = this;
}

void setup() {
  seed();
  colorMode(HSB, 360, 100, 100, 100);
  BACKGROUND_COLOR = color(350, 100);
  OUTLINE_COLOR = color(0, 0, 0, 70);
  CONTENT_COLOR = color(0, 0, 0, 30);
  
  specialCells = new ArrayList<SpecialCell>();
  resetVariations();
}

void resetVariations() {
  RIPPLE_SCALE = (int)random(5, 20);
  
  specialCells.clear();
  
  // Randomly choose between line and falling cells effect
  showLine = random(1) < 0.5;
  
  // Create array of all possible special variations
  ArrayList<Integer> allSpecialVariations = new ArrayList<Integer>();
  allSpecialVariations.add(VARIATION_GOLD);
  allSpecialVariations.add(VARIATION_SILVER);
  allSpecialVariations.add(VARIATION_RANDOM);
  allSpecialVariations.add(VARIATION_RANDOM_LOW);
  allSpecialVariations.add(VARIATION_BLOOD);
  allSpecialVariations.add(VARIATION_ACID);
  allSpecialVariations.add(VARIATION_CROSSHATCH_LOW);
  allSpecialVariations.add(VARIATION_CROSSHATCH_HIGH);
  allSpecialVariations.add(VARIATION_RIPPLE);
  allSpecialVariations.add(VARIATION_SPIRAL);
  
  // Use Gaussian distribution constrained between 2 and the number of special variations
  int numVariations = (int)map(randomGaussian(), -2, 2, 2, allSpecialVariations.size()); // Map ±2 standard deviations to our range
  numVariations = constrain(numVariations, 2, allSpecialVariations.size());
  
  // Randomly select variations
  ArrayList<Integer> specialVariations = new ArrayList<Integer>();
  java.util.Collections.shuffle(allSpecialVariations);
  for (int i = 0; i < numVariations; i++) {
    specialVariations.add(allSpecialVariations.get(i));
  }
  
  // Create array of all possible positions and shuffle them
  ArrayList<Integer> positions = new ArrayList<Integer>();
  for (int i = 0; i < NUM_CELLS * NUM_CELLS; i++) {
    positions.add(i);
  }
  java.util.Collections.shuffle(positions);
  
  // Initialize grid with checkerboard pattern
  availableVariations = new ArrayList<Integer>();
  for (int row = 0; row < NUM_CELLS; row++) {
    for (int col = 0; col < NUM_CELLS; col++) {
      availableVariations.add(((row + col) % 2 == 0) ? VARIATION_BANDS : VARIATION_LINES);
    }
  }
  
  // Override random positions with special variations
  for (int i = 0; i < specialVariations.size(); i++) {
    int position = positions.get(i);
    int variation = specialVariations.get(i);
    availableVariations.set(position, variation);
    
    // Calculate cell coordinates for this position
    int row = position / NUM_CELLS;
    int col = position % NUM_CELLS;
    float cellX = col * (CELL_SIZE + SPACING);
    float cellY = row * (CELL_SIZE + SPACING);
    
    // Calculate actual center position including margins
    float centerX = MARGIN + cellX + CELL_SIZE/2;
    float centerY = MARGIN + cellY + CELL_SIZE/2;
    specialCells.add(new SpecialCell(centerX, centerY, variation));
  }
}

void drawRect(int col, int row) {
  float cellX = col * (CELL_SIZE + SPACING);
  float cellY = row * (CELL_SIZE + SPACING);
  
  // Get variation for this cell
  int index = row * NUM_CELLS + col;
  int variation = availableVariations.get(index);
  
  pushMatrix();
  translate(cellX, cellY);
  mask.pushMatrix();
  mask.translate(cellX, cellY);
  
  translate(0, row * col * 3);
  rotate(row * col * 0.015);
  mask.translate(0, row * col * 3);
  mask.rotate(row * col * 0.015);

  pp.setPencilColor(CONTENT_COLOR);
  pp.setPencilSpread(1.5f);
  for (int x = 0; x < CELL_SIZE+1; x++) {
    for (int y = 0; y < CELL_SIZE+1; y++) {
      switch(variation) {
        case VARIATION_GOLD:
          drawGoldBands(x, y);
          break;
        case VARIATION_SILVER:
          drawSilverBands(x, y);
          break;
        case VARIATION_BANDS:
          drawBands(x, y);
          drawBands(x, y);
          break;
        case VARIATION_LINES:
          drawLines(x, y);
          break;
        case VARIATION_RANDOM:
          fill(pp.getPencilColor());
          pp.dot(x, y);
          if ((row + col) % 2 == 0) {
            drawBands(x, y);
          } else {
            drawLines(x, y);
          }
          break;
        case VARIATION_RANDOM_LOW:
          if (random(5) < 1) {
            fill(pp.getPencilColor());
            pp.dot(x, y);
          }
          if ((row + col) % 2 == 0) {
            drawBands(x, y);
          } else {
            drawLines(x, y);
          }
          break;
        case VARIATION_BLOOD:
          drawBlood(x, y);
          break;
        case VARIATION_ACID:
          drawAcid(x, y);
          break;
        case VARIATION_CROSSHATCH_LOW:
          drawCrosshatch(x, y, CROSSHATCH_SPACING_LOW);
          break;
        case VARIATION_CROSSHATCH_HIGH:
          drawCrosshatch(x, y, CROSSHATCH_SPACING_HIGH);
          break;
        case VARIATION_RIPPLE:
          drawRipple(x, y);
          break;
        case VARIATION_SPIRAL:
          drawSpiral(x, y);
          break;
      }
    }
  }

  pp.setPencilSpread(2f);
  pp.setPencilColor(OUTLINE_COLOR);
  pp.rect(0, 0, CELL_SIZE, CELL_SIZE);

  mask.fill(255);
  mask.stroke(255, 128);
  mask.rect(2, 2, CELL_SIZE-4, CELL_SIZE-4);

  popMatrix();
  mask.popMatrix();
}

void drawGoldBands(float x, float y) {
  float goldNoise = noise(x * GOLD_NOISE_SCALE, y * GOLD_NOISE_SCALE + 1000); // Offset noise for gold effect
  // Use existing noise value to create metallic gold variations
  float hue = map(goldNoise, 0f, 1f, 40f, 60f);        // Vary between yellow-gold (45) and orange-gold (55)
  float brightness = map(goldNoise, 0f, 1f, 80f, 100f);  // Vary brightness 90-100 for metallic sheen
  pp.setPencilColor(color(hue, 100, brightness, 70));
  fill(pp.getPencilColor());

  drawBands(x, y); // Draw the bands with the gold color
}

void drawSilverBands(float x, float y) {
  float silverNoise = noise(x * GOLD_NOISE_SCALE, y * GOLD_NOISE_SCALE + 2000); // Offset noise for silver effect
  // Use existing noise value to create metallic silver variations
  float brightness = map(silverNoise, 0f, 1f, 80f, 100f); // Vary brightness for metallic sheen
  pp.setPencilColor(color(240f, 4, brightness, 70)); // Slight blue hue and low saturation for silver
  fill(pp.getPencilColor());

  drawBands(x, y); // Draw the bands with the silver color
}

void drawBlood(float x, float y) {
  float bloodNoise = noise(x * GOLD_NOISE_SCALE, y * GOLD_NOISE_SCALE + 3000); // Offset noise for blood effect
  // Use existing noise value to create blood variations
  float hue = map(bloodNoise, 0f, 1f, -10f, 10f); // Restrict hue to dark red range
  float saturation = map(bloodNoise, 0f, 1f, 80f, 100f); // High saturation for rich red
  float brightness = map(bloodNoise, 0f, 1f, 30f, 60f); // Lower brightness for dark red
  pp.setPencilColor(color(hue, saturation, brightness, 70)); // Dark red with high saturation
  fill(pp.getPencilColor());

  drawBands(x, y); // Draw the bands with the blood color
  drawBands(x, y); // Draw the bands with the blood color
  drawBands(x, y); // Draw the bands with the blood color
}

void drawAcid(float x, float y) {
  float acidNoise = noise(x * GOLD_NOISE_SCALE, y * GOLD_NOISE_SCALE + 3000); // Offset noise for blood effect
  // Use existing noise value to create blood variations
  float hue = map(acidNoise, 0f, 1f, 0f, 360f); // Vary hue for blood color
  float saturation = map(acidNoise, 0f, 1f, 50f, 100f); // Vary saturation for blood effect
  pp.setPencilColor(color(hue, saturation, 100, 70)); // Bright red with high saturation
  fill(pp.getPencilColor());

  drawBands(x, y); // Draw the bands with the blood color
}

void drawBands(float x, float y) {
  fill(pp.getPencilColor());
  
  if (debug) {
    // In debug mode, just draw a simple dot
    pp.dot(x, y);
    pp.dot(x, y);
    return;
  }
  
  // Normal drawing mode
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
    fill(pp.getPencilColor());
    pp.dot(x, y);
    pp.dot(x, y);
    pp.dot(x, y);
  }
}

void drawCrosshatch(float x, float y, float spacing) {
  // diagonal lines in one direction
  if ((x + y) % spacing == 0) {
    drawBands(x, y);
  }
  
  // diagonal lines in other direction
  if ((x - y) % spacing == 0) {
    drawBands(x, y);
  }
}

void drawRipple(float x, float y) {
  float centerX = CELL_SIZE/2;
  float centerY = CELL_SIZE/2;
  float dist = dist(x, y, centerX, centerY);
  float wave = sin(dist * RIPPLE_SCALE);
  
  if (wave > 0) {
    drawBands(x, y);
  }
}

void drawSpiral(float x, float y) {
  float centerX = CELL_SIZE/2;
  float centerY = CELL_SIZE/2;
  float dx = x - centerX;
  float dy = y - centerY;
  float angle = atan2(dy, dx);
  
  // Normalize angle to 0-TWO_PI range
  if (angle < 0) angle += TWO_PI;
  
  float dist = dist(x, y, centerX, centerY);
  
  float spiral = angle * SPIRAL_ARMS - dist;
  
  if (sin(spiral) < 0) { // Check if the spiral value is below the threshold
    drawBands(x, y);
  }
}

void drawLine() {
  if (specialCells.size() == 0) return;
  
  pp.setPencilSpread(LINE_SPREAD);
  
  // Randomly select a base hue for this line
  float baseHue = random(360);
  float baseSaturation = random(60, 100);
  float baseBrightness = random(40, 80);
  
  // Sort special cells left to right
  java.util.Collections.sort(specialCells, new java.util.Comparator<SpecialCell>() {
    public int compare(SpecialCell a, SpecialCell b) {
      return Float.compare(a.centerX, b.centerX);
    }
  });
  
  // Create points array
  float[] points = new float[specialCells.size() * 2];
  for (int i = 0; i < specialCells.size(); i++) {
    SpecialCell cell = specialCells.get(i);
    points[i*2] = cell.centerX;
    points[i*2 + 1] = cell.centerY;
  }
    
  // Draw multiple passes
  for (int pass = 0; pass < NUM_PASSES; pass++) {
    float hue = baseHue + random(-20, 20);
    float saturation = baseSaturation + random(-5, 5);
    float brightness = baseBrightness + random(-5, 5);
    pp.setPencilColor(color(hue, saturation, brightness, 80));
    
    float[] offsetPoints = new float[points.length];
    float offset = 3;
    
    for (int i = 0; i < points.length; i++) {
      offsetPoints[i] = points[i] + random(-offset, offset);
    }

    pp.spline(offsetPoints, true, false);
  }
}

void draw() {
  background(BACKGROUND_COLOR);
  pp.paper();
  mask = pp.resetMask();

  pushMatrix();
  translate(MARGIN, MARGIN);
  mask.pushMatrix();
  mask.translate(MARGIN, MARGIN);

  // Draw a grid of rectangles
  for (int row = 0; row < NUM_CELLS; row++) {
    for (int col = 0; col < NUM_CELLS; col++) {
      drawRect(col, row);
    }
  }
  popMatrix();
  mask.popMatrix();
  
  // Reverse the mask
  mask.loadPixels();
  for (int i = 0; i < mask.pixels.length; i++) {
    int alpha = (mask.pixels[i] >> 24) & 0xFF;  // Extract alpha
    alpha = 255 - alpha;  // Invert alpha (0->255, 255->0)
    mask.pixels[i] = (alpha << 24) | (mask.pixels[i] & 0x00FFFFFF);  // Put alpha back
  }
  mask.updatePixels();

  pp.useMask();
  drawLine();

  fill(OUTLINE_COLOR);
  textSize(6);
  text("" + seed, 5, height - 5);
  text("" + RIPPLE_SCALE, width - 15, height - 5);
  
  if (true) {
    // Save final frame to a temporary file
    finalImagePath = "final_frame_temp.png";
    save(finalImagePath);
    noLoop();
    return;
  }
}

void seed() {
  // Set a random seed for the noise function
  seed = System.currentTimeMillis();
  noiseSeed(seed);
  randomSeed(seed);
}

void keyPressed() {
  if (key == 's' || key == 'S') {
    saveImage();
  } else if (key == ENTER || key == '\n') {
    resetSketch();
  } else if (key == 'd' || key == 'D') {
    debug = !debug; // Toggle debug mode
    loop(); // Force redraw with new debug setting
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
  seed();
  frameCount = 0;
  finalImagePath = null;
  resetVariations();
  loop();
}
