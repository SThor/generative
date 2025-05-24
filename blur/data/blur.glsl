#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

uniform sampler2D texture;
uniform vec2 resolution;
uniform int kernelSize; // Must be odd, e.g. 3, 5, 7
uniform float sigmaFactor; // Controls blur softness. Higher = softer, must be between 0 and 1
uniform vec3 bgColor; // Background color (normalized RGB)

void main() {
  vec2 uv = gl_FragCoord.xy / resolution.xy;
  float blurSize = 1.0 / min(resolution.x, resolution.y);

  vec4 sum = vec4(0.0);
  float totalWeight = 0.0;

  int halfKernel = kernelSize / 2;
  float radius = float(halfKernel) + 0.5; // Use a circular kernel
  for (int x = -halfKernel; x <= halfKernel; x++) {
    for (int y = -halfKernel; y <= halfKernel; y++) {
      float dist = length(vec2(float(x), float(y)));
      if (dist <= radius) {
        float sigma = float(kernelSize) * sigmaFactor;
        float weight = exp(-(dist * dist) / (2.0 * sigma * sigma));
        vec2 offset = vec2(float(x) * blurSize, float(y) * blurSize);
        vec4 col = texture(texture, uv + offset);
        col.rgb *= col.a; // Premultiply alpha
        sum += col * weight;
        totalWeight += weight;
      }
    }
  }
  sum /= totalWeight;
  float outAlpha = sum.a;
  vec3 outColor = outAlpha > 0.0 ? sum.rgb / outAlpha : bgColor;
  // Blend with background color if alpha < 1
  outColor = mix(bgColor, outColor, outAlpha);
  gl_FragColor = vec4(outColor, 1.0); // Output fully opaque
}
