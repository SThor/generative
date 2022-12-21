void paper() {
  noStroke();
  for (int i = 0; i < 50000; ++i) {
  	fill(248,243,231, random(150,255));
  	float x = random(width);
  	float y = random(height);
  	circle(x,y,random(3));
  }	
}

Particle p;

void setup() {
  size(1024, 768, P2D);
  orientation(LANDSCAPE);
  background(color(240, 236, 227));
  //paper();
  colorMode(HSB,100);

  p = new Particle();
}

void draw() {

}
