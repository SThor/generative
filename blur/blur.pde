// Configuration parameters
final int WIDTH = 1000;
final int HEIGHT = 1000;

// Animation and layout constants
final float PADDING = 100;
final float RECT_WIDTH_RATIO = 0.25;
final float RECT_HEIGHT_RATIO = 0.25;
final float RECT_CORNER_RADIUS = 20;
final float HUE_SPEED = 0.1;
final float OSCILLATION_SPEED = 0.03;
final int OVERLAY_LEFT_WIDTH = 200;
final int OVERLAY_TOP_HEIGHT = 20;
final int OVERLAY_RIGHT_WIDTH = 250;
final int BLUR_KERNEL_SIZE = 7;
final float BLUR_SIGMA_FACTOR = 0.1;

PGraphics displayBuffer; // Buffer that gets updated and displayed
PShader blurShader; // Circular blur shader

String finalImagePath = null;
long seed = 0;
color backgroundColor = color(255, 255, 255);

void settings() {
  size(WIDTH, HEIGHT, P2D);
}

void setRandomSeed() {
  seed = System.currentTimeMillis();
  randomSeed(seed);
  noiseSeed(seed);
}

// Helper to convert HSB to normalized RGB (0..1)
float[] hsbToRgb(float h, float s, float b) {
  color c = color(h, s, b);
  float r = red(c) / 255.0;
  float g = green(c) / 255.0;
  float bl = blue(c) / 255.0;
  return new float[] { r, g, bl };
}

void setup() {
  colorMode(HSB, 360, 100, 100, 100);
  // Try a non-white, non-black background color (e.g., light blue)
  backgroundColor = color(200, 50, 90, 100); // HSB: blue hue, medium saturation, high brightness, fully opaque
  setRandomSeed();
  displayBuffer = createGraphics(WIDTH, HEIGHT, P2D);
  displayBuffer.smooth(8);

  displayBuffer.beginDraw();
  displayBuffer.colorMode(HSB, 360, 100, 100, 100);
  displayBuffer.background(backgroundColor);
  displayBuffer.endDraw();

  blurShader = loadShader("blur.glsl");
  blurShader.set("resolution", float(WIDTH), float(HEIGHT));
  blurShader.set("kernelSize", BLUR_KERNEL_SIZE);
  blurShader.set("sigmaFactor", BLUR_SIGMA_FACTOR);

  float[] bgColorVec3 = hsbToRgb(
    hue(backgroundColor),
    saturation(backgroundColor),
    brightness(backgroundColor)
  );
  blurShader.set("bgColor", bgColorVec3);
}

void draw() {
  image(displayBuffer, 0, 0);

  displayBuffer.beginDraw();
  if (frameCount == 0) {
    displayBuffer.background(backgroundColor);
  }
  float rectWidth = width * RECT_WIDTH_RATIO;
  float rectHeight = height * RECT_HEIGHT_RATIO;
  float rectY = PADDING + frameCount; // Start from PADDING and move downwards
  float hue = (frameCount * HUE_SPEED) % 360;
  float progress = (rectY - PADDING) / (height - 2 * PADDING - rectHeight);
  float amp = lerp((width - 2 * PADDING - rectWidth) / 2, 0, progress);
  float osc = sin(frameCount * OSCILLATION_SPEED);
  float centerX = width / 2 + osc * amp;
  displayBuffer.pushMatrix();
  displayBuffer.translate(centerX, rectY + rectHeight / 2);
  displayBuffer.fill(hue, 80, 100);
  displayBuffer.stroke(hue, 80, 100);
  displayBuffer.rect(-rectWidth / 2, -rectHeight / 2, rectWidth, rectHeight, RECT_CORNER_RADIUS);
  displayBuffer.popMatrix();
  if (frameCount % 2 == 0) {
    displayBuffer.filter(blurShader);
  }
  displayBuffer.endDraw();

  // Overlay: frame and seed info
  fill(0);
  rect(0, 0, OVERLAY_LEFT_WIDTH, OVERLAY_TOP_HEIGHT);
  rect(width-OVERLAY_RIGHT_WIDTH, 0, OVERLAY_RIGHT_WIDTH, OVERLAY_TOP_HEIGHT);
  fill(255);
  text("Frame: " + frameCount, 10, 20);
  text("Seed: " + seed, width-OVERLAY_RIGHT_WIDTH+10, 20);

  if (rectY + rectHeight > height - PADDING) {
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
  } else if (key == 'r' || key == 'R') {
    displayBuffer.beginDraw();
    displayBuffer.background(backgroundColor);
    displayBuffer.endDraw();
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

void resetSketch() {
  setRandomSeed();
  frameCount = 0;
  finalImagePath = null;
  loop();
}
