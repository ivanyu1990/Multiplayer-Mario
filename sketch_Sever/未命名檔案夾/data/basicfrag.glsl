#ifdef GL_ES
	precision mediump float;
	precision mediump int;
#endif

varying vec4 vertColor;

//gl_FragCoord = vec4 (1.0, 0.0, 0.0, 1.0);
float lerpValue = gl_FragCoord.y /50.0 - 3.0; 

void main() { 
 	
   //gl_FragColor = vec4 (1.0, 0.0, 0.0, 1.0);
 	gl_FragColor = mix(vec4(0.0, 1.0, 0.0, 1.0), 
 				vec4(0.2, 0.2, 0.2, 1.0), lerpValue); 
}

