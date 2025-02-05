//#version 150

#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

// #define PROCESSING_TEXTURE_SHADER;

// ----------------------
// -      UNIFORMS      -
// ----------------------

uniform vec3      iResolution;           // viewport resolution (in pixels)
uniform float     iTime;                 // shader playback time (in seconds) (replaces iGlobalTime which is now obsolete)
uniform float     iTimeDelta;            // render time (in seconds)
uniform int       iFrame;                // shader playback frame
uniform vec4      iMouse;                // mouse pixel coords. xy: current (if MLB down), zw: click
uniform vec4      iDate;                 // (year, month, day, time in seconds)

uniform sampler2D texture;

#define PI 3.14159265358979323846

float hamiltonian(_st, _J, _mu, _h){
	return 0.0;
}

void main(){
	vec2 st = gl_FragCoord.xy/iResolution.xy;
	gl_FragColor = texture2D(texture, st);
}