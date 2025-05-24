// --- Constantes liées aux particules ---
final color PARTICLE_COLOR_SLOW = color(30, 144, 255); // bleu
final color PARTICLE_COLOR_MID = color(255, 255, 0);  // jaune
final color PARTICLE_COLOR_FAST = color(255, 0, 0);   // rouge
final float PARTICLE_VELOCITY_MIN = 0.0;
final float PARTICLE_VELOCITY_MAX = 4.0; // vitesse max approx pour le mapping
final float PARTICLE_RADIUS = 1.5;
final float PARTICLE_ACCELERATION = 0.04; // force du flow-field appliquée à chaque update (diminuée)
final float PARTICLE_VELOCITY_CAP = 2*PARTICLE_RADIUS; // vitesse maximale autorisée pour une particule

class Particle {
  PVector pos, prevPos;
  color col;

  Particle(float x, float y, PVector initialVelocity) {
    pos = new PVector(x, y);
    prevPos = PVector.sub(pos, initialVelocity); // Verlet: prevPos = pos - v0
    col = color(255);
  }

  // La fonction getFlowFieldDirection doit retourner un PVector direction normalisé à la position donnée
  void update(PVector flowDirection) {
    // Verlet integration: newPos = pos + (pos - prevPos) + acceleration
    PVector velocity = PVector.sub(pos, prevPos);
    velocity.add(PVector.mult(flowDirection, PARTICLE_ACCELERATION));
    // Cap sur la vitesse maximale
    if (velocity.mag() > PARTICLE_VELOCITY_CAP) {
      velocity.setMag(PARTICLE_VELOCITY_CAP);
    }
    prevPos.set(pos);
    pos.add(velocity);
    // Bords en torus (wrap) + correction de prevPos pour éviter les artefacts
    if (pos.x < 0) {
      pos.x += WIDTH;
      prevPos.x += WIDTH;
    }
    if (pos.x >= WIDTH) {
      pos.x -= WIDTH;
      prevPos.x -= WIDTH;
    }
    if (pos.y < 0) {
      pos.y += HEIGHT;
      prevPos.y += HEIGHT;
    }
    if (pos.y >= HEIGHT) {
      pos.y -= HEIGHT;
      prevPos.y -= HEIGHT;
    }
  }

  void display() {
    // Couleur dépendant de la vitesse instantanée (magnitude)
    float velocityMagnitude = PVector.dist(pos, prevPos);
    float t = constrain(map(velocityMagnitude, PARTICLE_VELOCITY_MIN, PARTICLE_VELOCITY_MAX, 0, 1), 0, 1);
    color interpolatedColor;
    if (t < 0.5) {
      interpolatedColor = lerpColor(PARTICLE_COLOR_SLOW, PARTICLE_COLOR_MID, t * 2);
    } else {
      interpolatedColor = lerpColor(PARTICLE_COLOR_MID, PARTICLE_COLOR_FAST, (t - 0.5) * 2);
    }
    stroke(interpolatedColor);
    strokeWeight(PARTICLE_RADIUS * 2);
    line(prevPos.x, prevPos.y, pos.x, pos.y); // Remplace point() par une ligne entre prevPos et pos
  }
}
