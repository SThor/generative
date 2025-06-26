#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

uniform sampler2D texture;
uniform vec2 resolution;
uniform vec3 bgColor;

void main() {
  vec2 uv = gl_FragCoord.xy / resolution.xy;
  
  // Taille du flou très subtile pour éviter la "disparition"
  float blurSize = 0.8 / resolution.x;
  
  vec4 sum = vec4(0.0);
  float totalWeight = 0.0;
  
  // Kernel de flou 3x3 avec préservation de luminosité
  float weights[9];
  weights[0] = 0.05; weights[1] = 0.09; weights[2] = 0.05;
  weights[3] = 0.09; weights[4] = 0.46; weights[5] = 0.09;  // Centre plus fort
  weights[6] = 0.05; weights[7] = 0.09; weights[8] = 0.05;
  
  vec2 offsets[9];
  offsets[0] = vec2(-blurSize, -blurSize); offsets[1] = vec2(0.0, -blurSize); offsets[2] = vec2(blurSize, -blurSize);
  offsets[3] = vec2(-blurSize, 0.0);       offsets[4] = vec2(0.0, 0.0);       offsets[5] = vec2(blurSize, 0.0);
  offsets[6] = vec2(-blurSize, blurSize);  offsets[7] = vec2(0.0, blurSize);  offsets[8] = vec2(blurSize, blurSize);
  
  for (int i = 0; i < 9; i++) {
    vec4 sample = texture(texture, uv + offsets[i]);
    
    // Si l'échantillon est très sombre/proche du noir, utiliser la couleur de fond
    float luminance = dot(sample.rgb, vec3(0.299, 0.587, 0.114));
    if (luminance < 0.02) {
      sample = vec4(bgColor, 1.0);
    }
    
    sum += sample * weights[i];
    totalWeight += weights[i];
  }
  
  gl_FragColor = sum / totalWeight;
}