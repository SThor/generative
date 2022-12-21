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

public class paper extends PApplet {

public void paper() {
  noStroke();
  for (int i = 0; i < 50000; ++i) {
  	fill(248,243,231, random(150,255));
  	float x = random(width);
  	float y = random(height);
  	circle(x,y,random(3));
  }	
}

public void setup() {
  
  orientation(LANDSCAPE);
  background(color(240, 236, 227));
  //paper();
  colorMode(HSB,100);
}

public void draw() {

}
  public void settings() {  size(1024, 768, P2D); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "paper" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
