class Ball {    
    float diameter = 10;
    color colour = color(0);
    PVector lastPosition = new PVector(0,0);
    private PVector position = new PVector(0,0);
    PVector acceleration = new PVector(0,0);
    
    Ball(PVector position) {
        this(position, 5, color(0));
    }
    
    Ball(PVector position, float diameter, color colour) {
        this.position = position;
        this.lastPosition = position;
        this.diameter = diameter;
        this.colour = colour;
    }

    PVector getPosition() {
        return position;
    }

    void setPosition(PVector position) {
        this.lastPosition = this.position;
        this.position = position;
    }

    void positionAdd(PVector position) {
        this.position.add(position);
    }

    void positionSub(PVector position) {
        this.position.sub(position);
    }

    void updatePosition(float dt) {
        PVector velocity = PVector.sub(this.position, this.lastPosition);
        this.lastPosition.set(this.position);
        this.positionAdd(PVector.add(velocity, PVector.mult(this.acceleration, dt*dt)));
        this.acceleration.mult(20);
        stroke(100, 100, 80);
        strokeWeight(1);
        // line(this.position.x, this.position.y, this.position.x+this.acceleration.x, this.position.y+this.acceleration.y);
        this.acceleration.set(0,0);
    }

    void accelerate(PVector force) {
        this.acceleration.add(force);
        //println("accelerating with force: " + force);
        //println("acceleration is now: " + this.acceleration);
        //println();
    }

    void display() {
        fill(colour);
        stroke(0);
        //println(this.position.x + " " + this.position.y);
        circle(position.x, position.y, diameter*2);
    }

    boolean collides(Ball p2) {
        return (this.position.dist(p2.position) < (this.diameter/2 + p2.diameter/2));
    }

    void bounce(Ball p2) {
        PVector normal = PVector.sub(p2.position, this.position);
        normal.normalize();
        PVector bounce = PVector.mult(normal, ((this.diameter/2 + p2.diameter/2) - this.position.dist(p2.position)) * 0.5);
        this.positionSub(bounce);
        p2.positionAdd(bounce);
    }
}

class AnchoredBall extends Ball {
    PVector originalPosition;

    AnchoredBall(PVector position, float diameter, color colour) {
        super(position, diameter, colour);
        originalPosition = position;
    }

    void accelerate(PVector force) {
        setPosition(originalPosition);
    }

    void updatePosition(float dt) {
        setPosition(originalPosition);
    }

    void positionAdd(PVector position) {
        setPosition(originalPosition);
    }

    void positionSub(PVector position) {
        setPosition(originalPosition);
    }

    void setPosition(PVector position) {
        super.setPosition(originalPosition);
    }
}
