// Configuration parameters
final int WIDTH = 1000;
final int HEIGHT = 1000;
final int STROKE_WEIGHT = 1;
final int NUM_COLORS = 3;

// Global variables
int originX, originY;
color[] colors = new color[NUM_COLORS];
String finalImagePath = null;

void settings() {
  size(WIDTH, HEIGHT, P2D);
  smooth(8);
}

void setup() {
  colorMode(RGB, 255, 255, 255);
  originX = WIDTH / 2;
  originY = HEIGHT / 2;
  // Initialize array with random colors
  for (int i = 0; i < colors.length; i++) {
    colors[i] = color(random(255), random(255), random(255));
  }
}

void draw() {
  noFill();
  int radius = frameCount * STROKE_WEIGHT;
  strokeWeight(STROKE_WEIGHT + 1);
  
  if (shouldStopDrawing(radius)) {
    // Save final frame to a temporary file
    finalImagePath = "final_frame_temp.png";
    save(finalImagePath);
    noLoop();
    return;
  }
  
  drawColorCircle(radius);
  drawColorPalette();
}

boolean shouldStopDrawing(int radius) {
  float maxRadius = sqrt(sq(WIDTH/2) + sq(HEIGHT/2));
  return radius >= maxRadius;
}

void drawColorCircle(int radius) {
  float angleIncrement = 1.0 / radius;
  float angleShift = calculateAngleShift(radius);
  
  for (float angle = 0; angle < TWO_PI; angle += angleIncrement) {
    float shiftedAngle = (angle + angleShift + TWO_PI) % TWO_PI;
    color c = getInterpolatedColor(angle);
    stroke(c);
    
    PVector point = calculatePoint(radius, shiftedAngle);
    point(point.x, point.y);
  }
}

float calculateAngleShift(int radius) {
  // Base noise value
  float noise = noise(frameCount / 200.0) - 0.5;
  
  // Calculate min and max radius
  float minRadius = WIDTH / 2; // Starting radius
  float maxRadius = sqrt(sq(WIDTH/2) + sq(HEIGHT/2));
  
  // Calculate progress (0 to 1)
  float progress = map(radius, minRadius, maxRadius, 0, 1);
  
  // Peak progress point where maximum shift should occur
  float peakProgress = 0.1;
  
  // Maximum physical displacement allowed (in pixels)
  float maxDisplacement = 100; // Adjust as needed
  
  float angleShift;
  if (progress <= peakProgress) {
    // From 0 to peakProgress: Increase the angular shift
    float growthFactor = progress / peakProgress;
    angleShift = noise * growthFactor;
  } else {
    // After peakProgress: Maintain consistent physical displacement
    // by decreasing angular shift as radius increases
    angleShift = (maxDisplacement / radius) * noise;
  }
  
  return angleShift;
}

color getInterpolatedColor(float angle) {
  float normalizedAngle = angle / TWO_PI;
  float colorPosition = normalizedAngle * colors.length;
  int color1Index = floor(colorPosition) % colors.length;
  int color2Index = (color1Index + 1) % colors.length;
  
  // Obtenir la partie fractionnaire
  float t = colorPosition - floor(colorPosition);
  
  // Appliquer la fonction pour transitions franches
  float lerpAmount = sharpTransition(t);
  
  return lerpColor(colors[color1Index], colors[color2Index], lerpAmount);
}

// Fonction pour des transitions plus franches
float sharpTransition(float t) {
  // Contrôle la netteté des transitions (>1 = plus net, <1 = plus doux)
  float sharpness = 2.5;
  sharpness = 100;
  
  if (t < 0.5) {
    // Première moitié de la transition
    return 0.5 * pow(2 * t, sharpness);
  } else {
    // Seconde moitié de la transition
    return 1 - 0.5 * pow(2 * (1 - t), sharpness);
  }
  
  // Alternatives pour expérimentation :
  // return pow(t, sharpness); // Simple power function (transitions franches quand sharpness > 1)
  // return t < 0.5 ? 0 : 1; // Transition en escalier (ultra franche, pas d'interpolation)
  // return round(t); // Arrondi (franche sans paramètre)
}

// Ancienne fonction smoothstep (maintenue comme référence)
float smoothstep(float t) {
  // Variante classique: 3t² - 2t³
  // return t * t * (3 - 2 * t);
  
  // Autres variantes possibles (en commentaire):
  // return t * t * t * (t * (t * 6 - 15) + 10); // Smootherstep (5t⁵ - 15t⁴ + 10t³)
  return 0.5 - 0.5 * cos(PI * t); // Variante basée sur cosinus
}

PVector calculatePoint(int radius, float angle) {
  float x = originX + radius * cos(angle);
  float y = originY + radius * sin(angle);
  return new PVector(x, y);
}

void drawColorPalette() {
  int squareSize = 5;
  int y = HEIGHT - squareSize;
  
  // Draw color squares
  strokeWeight(1);
  for (int i = 0; i < colors.length; i++) {
    fill(colors[i]);
    noStroke();
    rect(i * squareSize, y, squareSize, squareSize);
  }
}

void keyPressed() {
  if (key == 's' || key == 'S') {
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
  } else if (key == ENTER || key == '\n') {
    resetSketch();
  }
}

void resetSketch() {
  // Clear the canvas
  background(0);
  
  // Reset variables
  frameCount = 0;
  finalImagePath = null;
  
  // Generate new random colors
  for (int i = 0; i < colors.length; i++) {
    colors[i] = color(random(255), random(255), random(255));
  }
  
  // Restart drawing
  loop();
}
