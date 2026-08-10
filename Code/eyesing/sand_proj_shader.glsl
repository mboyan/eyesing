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

uniform sampler2D heightTexture;
uniform sampler2D noiseTexture;

uniform vec2 windDir;
uniform float selDensity;

const int maxHops = 100;

void main(){
	vec2 st = gl_FragCoord.xy/iResolution.xy;

    // Select sand grains
    float sel = step(selDensity, texture2D(noiseTexture, st).x);

    // Determine number of windward hops
    for(int i = 0; i < maxHops; ++i)
    {
        asd
    }
}