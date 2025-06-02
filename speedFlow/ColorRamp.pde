/**
 * Classe de gestion de transitions de couleurs (color ramp)
 * Permet de définir des gradients avec des transitions de couleurs personnalisables
 */
class ColorRamp {
  private color[] colors;
  private float[] thresholds;
    // Constructeur pour rampe de couleurs avec transitions uniformes
  ColorRamp(color[] colors) {
    this.colors = colors;
    this.thresholds = new float[colors.length];
    for (int i = 0; i < colors.length; i++) {
      thresholds[i] = map(i, 0, colors.length - 1, 0, 1);
    }
  }
    // Constructeur avec thresholds personnalisés
  ColorRamp(color[] colors, float[] thresholds) {
    if (colors.length != thresholds.length) {
      throw new IllegalArgumentException("Le nombre de couleurs doit être égal au nombre de seuils");
    }
    this.colors = colors;
    this.thresholds = thresholds;
  }
  
  // Obtenir une couleur interpolée basée sur une valeur entre 0 et 1
  color getColor(float value) {
    value = constrain(value, 0, 1);
    
    // Si la valeur est inférieure au premier seuil, retourner la première couleur
    if (value <= thresholds[0]) {
      return colors[0];
    }
    // Si la valeur est supérieure au dernier seuil, retourner la dernière couleur
    if (value >= thresholds[thresholds.length - 1]) {
      return colors[colors.length - 1];
    }

    // Sinon, trouver les deux couleurs entre lesquelles interpoler
    for (int i = 0; i < thresholds.length - 1; i++) {
      if (value >= thresholds[i] && value <= thresholds[i+1]) {
        float normalizedPos = map(value, thresholds[i], thresholds[i+1], 0, 1);
        return lerpColor(colors[i], colors[i+1], normalizedPos);
      }
    }
    
    // Failsafe (ne devrait jamais arriver avec le constrain)
    return colors[colors.length - 1];
  }
}