// --- Constantes liées aux particules ---
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
  boolean useThickness = true; // Toggle pour activer l'épaisseur liée au lifespan

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
  
  // Vérifie si la particule est en dehors des marges définies
  boolean isOutOfBounds() {
    return (pos.x < MARGIN || pos.x >= WIDTH - MARGIN || pos.y < MARGIN || pos.y >= HEIGHT - MARGIN);
  }
  
  /**
   * Calcule la probabilité de survie d'une particule en fonction de sa position verticale
   * Plus la particule est basse (y élevé), plus elle a de chances de survivre
   *
   * @return La probabilité de survie entre 0.0 et 1.0
   */
  float calculateSurvivalChance() {
    return map(pos.y, MARGIN * 1.1, HEIGHT - (MARGIN*0.8), 0, 1);
  }
  
  // Réinitialise la particule à une position aléatoire
  // et lui assigne une nouvelle direction basée sur le flow-field
  void respawn() {
      pos.set(random(-10, WIDTH+10), random(-10, HEIGHT+10));
      // pos.set(random(MARGIN, WIDTH - MARGIN), random(MARGIN, HEIGHT - MARGIN));
      if (isOutOfBounds()) {
        if (random(1.0) > calculateSurvivalChance()) {
          respawn();
          return;
        }
      }
      PVector newFlowDir = getFlowFieldDirectionAt(pos.x, pos.y);
      PVector velocity = new PVector().set(newFlowDir).mult(random(0.5, 2.5));
      lifespan = int(random(PARTICLE_LIFESPAN_MIN, PARTICLE_LIFESPAN_MAX));
      initialLifespan = lifespan; // Réinitialiser la durée de vie initiale
      // Ajuster prevPos pour éviter les artefacts visuels
      prevPos.set(pos.x - velocity.x, pos.y - velocity.y);
  }
  
  /**
   * Met à jour la particule en fonction de:
   * - la direction du flow-field
   * - la vitesse actuelle
   * - la friction
   * - la durée de vie
   * - la position par rapport aux marges
   * - etc.
   */
  void update(PVector flowDirection, ArrayList<Particle> particles) {
    // Verlet integration: newPos = pos + (pos - prevPos) + acceleration
    PVector velocity = PVector.sub(pos, prevPos);
      // Utiliser directement le vecteur du flow field comme force
    // La magnitude du vecteur détermine naturellement la force appliquée
    velocity.add(flowDirection);

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
    // velocity.mult(1 - PARTICLE_FRICTION);

    prevPos.set(pos);
    pos.add(velocity);
      float escapeSpeed = PARTICLE_VELOCITY_CAP * 0.5; // Vitesse d'évasion pour les particules lentes
    // Si la particule sort de la zone définie par la marge
    // if (velocity.mag() > escapeSpeed && isOutOfBounds()) {
    if (isOutOfBounds()) {      
      // Si le nombre aléatoire est supérieur à la probabilité, on repositionne la particule
      if (random(1.0) > calculateSurvivalChance()) {
        respawn();
        return; // Ne pas continuer l'update si la particule est réapparue
      }
      // Sinon, la particule reste en vie même en dehors des limites, avec une durée de vie réduite
      // lifespan = min(lifespan, int(PARTICLE_LIFESPAN_MAX * 0.2)); // Durée de vie réduite pour les particules qui s'échappent
      // lifespan = 2; // reste en vie à l'infini, mais super fine, donc cheveux d'ange à l'extérieur
      // lifespan = min(lifespan, 10); // Reste en vie 10 frames max, donc juste petits points à l'extérieur
      //lifespan--;
      //initialLifespan--;
    }

    // Décrémenter la durée de vie
    lifespan--;

    // Vérifier si la particule est "morte"
    if (lifespan <= 0) {
      // Réapparaître la particule à une position aléatoire avec alignement au flow-field
      respawn();
    }
  }

  void display() {
    // Couleur dépendant de la vitesse instantanée (magnitude)
    float velocityMagnitude = PVector.dist(pos, prevPos);
    float interpolationValue = constrain(map(velocityMagnitude, PARTICLE_VELOCITY_MIN, PARTICLE_VELOCITY_MAX, 0, 1), 0, 1);

    // Utiliser la rampe de couleurs pour obtenir la couleur correspondante
    color interpolatedColor = colorRamp.getColor(interpolationValue);

    // Calculer le fading en fonction du lifespan
    // Calcul du facteur d'opacité et d'épaisseur (0 à 1)
    float fading;
    float halfLife = initialLifespan * 0.5;
    
    // Effet de fondu: apparition puis disparition
    if (lifespan > halfLife) {
      // Première moitié de vie: apparition (0 → 1)
      fading = map(lifespan, initialLifespan, halfLife, 0, 1);
    } else {
      // Seconde moitié de vie: disparition (1 → 0)
      fading = map(lifespan, halfLife, 0, 1, 0);
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
