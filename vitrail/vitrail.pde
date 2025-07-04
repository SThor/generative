import paperandpencil.*;

// === VARIABLES GLOBALES ===
PaperAndPencil pp;                    // Instance de la bibliothèque PaperAndPencil
float topMargin = 0, leftMargin = 0;  // Marges (non utilisées actuellement)
float xOffset = 340;                  // Décalage horizontal (non utilisé actuellement)
float yOffset = 310;                  // Décalage vertical (non utilisé actuellement)
float minDiameter = 80;               // Diamètre minimum (non utilisé actuellement)
float maxDiameter;                    // Diamètre maximum (non utilisé actuellement)
float x1, y1, x2, y2 = 0;            // Coordonnées pour le dessin à la souris
//color pencilColor = color(0, 0, 0, 30);  // Couleur du crayon (version éclaircie)
color pencilColor = color(0, 0, 0, 0);     // Couleur du crayon (version opaque)
color pencilColorCroisillions = color(0, 0, 0, 20); // Couleur des croisillions (lignes croisées)
int step = 2;                         // Nombre de subdivisions principales
int substep = 2;                      // Nombre de subdivisions secondaires
float radius = 400;                   // Rayon principal de l'arc gothique
int rosaceSubcircles = 3;            // Nombre de subdivisions de la rosace
boolean debugMode = false;           // Mode debug pour visualiser la géométrie

// === FONCTIONS UTILITAIRES MATHÉMATIQUES ===

/**
 * Calcule la hauteur d'un triangle équilatéral à partir de sa base
 * Utilise la formule : h = (√3 * base) / 2
 */
float triangleHeight(float base) {
  return sqrt(3.0)*base/2.0;
}

/**
 * Calcule la hauteur d'un triangle isocèle à partir de sa base et de ses côtés
 * Utilise la formule : h = √(4*côté² - base²) / 2
 */
float triangleHeight(float base, float side) {
  return sqrt(4*sq(side)-sq(base))/2;
}

// === FONCTIONS DE CONFIGURATION PROCESSING ===

/**
 * Configure la taille de la fenêtre et les paramètres de rendu
 * Appelée automatiquement avant setup()
 */
void settings() {
  size(1000, 1500, P2D);  // Fenêtre 1000x1500 pixels avec rendu P2D (accéléré)
  smooth(8);              // Anti-aliasing pour des lignes plus lisses
}

/**
 * Fonction principale qui dessine le vitrail complet
 * Appelée à chaque fois qu'on veut redessiner (touches clavier, setup initial)
 */
void mainStep() {
  background(360);  // Efface l'écran avec du blanc (HSB: 360 = blanc)
  
  //gothicArc(width/2, height/2, radius, true, radius, false);
  //generateInteriorArcs(step);

  // Dessine l'arc gothique principal avec subdivisions récursives
  // gothicArc(width/2, height/2, radius, true, radius, step, substep);

  // Debug des rosaces
  for (int i=0; i<12; i++) {
    // dessine une grille de rosaces à des fins de test, chaque rosace est décalée
    float offsetX = (i%3) * (width/3) * 0.5; // Décalage horizontal pour chaque rosace
    float offsetY = (i/3) * (height/4) * 0.5; // Décalage vertical pour chaque rosace
    simpleRosace(width * 0.1 + offsetX, height * 0.1 + offsetY, radius/4, i, 0);
    text("Rosace " + i, width * 0.1 + offsetX - 20, height * 0.1 + offsetY + radius * 0.2);
  }
}

/**
 * Configuration initiale du programme - appelée une seule fois au démarrage
 */
void setup() {
  pp = new PaperAndPencil(this);           // Initialise la bibliothèque
  colorMode(HSB, 360, 100, 100, 100);     // Mode couleur HSB (Teinte, Saturation, Luminosité)
  stroke(0);                              // Couleur de contour noire
  pp.setPencilColor(pencilColor);         // Définit la couleur du crayon
  mainStep();                             // Dessine le vitrail initial
}

// === FONCTIONS DE DESSIN ===

/**
 * Dessine une rosace simple composée d'un cercle central et d'arcs disposés en étoile
 * @param centerX, centerY : coordonnées du centre de la rosace
 * @param diameter : diamètre du cercle principal
 * @param subcircles : nombre d'arcs à disposer autour du centre
 * @param startAngle : angle de départ pour la première subdivision (en radians)
 */
