// Import la bibliothèque de palettes de couleurs
import nice.palettes.*;

// --- Configuration ---
final int WIDTH = 1000;
final int HEIGHT = 1000;
final int MARGIN = 100; // Marge en pixels autour du flow field
final int FLOW_GRID_SIZE = 30; // Nombre de cellules sur un axe
final float FLOW_NOISE_SCALE = 0.15; // Echelle du bruit pour le flow field
final float FLOW_VECTOR_LEN = 0.2; // Longueur du vecteur
final float FLOW_ARROW_SIZE = 10; // Taille de la flèche
final int PARTICLE_COUNT = 2000;
// Taille calculée des cellules de la grille
float CELL_WIDTH, CELL_HEIGHT;
// Centre de la grille
float CENTER_X, CENTER_Y;
// Poids pour les différents types de flow fields (noise, disk, diskBand, sinX)
final float[] FLOW_WEIGHTS = {1, 0, 0, 0};
// final float[] FLOW_WEIGHTS = {0.5, 0.5, 1};
// Paramètres pour la bande dans flowFieldVectorDiskBand
final float BAND_MIN = 0.3;
final float BAND_MAX = 0.6;

// Couleurs et palette
ColorPalette palette;       // Bibliothèque externe pour sélection de palettes
ColorRamp colorRamp;        // Interpolation avancée entre couleurs

// --- Global variables ---
String finalImagePath = null;
long flowSeed = 0; // Seed for le flow-field et random
boolean debug = false; // Affichage du flow-field
ArrayList<Particle> particles;
boolean lifespanActive = true; // Control variable for lifespan toggling
int paletteIndex = 0; // Index de la palette utilisée

// --- Processing setup ---
void settings() {
  size(WIDTH, HEIGHT, P2D);
  smooth(8);
}

void setup() {
  colorMode(RGB, 255, 255, 255);
  // Initialiser les dimensions des cellules et le centre
  CELL_WIDTH = float(WIDTH) / FLOW_GRID_SIZE;
  CELL_HEIGHT = float(HEIGHT) / FLOW_GRID_SIZE;
  CENTER_X = WIDTH / 2;
  CENTER_Y = HEIGHT / 2;
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
    // float x = random(MARGIN, WIDTH - MARGIN);
    // float y = random(MARGIN, HEIGHT - MARGIN);
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
  // Initialiser la rampe de couleurs
  initColors();
  clearAndRestartParticles();
}

// Initialisation des couleurs et de la palette
void initColors() {
  color[] paletteColors = { 
    color(255, 240, 150),  // jaune pastel
    color(30, 220, 140),   // vert fluo marin (moyen)
    color(10, 60, 120)     // bleu marin profond (rapide)
  };
  
  // Si on utilise la bibliothèque ColorPalette externe
  try {
    palette = new ColorPalette(this);
    paletteIndex = int(random(0, palette.getPaletteCount()));
    // Récupérer une palette de la bibliothèque externe
    paletteColors = palette.getPalette(paletteIndex);
  } catch (Exception e) {
    println("Bibliothèque ColorPalette non disponible, utilisation des couleurs par défaut");
  }

  // Option 1: Transitions uniformes
  colorRamp = new ColorRamp(paletteColors);
  
  // Option 2: Transitions personnalisées (décommentez pour avoir une répartition différente)
  //colorRamp = new ColorRamp(paletteColors, new float[] {0.1, 0.5, 0.7});
}

// --- Flow field ---

void drawFlowField() {
  stroke(100, 180);
  for (int gx = 0; gx < FLOW_GRID_SIZE; gx++) {
    for (int gy = 0; gy < FLOW_GRID_SIZE; gy++) {
      PVector pos = getCellPosition(gx, gy);
      PVector v = flowFieldVectorWeighted(gx, gy, FLOW_WEIGHTS);
      float x2 = pos.x + v.x;
      float y2 = pos.y + v.y;
      line(pos.x, pos.y, x2, y2);
      float angle = atan2(v.y, v.x);
      line(x2, y2, x2 - cos(angle + 0.3) * FLOW_ARROW_SIZE, y2 - sin(angle + 0.3) * FLOW_ARROW_SIZE);
      line(x2, y2, x2 - cos(angle - 0.3) * FLOW_ARROW_SIZE, y2 - sin(angle - 0.3) * FLOW_ARROW_SIZE);
    }
  }
  noStroke();
}

