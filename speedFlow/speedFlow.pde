// Configuration parameters
final int WIDTH = 1000;
final int HEIGHT = 1000;

// Global variables
String finalImagePath = null;
long flowSeed = 0; // Seed for the random number generator
boolean debug = false; // Affichage du flow-field

// --- Flow field configuration ---
final int FLOW_GRID_SIZE = 20; // Nombre de cellules sur un axe
final float FLOW_NOISE_SCALE = 0.15; // Echelle du bruit pour le flow field
final float FLOW_VECTOR_LEN = 0.4; // Longueur relative du vecteur (par rapport à la cellule)
final float FLOW_ARROW_SIZE = 4; // Taille de la flèche

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

// --- Flow field ---
float flowFieldAngle(int gx, int gy) {
  // Renvoie l'angle du flow field à la grille (gx, gy)
  return noise(gx * FLOW_NOISE_SCALE, gy * FLOW_NOISE_SCALE, flowSeed * 0.00001) * TWO_PI * 2;
}

PVector flowFieldVector(int gx, int gy, float cellW, float cellH) {
  float angle = flowFieldAngle(gx, gy);
  float len = cellW * FLOW_VECTOR_LEN;
  return new PVector(cos(angle) * len, sin(angle) * len);
}

void drawFlowField() {
  float cellW = float(WIDTH) / FLOW_GRID_SIZE;
  float cellH = float(HEIGHT) / FLOW_GRID_SIZE;
  stroke(100, 180); // gris clair, discret
  for (int gx = 0; gx < FLOW_GRID_SIZE; gx++) {
    for (int gy = 0; gy < FLOW_GRID_SIZE; gy++) {
      float x = gx * cellW + cellW/2;
      float y = gy * cellH + cellH/2;
      PVector v = flowFieldVector(gx, gy, cellW, cellH);
      float x2 = x + v.x;
      float y2 = y + v.y;
      line(x, y, x2, y2);
      // Petite flèche
      float angle = atan2(v.y, v.x);
      line(x2, y2, x2 - cos(angle + 0.3) * FLOW_ARROW_SIZE, y2 - sin(angle + 0.3) * FLOW_ARROW_SIZE);
      line(x2, y2, x2 - cos(angle - 0.3) * FLOW_ARROW_SIZE, y2 - sin(angle - 0.3) * FLOW_ARROW_SIZE);
    }
  }
  noStroke();
}

void draw() {
  // Your generative art code here

  // Affichage de la seed en haut à gauche, discret
  fill(255, 180); // Blanc légèrement transparent
  textAlign(LEFT, TOP);
  textSize(9);
  text("s:" + flowSeed, 6, 6);

  // Affichage du flow-field en mode debug
  if (debug) {
    drawFlowField();
  }

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
  } else if (key == 'd' || key == 'D') {
    debug = !debug;
    redraw();
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
