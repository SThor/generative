// --- Configuration ---
final int WIDTH = 1000;
final int HEIGHT = 1000;
final int FLOW_GRID_SIZE = 30; // Nombre de cellules sur un axe
final float FLOW_NOISE_SCALE = 0.15; // Echelle du bruit pour le flow field
final float FLOW_VECTOR_LEN = 0.4; // Longueur relative du vecteur (par rapport à la cellule)
final float FLOW_ARROW_SIZE = 4; // Taille de la flèche
final int PARTICLE_COUNT = 2000;

// --- Global variables ---
String finalImagePath = null;
long flowSeed = 0; // Seed for le flow-field et random
boolean debug = false; // Affichage du flow-field
ArrayList<Particle> particles;
boolean lifespanActive = true; // Control variable for lifespan toggling

// --- Processing setup ---
void settings() {
  size(WIDTH, HEIGHT, P2D);
  smooth(8);
}

void setup() {
  colorMode(RGB, 255, 255, 255);
  resetSketch();
}

// --- Initialisation & reset ---
void setNewSeed() {
  flowSeed = System.currentTimeMillis();
  noiseSeed(flowSeed);
  randomSeed(flowSeed);
}

void initParticles() {
  particles = new ArrayList<Particle>();
  for (int i = 0; i < PARTICLE_COUNT; i++) {
    float x = random(WIDTH);
    float y = random(HEIGHT);
    PVector flowDir = getFlowFieldDirectionAt(x, y);
    float speed = random(0.5, 2.5);
    PVector v0 = PVector.fromAngle(flowDir.heading()).mult(speed);
    particles.add(new Particle(x, y, v0));
  }
}

void clearAndRestartParticles() {
  background(255);
  randomSeed(flowSeed);
  noiseSeed(flowSeed);
  initParticles();
  frameCount = 0;
  finalImagePath = null;
  loop();
}

void resetSketch() {
  setNewSeed();
  clearAndRestartParticles();
}

// --- Flow field ---
float flowFieldAngle(int gx, int gy) {
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
  stroke(100, 180);
  for (int gx = 0; gx < FLOW_GRID_SIZE; gx++) {
    for (int gy = 0; gy < FLOW_GRID_SIZE; gy++) {
      float x = gx * cellW + cellW/2;
      float y = gy * cellH + cellH/2;
      PVector v = flowFieldVector(gx, gy, cellW, cellH);
      float x2 = x + v.x;
      float y2 = y + v.y;
      line(x, y, x2, y2);
      float angle = atan2(v.y, v.x);
      line(x2, y2, x2 - cos(angle + 0.3) * FLOW_ARROW_SIZE, y2 - sin(angle + 0.3) * FLOW_ARROW_SIZE);
      line(x2, y2, x2 - cos(angle - 0.3) * FLOW_ARROW_SIZE, y2 - sin(angle - 0.3) * FLOW_ARROW_SIZE);
    }
  }
  noStroke();
}

// --- Draw loop ---
void draw() {
  // Affichage des particules
  for (Particle particle : particles) {
    // Récupérer la direction du flow-field à la position de la particule (normalisé)
    PVector flowDirection = getFlowFieldDirectionAt(particle.pos.x, particle.pos.y);
    particle.update(flowDirection, particles);
    particle.display();
  }
  // Affichage de la seed
  fill(255, 180);
  textAlign(LEFT, TOP);
  textSize(9);
  text("s:" + flowSeed, 6, 6);
  // Affichage du flow-field en mode debug
  if (debug) drawFlowField();
  // (Autres affichages éventuels...)

  if (false) { // Replace with your condition to stop drawing
    // Save final frame to a temporary file
    finalImagePath = "final_frame_temp.png";
    save(finalImagePath);
    noLoop();
    return;
  }
}

// Retourne la direction du flow-field (normalisée) à une position flottante (x, y)
PVector getFlowFieldDirectionAt(float x, float y) {
  float cellW = float(WIDTH) / FLOW_GRID_SIZE;
  float cellH = float(HEIGHT) / FLOW_GRID_SIZE;
  int gx = int(constrain(x / cellW, 0, FLOW_GRID_SIZE - 1));
  int gy = int(constrain(y / cellH, 0, FLOW_GRID_SIZE - 1));
  float angle = flowFieldAngle(gx, gy);
  return new PVector(cos(angle), sin(angle)); // Normalisé
}

// --- Events ---
void keyPressed() {
  if (key == 's' || key == 'S') {
    saveImage();
  } else if (key == 'n' || key == 'N') {
    resetSketch();
  } else if (key == 'd' || key == 'D') {
    debug = !debug;
    clearAndRestartParticles();
  } else if (key == 'l' || key == 'L') {
    lifespanActive = !lifespanActive;
  // } else if (key == 'o' || key == 'O') {
  //   Particle.useOpacity = !Particle.useOpacity;
  // } else if (key == 'h' || key == 'H') {
  //   Particle.useThickness = !Particle.useThickness;
  }
}

void saveImage() {
  String filename = year() + "-" + month() + "-" + day() + "-" + hour() + "-" + minute() + "-" + second() + ".png";
  if (finalImagePath != null) {
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