void drawRandomVariables() {
  // Préparation du texte de la seed pour calculer sa largeur
  float textH = 8; // Hauteur fixe pour le texte
  textSize(textH - 1);
  String seedText = "s:" + flowSeed + " p:" + paletteIndex;
  float textW = textWidth(seedText);

  // Positionnement dans le coin inférieur droit
  float x = WIDTH - textW - 5;
  float y = HEIGHT - textH - 5;

  // Extension de la palette autour du fond transparent
  float paletteMargin = 2;
  float swatchWidth = (textW + paletteMargin * 2) / colorRamp.colors.length;
  float swatchHeight = textH + paletteMargin * 2;
  for (int i = 0; i < colorRamp.colors.length; i++) {
    fill(colorRamp.colors[i]);
    noStroke();
    rect(x - paletteMargin + (i * swatchWidth), y - paletteMargin, swatchWidth, swatchHeight);
  }

  // Fond semi-transparent limité au texte
  fill(255, 200);
  noStroke();
  rect(x, y, textW, textH);

  // Affichage de la seed et du paletteIndex
  textAlign(LEFT, TOP);
  fill(0);
  text(seedText, x, y);
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

  drawRandomVariables();
  
  // Affichage du flow-field en mode debug
  if (debug) {
    drawFlowField();
    // Affichage de la marge
    noFill();
    stroke(180, 100);
    strokeWeight(1);
    rect(MARGIN, MARGIN, WIDTH - 2 * MARGIN, HEIGHT - 2 * MARGIN);
  }
  // (Autres affichages éventuels...)

  if (false) { // Replace with your condition to stop drawing
    // Save final frame to a temporary file
    finalImagePath = "final_frame_temp.png";
    save(finalImagePath);
    noLoop();
    return;
  }
}

// Calcule la position au centre d'une cellule de la grille
PVector getCellPosition(int gx, int gy) {
  float x = gx * CELL_WIDTH + CELL_WIDTH/2;
  float y = gy * CELL_HEIGHT + CELL_HEIGHT/2;
  return new PVector(x, y);
}

// Convertit une position (x,y) en indices de grille flottants (gx, gy)
PVector getGridIndices(float x, float y) {
  float gx = constrain(x / CELL_WIDTH, 0, FLOW_GRID_SIZE - 1);
  float gy = constrain(y / CELL_HEIGHT, 0, FLOW_GRID_SIZE - 1);
  return new PVector(gx, gy);
}

// Applique une interpolation bilinéaire entre 4 vecteurs
PVector bilinearInterpolation(PVector v00, PVector v10, PVector v01, PVector v11, float factorX, float factorY) {
  // Interpolation horizontale en haut
  PVector v0 = PVector.lerp(v00, v10, factorX);
  // Interpolation horizontale en bas
  PVector v1 = PVector.lerp(v01, v11, factorX);
  // Interpolation verticale entre les résultats
  return PVector.lerp(v0, v1, factorY);
}

// Retourne la direction du flow-field (normalisée) à une position flottante (x, y)
PVector getFlowFieldDirectionAt(float x, float y) {
  // On récupère les indices flottants pour trouver la position relative dans la grille
  PVector gridIndices = getGridIndices(x, y);
  
  // On récupère le coin supérieur gauche (entier)
  int gx0 = int(floor(gridIndices.x));
  int gy0 = int(floor(gridIndices.y));
    // Facteurs d'interpolation (position relative dans la cellule)
  float factorX = gridIndices.x - gx0;
  float factorY = gridIndices.y - gy0;
  
  // On s'assure de ne pas sortir des limites
  int gx1 = min(gx0 + 1, FLOW_GRID_SIZE - 1);
  int gy1 = min(gy0 + 1, FLOW_GRID_SIZE - 1);
  
  // On récupère les vecteurs des 4 coins
  PVector v00 = flowFieldVectorWeighted(gx0, gy0, FLOW_WEIGHTS);
  PVector v10 = flowFieldVectorWeighted(gx1, gy0, FLOW_WEIGHTS);
  PVector v01 = flowFieldVectorWeighted(gx0, gy1, FLOW_WEIGHTS);
  PVector v11 = flowFieldVectorWeighted(gx1, gy1, FLOW_WEIGHTS);
    // On applique l'interpolation bilinéaire
  PVector result = bilinearInterpolation(v00, v10, v01, v11, factorX, factorY);
  
  // Retourner le vecteur sans normalisation pour préserver son amplitude
  return result;
}

