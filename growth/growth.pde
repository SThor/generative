final float FPS = 60;
final float GAMESPEED = 60;
final int SUBSTEPS = 16;

float previousMilli, deltaDiv, deltaTime;

Chain chain;

void settings() {
    size(1000, 1000, P2D);
    smooth(8);
}

void setup() {
    colorMode(HSB, 360, 100, 100, 100);
    frameRate(FPS);
    background(360);
    fill(0);
    chain = new Chain(40);
}

void draw() {
    fill(360, 1);
    noStroke();
    rect(0, 0, width, height);
    deltaDiv = previousMilli / millis();
    deltaTime = (GAMESPEED / FPS) * deltaDiv;
    previousMilli = millis();
    update(deltaTime);
    chain.display();
}

void update(float dt) {
    float subDt = dt / SUBSTEPS;
    for (int i = 0; i < SUBSTEPS; i++) {
        chain.update(subDt);
    }
}

void keyTyped() {
  if (key == 's' || key == 'S') {
    save(year()+"-"+month()+"-"+day()+"-"+hour()+"-"+minute()+"-"+second()+".png");
  }
  if (key == ' ') {
      redraw();
  }
}