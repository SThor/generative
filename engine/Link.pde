class Link {
    Ball b1;
    Ball b2;
    float targetDist;    
    
    Link(Ball b1, Ball b2) {
        this(b1, b2, 20);
    }
    
    Link(Ball b1, Ball b2, float targetDist) {
        this.b1 = b1;
        this.b2 = b2;
        this.targetDist = targetDist;
    }
    
    void update() {
        PVector diff = PVector.sub(this.b1.getPosition(), this.b2.getPosition());
        float dist = diff.mag();
        float delta = targetDist - dist;
        diff.normalize();
        diff.mult(delta * 0.5);
        b1.positionAdd(diff);
        b2.positionSub(diff);
    }
    
    void display() {
        stroke(255);
        line(this.b1.getPosition().x, this.b1.getPosition().y, this.b2.getPosition().x, this.b2.getPosition().y);
    }
}