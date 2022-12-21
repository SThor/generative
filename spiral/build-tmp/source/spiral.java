import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class spiral extends PApplet {

float r;
float theta;
float oldR;
float oldTheta;
float thetaVelocity;
float rVelocity;

public void setup() {
  
  
  background(255);
  r = 20;
  theta = 0.1f;
  thetaVelocity = 0.01f;
  rVelocity = 50*thetaVelocity;
  noFill();
  stroke(100);
}

public void draw(){
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
  
  float noise = noise(0.1f*r);
  
  float opacity = map(noise,0,1,200,0);//-50;
  
  //stroke(map(theta%r,0,r,0,255), map((theta+100)%r,0,r,0,255) ,255, opacity);
  
  circle(x, y, noise * height/8.0f);
}

public void mouseClicked() {
  save(frameCount+".png");
}
  public void settings() {  size(1024, 768, P2D);  smooth(8); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "spiral" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
