#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

uniform sampler2D texture;
uniform vec2 resolution;
uniform int kernelSize; // New: kernel size (must be odd, e.g. 3, 5, 7)

void main() {
  vec2 uv = gl_FragCoord.xy / resolution.xy;
  float blurSize = 1.0 / min(resolution.x, resolution.y); // Use min dimension for isotropic blur

  vec4 sum = vec4(0.0);
  float totalWeight = 0.0;

  int halfKernel = kernelSize / 2;
  for (int x = -halfKernel; x <= halfKernel; x++) {
    for (int y = -halfKernel; y <= halfKernel; y++) {
      float dist = length(vec2(float(x), float(y)));
      float sigma = float(kernelSize) * 0.35; // Standard deviation proportional to kernel size
      float weight = exp(-(dist * dist) / (2.0 * sigma * sigma));
      vec2 offset = vec2(float(x) * blurSize, float(y) * blurSize);
      sum += texture2D(texture, uv + offset) * weight;
      totalWeight += weight;
    }
  }
  sum /= totalWeight;
  gl_FragColor = sum;
}
