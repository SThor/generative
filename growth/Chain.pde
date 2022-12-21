class Chain {
    ArrayList<ChainedBall> balls = new ArrayList<ChainedBall>();
    float linkLength = 30;
    float minAngle = PI * 0.5;
    
    Chain(int count) {
        for (int i = 0; i < count; i++) {
            balls.add(new ChainedBall(new PVector(width/2 + sin(TWO_PI*i/count) * 100, height/2 + cos(TWO_PI*i/count) * 100)));
            //println("added ball in " + balls.get(i).getPosition().x+" "+balls.get(i).getPosition().y);
        }
    }
    
    void update(float dt) {
        for(int i = 1; i < balls.size() - 1; i++) {
            balls.get(i).attraction(balls.get(i-1), balls.get(i+1));
            //println("ball " + i + " accelerated");
        }
        balls.get(balls.size() - 1).attraction(balls.get(balls.size() - 2), balls.get(0));
        //println("ball " + (balls.size() - 1) + " accelerated");
        balls.get(0).attraction(balls.get(balls.size() - 1), balls.get(1));
        //println("ball " + 0 + " accelerated");
        
        for(int i = 1; i < balls.size() - 1; i++) {
            balls.get(i).rejectNeighbors(balls.get(i-1), balls.get(i+1), balls);
        }
        balls.get(balls.size() - 1).rejectNeighbors(balls.get(balls.size() - 2), balls.get(0), balls);
        balls.get(0).rejectNeighbors(balls.get(balls.size() - 1), balls.get(1), balls);

        for(int i = 0; i < balls.size(); i++) {
            Ball b1 = balls.get(i);
            for(int j = i + 1; j < balls.size(); j++) {
                Ball b2 = balls.get(j);
                if (b1.collides(b2)) {
                    b1.bounce(b2);
                }
            }
        }
        
        for(int i = 0; i < balls.size() - 2; i++) {
            ChainedBall b1 = balls.get(i);
            ChainedBall b2 = balls.get(i+1);

            PVector distance = PVector.sub(b1.getPosition(), b2.getPosition());
            if (distance.mag() > linkLength) {
                 println("Adding new ball, new chain length: " + balls.size());
                 balls.add(i+1, new ChainedBall(PVector.add(b2.getPosition(), PVector.mult(distance, 0.5f))));
                 break;
            }
        }
        
        for(int i = 0; i < balls.size(); i++) {
            balls.get(i).updatePosition(dt);
        }

        for(int i = 1; i < balls.size() - 2; i++) {
            ChainedBall ballBefore = balls.get(i-1);
            ChainedBall b = balls.get(i);
            ChainedBall ballAfter = balls.get(i+1);
            
            PVector before = PVector.sub(ballBefore.getPosition(), b.getPosition());
            PVector after = PVector.sub(ballAfter.getPosition(), b.getPosition());
            float angleBetween = PVector.angleBetween(before, after);
            if (angleBetween < minAngle) {
                float diff = minAngle - angleBetween;
                println("angle between too small " + angleBetween + " diff " + diff);
                before.rotate(-diff/2);
                after.rotate(diff/2);
                println("new angle between " + PVector.angleBetween(before, after));
                println("old ballBefore " + ballBefore.getPosition().x + " " + ballBefore.getPosition().y);
                println("new ballBefore " + PVector.add(b.getPosition(), before).x + " " + PVector.add(b.getPosition(), before).y);
                ballBefore.setPosition(PVector.add(b.getPosition(), before));
                ballAfter.setPosition(PVector.add(b.getPosition(), after));
                stroke(100, 100, 80);
                strokeWeight(2);
                line(b.getPosition().x, b.getPosition().y, ballBefore.getPosition().x, ballBefore.getPosition().y);
                line(b.getPosition().x, b.getPosition().y, ballAfter.getPosition().x, ballAfter.getPosition().y);
                break;
                // noLoop();
            } else if (angleBetween > TWO_PI - minAngle) {
                float diff = angleBetween - (TWO_PI - minAngle);
                println("angle between too big" + angleBetween + " diff " + diff);
                before.rotate(diff/2);
                after.rotate(-diff/2);
                ballBefore.setPosition(PVector.add(b.getPosition(), before));
                ballAfter.setPosition(PVector.add(b.getPosition(), after));
                stroke(100, 100, 80);
                strokeWeight(2);
                line(b.getPosition().x, b.getPosition().y, ballBefore.getPosition().x, ballBefore.getPosition().y);
                line(b.getPosition().x, b.getPosition().y, ballAfter.getPosition().x, ballAfter.getPosition().y);
                break;
                // noLoop();
            }
        }
    }
    
    void display() {
        fill(250);
        stroke(0);
        strokeWeight(1);
        for(int i = 0; i < balls.size() - 1; i++) {
            Ball b1 = balls.get(i);
            Ball b2 = balls.get(i + 1);
            b1.display();
            b2.display();
            //line(b1.getPosition().x, b1.getPosition().y, b2.getPosition().x, b2.getPosition().y);
        }
        stroke(0);
        strokeWeight(1);
        //line(balls.get(balls.size() - 1).getPosition().x, balls.get(balls.size() - 1).getPosition().y, balls.get(0).getPosition().x, balls.get(0).getPosition().y);
    }
}

class ChainedBall extends Ball {
    float neighborhoodDist = 100;
    float neighborsDist = 30;

    float attractionStrength = 10;
    float repulsionStrength = 1;

    ChainedBall(PVector position) {
        super(position);
    }

    void attraction(ChainedBall neighborBefore, ChainedBall neighborAfter) {
        PVector towardsBefore = neighborBefore.getPosition().copy().sub(this.getPosition());
        PVector towardsAfter = neighborAfter.getPosition().copy().sub(this.getPosition());

        if (towardsBefore.mag() > neighborsDist) {
            this.accelerate(towardsBefore.normalize().mult(attractionStrength));
        }
        if (towardsAfter.mag() > neighborsDist) {
            this.accelerate(towardsAfter.normalize().mult(attractionStrength));
        }
    }

    void rejectNeighbors(ChainedBall neighborBefore, ChainedBall neighborAfter, ArrayList<ChainedBall> neighbors) {
        for(int i = 0; i < neighbors.size() - 1; i++) {
            Ball ball = neighbors.get(i);
            if (this == ball || ball == neighborBefore || ball == neighborAfter) {
                continue;
            }
            PVector diff = this.getPosition().copy().sub(ball.position);
            float dist = diff.mag();
            if (dist < neighborhoodDist) {
                this.accelerate(diff.normalize().mult(repulsionStrength));
                stroke(200, 90, 90, 50);
                strokeWeight(neighborhoodDist / dist * 2);
                // line(this.getPosition().x, this.getPosition().y, ball.getPosition().x, ball.getPosition().y);
            }
        }
    }
}