void simpleRosace(float centerX, float centerY, float diameter, int subcircles, float startAngle) {
  // Évite les erreurs pour les cas extrêmes
  if (subcircles <= 0) return;
  
  // Dessine le cercle central
  pp.circle(centerX, centerY, diameter, false);
  
  // Calcule l'angle entre chaque arc
  float angle = TWO_PI/subcircles;
  float subdiameter = diameter/2;
  float x, y, subAngle;
  
  // Mode debug : dessine les rayons et triangles géométriques
  if (debugMode) {    
    // Dessine les rayons en rouge (points de contact fixes sur le cercle principal)
    pp.setPencilColor(color(0, 100, 100)); // Rouge vif en HSB
    for (int i = 0; i < subcircles; i++) {
      // Angle entre chaque subdivision (point de jonction entre arcs)
      float contactAngle = startAngle + (i + 0.5) * angle;
      float contactX = centerX + (diameter/2) * cos(contactAngle);
      float contactY = centerY + (diameter/2) * sin(contactAngle);
      pp.line(centerX, centerY, contactX, contactY, false);
    }
    
    // Dessine les triangles isocèles en vert
    pp.setPencilColor(color(120, 100, 100)); // Vert vif en HSB
    for (int i = 0; i < subcircles; i++) {
      subAngle = startAngle + i * angle;
      // Centre du sous-arc (sommet du triangle)
      x = centerX + subdiameter/2 * cos(subAngle);
      y = centerY + subdiameter/2 * sin(subAngle);
      
      // Points de contact adjacents (base du triangle isocèle)
      float contactAngle1 = startAngle + (i - 0.5) * angle;
      float contactAngle2 = startAngle + (i + 0.5) * angle;
      float contact1X = centerX + (diameter/2) * cos(contactAngle1);
      float contact1Y = centerY + (diameter/2) * sin(contactAngle1);
      float contact2X = centerX + (diameter/2) * cos(contactAngle2);
      float contact2Y = centerY + (diameter/2) * sin(contactAngle2);
      
      // Dessine le triangle isocèle
      pp.line(x, y, contact1X, contact1Y, false); // Côté 1 (rayon de l'arc)
      pp.line(x, y, contact2X, contact2Y, false); // Côté 2 (rayon de l'arc)
      pp.line(contact1X, contact1Y, contact2X, contact2Y, false); // Base du triangle
    }
    
    // Restaure la couleur originale
    pp.setPencilColor(pencilColor);
  }
  
  // Dessine chaque arc autour du centre
  for (int i=0; i<subcircles; i++) {
    subAngle = startAngle + i*angle;
    // Position de chaque arc
    x = centerX + subdiameter/2*cos(subAngle);
    y = centerY + subdiameter/2*sin(subAngle);
    // Dessine l'arc avec une ouverture de PI/3 (60 degrés)
    pp.arc(x, y, subdiameter, subAngle - angle, subAngle + angle, false);
  }
}

/**
 * Version simplifiée de gothicArc - redirige vers la version avec récursion
 * @param centerX, centerY : coordonnées du centre de l'arc
 * @param radius : rayon de l'arc principal
 * @param showTail : si true, dessine les lignes verticales (piliers)
 * @param tail : longueur des piliers
 * @param subdivisions : nombre de subdivisions à créer
 */
void gothicArc(float centerX, float centerY, float radius, boolean showTail, float tail, int subdivisions) {
  gothicArc(centerX, centerY, radius, showTail, tail, subdivisions, 0);
}

/**
 * Version récursive de gothicArc - crée des arcs gothiques avec subdivisions
 * Cette fonction est le cœur de l'algorithme de génération du vitrail
 * @param centerX : coordonnées du centre de l'arc
 * @param centerY : coordonnées du centre de l'arc
 * @param radius : rayon de l'arc principal
 * @param showTail : si true, dessine les lignes verticales (piliers)
 * @param tail : longueur des piliers
 * @param subdivisions : nombre de subdivisions à créer
 * @param recursion : niveau de récursion (0 = niveau le plus bas)
 */
void gothicArc(float centerX, float centerY, float radius, boolean showTail, float tail, int subdivisions, int recursion) {
  // Dessine d'abord l'arc principal
  gothicArc(centerX, centerY, radius, showTail, tail, recursion == 0);
  
  if (recursion > 0) {
    // === PHASE RÉCURSIVE : crée des sous-arcs ===
    
    // Calcule l'origine pour aligner les sous-arcs
    float origin = centerX-radius/2;
    float subradius = radius/subdivisions;
    
    // Crée chaque subdivision
    for (int i=0; i<subdivisions; i++) {
      // Alterne l'affichage des piliers (i%2==0)
      gothicArc(origin + (i+0.5)*subradius, height/2, subradius, i%2==0, tail, (recursion > 0) ? step : 0, recursion - 1);
    }
    
    // Ajoute une rosace décorative en haut de l'arc principal
    simpleRosace(centerX, centerY - triangleHeight(radius, 0.75*radius), radius/2, rosaceSubcircles, 3*HALF_PI);

  } else {
    // === PHASE FINALE : dessine les motifs de remplissage (lignes croisées) ===
    
    pp.setPencilColor(pencilColorCroisillions);  // Transparence légère pour les lignes
    float x, y, a, b, x1, y1, y2;
    
    // Premier ensemble de lignes diagonales (pente -1.5)
    a = -1.5;
    for (float centerOffset = -radius; centerOffset < tail + radius; centerOffset += 40) {
      x = centerX;
      y = centerY + centerOffset;
      b = y - a * x;  // Calcul de l'ordonnée à l'origine
      x1 = x + radius/2;
      y1 = a * x1+b;
      x2 = x - radius/2;
      y2 = a * x2+b;
      pp.line(x1, y1, x2, y2, false);
    }
    
    // Deuxième ensemble de lignes diagonales (pente +1.5, symétrique)
    a = -a;  // Inverse la pente
    for (float centerOffset = -radius; centerOffset < tail + radius; centerOffset += 40) {
      x = centerX;
      y = centerY + centerOffset;
      b = y - a * x;
      x1 = x + radius/2;
      y1 = a * x1+b;
      x2 = x - radius/2;
      y2 = a * x2+b;
      pp.line(x1, y1, x2, y2, false);
    }
    
    // Remet la couleur du crayon à la valeur globale
    pp.setPencilColor(pencilColor);
  }
}

