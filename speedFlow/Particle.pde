class Particle {
  PVector pos, prevPos;
  color col;

  Particle(float x, float y, PVector v0) {
    pos = new PVector(x, y);
    prevPos = PVector.sub(pos, v0); // Verlet: prevPos = pos - v0
    col = color(255);
  }

  void update() {
    // Verlet integration: newPos = pos + (pos - prevPos) + acceleration
    PVector velocity = PVector.sub(pos, prevPos);
    prevPos.set(pos);
    // Pour l'instant, pas d'accélération (flow-field plus tard)
    pos.add(velocity);
    // Bords en torus (wrap)
    if (pos.x < 0) pos.x += WIDTH;
    if (pos.x >= WIDTH) pos.x -= WIDTH;
    if (pos.y < 0) pos.y += HEIGHT;
    if (pos.y >= HEIGHT) pos.y -= HEIGHT;
  }

  void display() {
    stroke(col);
    strokeWeight(PARTICLE_RADIUS * 2);
    point(pos.x, pos.y);
  }
}
