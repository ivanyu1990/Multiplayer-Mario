#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

varying vec4 vertColor;
varying vec3 ecNormal;
varying vec3 lightDir;
varying vec3 ecVertex;

void main() {  
  vec3 direction = normalize(lightDir);
  vec3 normal = normalize(ecNormal);
  float intensity = max(0.0, dot(direction, normal));

  vec3 ecView = normalize(-ecVertex);
  vec3 h = normalize(lightDir + ecView);
  float spec = pow(max(dot(h, ecNormal), 0.0), 5.0);

  gl_FragColor = (vec4(intensity, intensity, intensity, 1) + vec4(0.0,0.0, 0.0 ,1) + vec4(0,0, spec ,1) )* vertColor;
}