/**
 * Version basique de gothicArc - dessine un arc gothique simple
 * @param centerX : coordonnées du centre de l'arc
 * @param centerY : coordonnées du centre de l'arc
 * @param radius : rayon de l'arc principal
 * @param showTail : si true, dessine les lignes verticales (piliers)
 * @param tail : longueur des piliers
 * @param subarcs : si true, ajoute des arcs intérieurs décoratifs
 */
void gothicArc(float centerX, float centerY, float radius, boolean showTail, float tail, boolean subarcs) {
  if (showTail) {
    // Dessine les deux piliers verticaux
    pp.line(centerX - radius/2, centerY, centerX - radius/2, centerY + tail, false);
    pp.line(centerX + radius/2, centerY, centerX + radius/2, centerY + tail, false);
  }

  // Dessine les deux arcs principaux qui forment la pointe gothique
  pp.arc(centerX - radius/2, centerY, 2*radius, -PI/3, 0, false);       // Arc gauche
  pp.arc(centerX + radius/2, centerY, 2*radius, PI, PI+PI/3, false);     // Arc droit

  if (subarcs) {
    // Ajoute des arcs décoratifs intérieurs pour plus de détail
    pp.arc(centerX, centerY, radius, PI, PI+PI/3, false);
    pp.arc(centerX + radius/4, centerY - triangleHeight(radius/2), radius, PI, PI+PI/3, false);
    pp.arc(centerX - radius/4, centerY - triangleHeight(radius/2), radius, -PI/3, 0, false);
    pp.arc(centerX, centerY, radius, -PI/3, 0, false);
  }
}

/**
 * Génère une série d'arcs gothiques alignés horizontalement
 * Fonction alternative non utilisée dans la version actuelle
 * @param qty : nombre d'arcs à créer
 */
void generateInteriorArcs(int qty) {
  float origin = (width-radius)/2;       // Point de départ
  float subradius = radius/qty;          // Rayon de chaque sous-arc
  for (int i=0; i<qty; i++) {
    // Crée chaque arc à intervalles réguliers
    gothicArc(origin + (i+0.5)*subradius, height/2, subradius, false, radius, substep);
  }
}

// === FONCTIONS D'INTERACTION ===

/**
 * Fonction appelée quand on clique avec la souris
 * Enregistre le point de départ pour un futur dessin à la souris
 */
void mousePressed() {
  x1 = mouseX;
  y1 = mouseY;
  x2 = mouseX;
  y2 = mouseY;
}

/**
 * Fonction appelée quand on fait glisser la souris
 * Met à jour le point d'arrivée du trait
 */
void mouseDragged() {
  x2 = mouseX;
  y2 = mouseY;
}

/**
 * Fonction appelée quand on relâche la souris
 * Dessine une ligne
 */
void mouseReleased() {
  pp.setPencilColor(pencilColor);
  //pp.line(x1, y1, x2, y2, true);
}

/**
 * Fonction draw() vide - tout le dessin se fait dans mainStep()
 * Processing appelle cette fonction en boucle mais on ne l'utilise pas
 */
void draw() {
}

/**
 * Fonction appelée à chaque fois qu'on tape une touche
 * Contrôle les paramètres du vitrail et permet de sauvegarder
 */
void keyTyped() {
  if (key == 's' || key == 'S') {
    // Sauvegarde l'image avec un nom basé sur la date/heure
    save(year()+"-"+month()+"-"+day()+"-"+hour()+"-"+minute()+"-"+second()+".png");
  }
  if (key == '+') {
    step++;                 // Augmente le nombre de subdivisions principales
  }
  if (key == '-') {
    step--;                 // Diminue le nombre de subdivisions principales
  }
  if (key == 'p') {
    substep++;              // Augmente le niveau de récursion
  }
  if (key == 'm') {
    substep--;              // Diminue le niveau de récursion
  }
  if (key == 'o') {
    rosaceSubcircles++;  // Augmente le nombre de subdivisions de la rosace
  }
  if (key == 'l') {
    rosaceSubcircles--;  // Diminue le nombre de subdivisions de la rosace
  }
  if (key == 'd' || key == 'D') {
    debugMode = !debugMode;  // Toggle le mode debug
  }
  mainStep();               // Redessine avec les nouveaux paramètres
}
