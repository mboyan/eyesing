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
uniform bool xyModelToggle;

#define PI 3.14159265358979323846

uvec3 pcg3d(uvec3 v) {
    v = v * uvec3(1664525u) + uvec3(1013904223u);
    v.x += v.y * v.z;
    v.y += v.z * v.x;
    v.z += v.x * v.y;
    v ^= v >> uvec3(16u);
    v.x += v.y * v.z;
    v.y += v.z * v.x;
    v.z += v.x * v.y;
    return v;
}

float hamiltonian(float _s, float _sl, float _sr, float _st, float _sb, float _J, float _h){
	return - _J * (cos(_s - _sl) + cos(_s - _sr) + cos(_s - _st) + cos(_s - _sb)) - _h * cos(_s);
}

void main(){
	vec2 st = gl_FragCoord.xy/iResolution.xy;

	// Modulate with textures
	float betaMod = max(0.0, beta + exp(texture2D(paramTextureBeta, 1. - st).x*20. - 10.));
    float fieldMod = field + texture2D(paramTextureField, 1. - st).y*2. - 1.;
    float interactMod = interact + texture2D(paramTextureInteract, 1. - st).z*2. - 1.;

	// Read spin texture
	float modelSelector = float(xyModelToggle);
	float tex = texture2D(spinTexture, st).x;
	float texl = texture2D(spinTexture, st + vec2(-1./iResolution.x, 0.)).x;
	float texr = texture2D(spinTexture, st + vec2(1./iResolution.x, 0.)).x;
	float text = texture2D(spinTexture, st + vec2(0., -1./iResolution.y)).x;
	float texb = texture2D(spinTexture, st + vec2(0., 1./iResolution.y)).x;

	// Quantise if standard Ising model
	float scaleFactor = mix(1, 2, modelSelector) * PI;
	float spin = mix(step(0.5, tex), tex, modelSelector) * scaleFactor;
	float spinl = mix(step(0.5, texl), texl, modelSelector) * scaleFactor;
	float spinr = mix(step(0.5, texr), texr, modelSelector) * scaleFactor;
	float spint = mix(step(0.5, text), text, modelSelector) * scaleFactor;
	float spinb = mix(step(0.5, texb), texb, modelSelector) * scaleFactor;

	// Compute new state proposal
	uvec3 rndVal = pcg3d(uvec3(st*iResolution.xy, iTime));
	float rndValUnit = fract(rndVal.x ^ rndVal.y ^ rndVal.z);
	float texProposal = mix(1 - spin, fract(tex + (2.0*rndValUnit - 1.0)*0.01), modelSelector);

	// Translate texture into spin values (-1, 1)
	// float spin = tex * 2. - 1.;
	// float spinl = texl * 2. - 1.;
	// float spinr = texr * 2. - 1.;
	// float spint = text * 2. - 1.;
	// float spinb = texb * 2. - 1.;

	float sel = step(selDensity, texture2D(noiseTexture1, st).x);
	float hold = hamiltonian(spin, spinl, spinr, spint, spinb, interactMod, fieldMod);
	float hnew = hamiltonian(texProposal * scaleFactor, spinl, spinr, spint, spinb, interactMod, fieldMod);
	float dH = hnew - hold;

	float pacc = min(exp(-dH * betaMod), 1.0);
	float noise = texture2D(noiseTexture2, st).x;
	float newTex = mix(tex, texProposal, step(noise, pacc)*sel);

	// gl_FragColor = vec4(vec3(newTex, pacc, 0.5*dH+0.5), 1.);
	gl_FragColor = vec4(vec3(newTex), 1.0);
	// gl_FragColor = vec4(vec3(step(pacc, noise) * sel), 1.);
	// gl_FragColor = vec4(vec3(sel), 1.);
	// gl_FragColor = vec4(vec3(tex-texl-texr-text-texb), 1.);
}