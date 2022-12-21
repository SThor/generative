void setup() {
  smooth(4);
  size(1024, 768, P2D);
  orientation(LANDSCAPE);
  background(255);
  
  //noStroke();
  // Translate the origin point to the center of the screen
  translate(width/2, height/2);
  noFill();
}

void draw(){
  // Translate the origin point to the center of the screen
  translate(width/2, height/2);
  noFill();
  for(int i = 0; i<10; i++) {
    stroke(203,35,60,randomGaussian()*128);
    circle(randomGaussian()*100,randomGaussian()*100,5);
  } 
  noStroke();
  for(int i = 0; i<100; i++) {
    fill(255,250,125,50);
    circle(randomGaussian()*25,randomGaussian()*25,5);
  } 
  
}

void mouseClicked() {
  save(frameCount+".png");
}
