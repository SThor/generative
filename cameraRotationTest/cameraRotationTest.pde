int[] dimensions = { 150, 480, 640, 500, 700, 1000, 2000 };
int xIndex = 0;
int yIndex = 0;
int myWidth;
int myHeight;
PGraphics pg;

void setup() {
    size(10, 10, P2D);
    frameRate(15);
}

void draw() {
    myWidth = dimensions[xIndex];
    myHeight = dimensions[yIndex];
    pg = createGraphics(myWidth,myHeight);
    pg.stroke(0);
    pg.smooth(4);
    pg.beginDraw();
    
    pg.textAlign(CENTER);
    pg.textSize(20);
    
    pg.background(255);
    
    pg.fill(200);
    pg.noStroke();
    pg.rect(10,10,myWidth - 20,myHeight - 20);
    
    pg.noFill();
    pg.stroke(0);
    pg.strokeWeight(5);
    pg.circle(myWidth / 2, myHeight / 2, 50);
    
    pg.fill(0);
    pg.stroke(0);
    pg.text("" + myWidth + "x" + myHeight, myWidth / 2, myHeight / 4);
    
    println("" + myWidth + "x" + myHeight + ".png");
    
    pg.endDraw();
    pg.save("" + myWidth + "x" + myHeight + ".png");
    yIndex++;
    if(yIndex >= dimensions.length) {
        yIndex = 0;
        xIndex++;
        if (xIndex >= dimensions.length) {
            exit();
        }
}
}