// --- Flow field vector functions ---
// Crée un vecteur avec un angle et une longueur donnés
PVector vectorFromAngle(float angle, float len) {
  return new PVector(cos(angle) * len, sin(angle) * len);
}

// Flow field basé sur le bruit de Perlin
PVector flowFieldVectorNoise(int gx, int gy) {
  float angle = noise(gx * FLOW_NOISE_SCALE, gy * FLOW_NOISE_SCALE, flowSeed * 0.00001) * TWO_PI * 2;
  return vectorFromAngle(angle, FLOW_VECTOR_LEN);
}

// 2. Flow field circulaire autour du centre
PVector flowFieldVectorDisk(int gx, int gy) {
  PVector pos = getCellPosition(gx, gy);
  float angle = atan2(pos.y-CENTER_Y, pos.x-CENTER_X) + HALF_PI;
  return vectorFromAngle(angle, FLOW_VECTOR_LEN);
}

// 3. Flow field disque avec bande à angle inversé
PVector flowFieldVectorDiskBand(int gx, int gy) {
  PVector pos = getCellPosition(gx, gy);
  float dx = pos.x - CENTER_X;  float dy = pos.y - CENTER_Y;
  float r = sqrt(dx*dx + dy*dy);
  float rNorm = r / (min(WIDTH, HEIGHT)/2.0);
  float angle;
  if (rNorm > BAND_MIN && rNorm < BAND_MAX) {
    angle = atan2(pos.y-CENTER_Y, pos.x-CENTER_X) - HALF_PI;  } else {
    angle = atan2(pos.y-CENTER_Y, pos.x-CENTER_X) + HALF_PI;
  }
  return vectorFromAngle(angle, FLOW_VECTOR_LEN);
}

// 4. Flow field en ondulations sinusoïdales horizontales
PVector flowFieldVectorSinX(int gx, int gy) {
  // Paramètres de l'ondulation
  float frequency = 0.05;  // Fréquence de l'ondulation
  float amplitude = 0.8;   // Force de l'ondulation
  
  // Position dans la grille
  PVector pos = getCellPosition(gx, gy);
  
  // Composante constante horizontale
  float vx = 1.0;
  
  // Composante verticale suivant la dérivée de sin(x)
  // La dérivée de sin(x) est cos(x)
  float vy = cos(pos.x * frequency) * amplitude;
    
  return new PVector(vx, vy).normalize().mult(FLOW_VECTOR_LEN);
}

// Combine plusieurs flowfields selon des poids
PVector flowFieldVectorWeighted(int gx, int gy, float[] weights) {
  PVector v = new PVector(0, 0);
  float total = 0;
  if (weights.length > 0) {
    v.add(PVector.mult(flowFieldVectorNoise(gx, gy), weights[0]));
    total += weights[0];
  }
  if (weights.length > 1) {
    v.add(PVector.mult(flowFieldVectorDisk(gx, gy), weights[1]));
    total += weights[1];
  }
  if (weights.length > 2) {
    v.add(PVector.mult(flowFieldVectorDiskBand(gx, gy), weights[2]));
    total += weights[2];
  }
  if (weights.length > 3) {
    v.add(PVector.mult(flowFieldVectorSinX(gx, gy), weights[3]));
    total += weights[3];
  }
  if (total > 0) v.div(total); // Normalise la somme pondérée
  return v;
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
