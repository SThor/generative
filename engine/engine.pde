final float FPS = 60;
final float GAMESPEED = 60;
final int SUBSTEPS = 16;

float previousMilli, deltaDiv, deltaTime;

int ballsCount = 100;
PVector gravity = new PVector(0, 100.0f);
ArrayList<Ball> balls = new ArrayList<Ball>();
ArrayList<Link> links = new ArrayList<Link>();
Ball lastBall;

void settings() {
    size(1000, 1000, P2D);
    smooth(8);
}

void setup() {
    colorMode(HSB, 360, 100, 100, 100);
    frameRate(FPS);
    for (int i = 0; i < ballsCount; i++) {
        lastBall = new Ball(new PVector(random(width * 0.25, width * 0.75), height / 4), 20, 255);
        balls.add(lastBall);
    }
    Ball anchor = new AnchoredBall(new PVector(width / 2, height / 4), 20, 255);
    balls.add(anchor);
    Ball lastChainedBall = anchor;
    lastBall = anchor;
    for (int i = 0; i < 10; i++) {
        Ball b = new Ball(new PVector(lastChainedBall.position.x + 20, lastChainedBall.position.y), 20, 255);
        balls.add(b);
        links.add(new Link(lastChainedBall, b));
        lastChainedBall = b;
        lastBall = b;
    }
    Ball b = new AnchoredBall(new PVector(lastChainedBall.position.x + 10, lastChainedBall.position.y), 20, 255);
    balls.add(b);
    links.add(new Link(lastChainedBall, b));
    lastBall = b;

    previousMilli = millis();
}

void draw() {
    deltaDiv = previousMilli / millis();
    deltaTime = (GAMESPEED / FPS) * deltaDiv;
    previousMilli = millis();
    update(deltaTime);
    
    background(0);
    
    noFill();
    stroke(255);
    circle(width / 2, height / 2, height * 0.75);
    
    for (int i = 0; i < balls.size(); i++) {
        balls.get(i).display();
    }
    
    for (int i = 0; i < links.size(); i++) {
        links.get(i).display();
    }
}

void update(float dt) {
    float subDt = dt / SUBSTEPS;
    for (int i = 0; i < SUBSTEPS; i++) {
        applyGravity();
        applyConstraint();
        updateLinks();
        solveCollisions();
        updatePositions(subDt);
    }
}

void updatePositions(float dt) {
    for (int i = 0; i < balls.size(); i++) {
        balls.get(i).updatePosition(dt);
    }
}

void applyGravity() {
    for (int i = 0; i < balls.size(); i++) {
        balls.get(i).accelerate(gravity);
    }
}

void applyConstraint() {
    PVector center = new PVector(width / 2, height / 2);
    float circleRadius = (height * 0.75f) / 2;
    for (int i = 0; i < balls.size(); i++) {
        // if (balls.get(i).position.y > height/2 - balls.get(i).diameter/2) {
        //     balls.get(i).position.y = height/2 - balls.get(i).diameter/2;
// }
    Ball ball = balls.get(i);
    PVector to_object = PVector.sub(ball.position, center);
    float distance = to_object.mag();
    if (distance > circleRadius - ball.diameter / 2) {
        to_object.normalize();
        to_object.mult(circleRadius - ball.diameter / 2);
        balls.get(i).position.set(PVector.add(center, to_object));
    }
}
}

void solveCollisions() {
for (int i = 0; i < balls.size(); i++) {
    for (int j = i + 1; j < balls.size(); j++) {
        if (balls.get(i).collides(balls.get(j))) {
            balls.get(i).bounce(balls.get(j));
        }
    }
}
}

void updateLinks() {
for (int i = 0; i < links.size(); i++) {
    links.get(i).update();
}
}

void mousePressed() {
Ball ball = new Ball(new PVector(mouseX, mouseY), 20, 255);
balls.add(ball);
if (lastBall != null && keyPressed && key == ' ') {
    Link link = new Link(lastBall, ball);
    links.add(link);
}
lastBall = ball;
}

void mouseDragged() {
if (mouseButton == LEFT) {
    Ball ball = new Ball(new PVector(float(mouseX), float(mouseY)));
    lastBall = ball;
    balls.add(ball);
} else {
    lastBall.setPosition(new PVector(float(mouseX), float(mouseY)));
}
}

