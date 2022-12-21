import processing.pdf.*;

float r;
float theta;
float oldR;
float oldTheta;
float thetaVelocity;
float rVelocity;

void settings() {
  size(1748, 1240);
  smooth(8);
}
  

void setup() {
  beginRecord(PDF, "everything.pdf");
  background(255);
  r = 20;
  theta = 0.1;
  thetaVelocity = 0.01f;
  rVelocity = 60*thetaVelocity;
  noFill();
  //stroke(100);
}

void draw(){
  // Translate the origin point to the center of the screen
  translate(width/2, height/2);
  
  oldR = r;
  oldTheta = theta;
    
  thetaVelocity = 1.0f / theta;
  
  r += rVelocity;
  theta += thetaVelocity ;
  
  // Convert polar to cartesian
  float x = r * cos(theta);
  float y = r * sin(theta);
  
  float oldX = oldR * cos(oldTheta);
  float oldY = oldR * sin(oldTheta);
  
  float noise = noise(0.1*r);
  
  float opacity = map(noise,0,1,200,0);//-50;
  
  //stroke(map(theta%r,0,r,0,255), map((theta+100)%r,0,r,0,255) ,255, opacity);
  
  circle(x, y, noise * height/8.0f);
}

void mouseClicked() {
  save(frameCount+".png");
}

void keyPressed() {
  if (key == 'q') {
    endRecord();
    exit();
  }
}
