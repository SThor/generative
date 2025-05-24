// --- Constantes liées aux particules ---
final color PARTICLE_COLOR_SLOW = color(255, 240, 150);  // jaune pastel
final color PARTICLE_COLOR_MID = color(30, 220, 140);   // vert fluo marin
final color PARTICLE_COLOR_FAST = color(10, 60, 120);   // bleu marin profond
final float PARTICLE_VELOCITY_MIN = 0.0;
final float PARTICLE_VELOCITY_MAX = 4.0; // vitesse max approx pour le mapping
final float PARTICLE_RADIUS = 1.5;
final float PARTICLE_ACCELERATION = 0.04; // force du flow-field appliquée à chaque update (diminuée)
final float PARTICLE_VELOCITY_CAP = 2*PARTICLE_RADIUS; // vitesse maximale autorisée pour une particule
final float PARTICLE_FRICTION = 0.01; // coefficient de frottement (réduction de la vitesse par frame)
final int PARTICLE_LIFESPAN_MIN = 10; // durée de vie minimale (en frames)
final int PARTICLE_LIFESPAN_MAX = 100; // durée de vie maximale (en frames)

class Particle {
  boolean useOpacity = true; // Toggle pour activer l'opacité liée au lifespan
  boolean useThickness = false; // Toggle pour activer l'épaisseur liée au lifespan

  PVector pos, prevPos;
  color col;
  int lifespan; // Durée de vie restante de la particule
  int initialLifespan; // Durée de vie initiale de la particule

  Particle(float x, float y, PVector initialVelocity) {
    pos = new PVector(x, y);
    prevPos = PVector.sub(pos, initialVelocity); // Verlet: prevPos = pos - v0
    col = color(255);
    lifespan = int(random(PARTICLE_LIFESPAN_MIN, PARTICLE_LIFESPAN_MAX)); // Durée de vie aléatoire dans l'intervalle défini
    initialLifespan = lifespan; // Enregistrer la durée de vie initiale
  }

  // La fonction getFlowFieldDirection doit retourner un PVector direction normalisé à la position donnée
  void update(PVector flowDirection, ArrayList<Particle> particles) {
    // Verlet integration: newPos = pos + (pos - prevPos) + acceleration
    PVector velocity = PVector.sub(pos, prevPos);
    velocity.add(PVector.mult(flowDirection, PARTICLE_ACCELERATION));

    // // Répulsion locale
    // for (Particle other : particles) {
    //   if (other != this) {
    //     float distance = PVector.dist(pos, other.pos);
    //     if (distance < PARTICLE_RADIUS * 4) { // Seuil de collision
    //       PVector repulsion = PVector.sub(pos, other.pos).normalize().mult(0.1);
    //       velocity.add(repulsion);
    //     }
    //   }
    // }

    // Cap sur la vitesse maximale
    if (velocity.mag() > PARTICLE_VELOCITY_CAP) {
      velocity.setMag(PARTICLE_VELOCITY_CAP);
    }

    // Application du frottement : réduction de la vitesse
    velocity.mult(1 - PARTICLE_FRICTION);

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

    // Décrémenter la durée de vie
    lifespan--;

    // Vérifier si la particule est "morte"
    if (lifespan <= 0) {
      // Réapparaître la particule à une position aléatoire avec alignement au flow-field
      pos.set(random(WIDTH), random(HEIGHT));
      PVector newFlowDir = getFlowFieldDirectionAt(pos.x, pos.y);
      velocity.set(newFlowDir).mult(random(0.5, 2.5));
      lifespan = int(random(PARTICLE_LIFESPAN_MIN, PARTICLE_LIFESPAN_MAX));
      initialLifespan = lifespan; // Réinitialiser la durée de vie initiale
      // Ajuster prevPos pour éviter les artefacts visuels
      prevPos.set(pos.x - velocity.x, pos.y - velocity.y);
    }
  }

  void display() {
    // Couleur dépendant de la vitesse instantanée (magnitude)
    float velocityMagnitude = PVector.dist(pos, prevPos);
    float interpolationValue = constrain(map(velocityMagnitude, PARTICLE_VELOCITY_MIN, PARTICLE_VELOCITY_MAX, 0, 1), 0, 1);
    color interpolatedColor;
    // Interpolation plus progressive :
    if (interpolationValue <= 0.33) {
      float t1 = map(interpolationValue, 0, 0.33, 0, 1);
      interpolatedColor = lerpColor(PARTICLE_COLOR_SLOW, PARTICLE_COLOR_MID, t1);
    } else if (interpolationValue <= 0.66) {
      float t2 = map(interpolationValue, 0.33, 0.66, 0, 1);
      interpolatedColor = lerpColor(PARTICLE_COLOR_MID, PARTICLE_COLOR_FAST, t2);
    } else {
      interpolatedColor = PARTICLE_COLOR_FAST;
    }

    // Calculer le fading en fonction du lifespan
    float fading = 1; // Fading par défaut
    if (lifespan >= initialLifespan * 0.5) {
      fading = map(lifespan, initialLifespan * 0.5, initialLifespan, 1, 0);
    } else {
      fading = map(lifespan, 0, initialLifespan * 0.5, 0, 1);
    }

    float weight = PARTICLE_RADIUS * 2;
    if (useThickness) {
      weight *= fading;
    }

    if (useOpacity) {
      stroke(interpolatedColor, fading * 255);
    } else {
      stroke(interpolatedColor);
    }
    strokeWeight(weight);
    line(prevPos.x, prevPos.y, pos.x, pos.y);
  }
}
