//#version 150

#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

#define PROCESSING_COLOR_SHADER;

// ----------------------
// -      UNIFORMS      -
// ----------------------

uniform vec3      iResolution;           // viewport resolution (in pixels)
uniform float     iTime;                 // shader playback time (in seconds) (replaces iGlobalTime which is now obsolete)
uniform float     iTimeDelta;            // render time (in seconds)
uniform int       iFrame;                // shader playback frame
uniform vec4      iMouse;                // mouse pixel coords. xy: current (if MLB down), zw: click
uniform vec4      iDate;                 // (year, month, day, time in seconds)

uniform sampler2D spinTexture;
uniform sampler2D noiseTexture1;
uniform sampler2D noiseTexture2;
uniform sampler2D paramTextureBeta;
uniform sampler2D paramTextureField;
uniform sampler2D paramTextureInteract;

uniform float beta;
uniform float field;
uniform float interact;
uniform float selDensity;

#define PI 3.14159265358979323846

float hamiltonian(float _s, float _sl, float _sr, float _st, float _sb, float _J, float _h){
	return - _J * _s * (_sl + _sr + _st + _sb) - _h * _s;
}

void main(){
	vec2 st = gl_FragCoord.xy/iResolution.xy;

    // Read parameters from texture
    float beta = exp(texture2D(paramTextureBeta, st).x*20. - 10.);
    float field = texture2D(paramTextureField, st).x*2. - 1.;
    float interact = texture2D(paramTextureInteract, st).x*2. - 1.;

	// Read spin texture
	float tex = step(0.5, texture2D(spinTexture, st).x);
	float texl = step(0.5, texture2D(spinTexture, st + vec2(-1./iResolution.x, 0.)).x);
	float texr = step(0.5, texture2D(spinTexture, st + vec2(1./iResolution.x, 0.)).x);
	float text = step(0.5, texture2D(spinTexture, st + vec2(0., -1./iResolution.y)).x);
	float texb = step(0.5, texture2D(spinTexture, st + vec2(0., 1./iResolution.y)).x);

	// Translate texture into spin values (-1, 1)
	float spin = tex * 2. - 1.;
	float spinl = texl * 2. - 1.;
	float spinr = texr * 2. - 1.;
	float spint = text * 2. - 1.;
	float spinb = texb * 2. - 1.;

	// float sel = step(1.0, texture2D(noiseTexture1, st).x);
	float sel = step(selDensity, texture2D(noiseTexture1, st).x);
	// float sel = (10000.0 / (iResolution.x * iResolution.y)) * texture2D(noiseTexture1, st).x;
	float hold = hamiltonian(spin, spinl, spinr, spint, spinb, interact, field);
	float hnew = hamiltonian(-spin, spinl, spinr, spint, spinb, interact, field);
	float dH = hnew - hold;

	float pacc = min(exp(-dH * beta), 1.0);
	float noise = texture2D(noiseTexture2, st).x;
	// float newTex = mix(tex, 1. - tex, step(1. - pacc, noise) * sel);
	float newTex = mix(tex, 1. - tex, step(noise, pacc)*sel);

	// gl_FragColor = vec4(vec3(newTex, pacc, 0.5*dH+0.5), 1.);
	gl_FragColor = vec4(vec3(newTex), 1.0);
	// gl_FragColor = vec4(vec3(step(pacc, noise) * sel), 1.);
	// gl_FragColor = vec4(vec3(sel), 1.);
	// gl_FragColor = vec4(vec3(tex-texl-texr-text-texb), 1.);
}