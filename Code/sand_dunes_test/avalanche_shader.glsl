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
uniform sampler2D depositTexture;

uniform vec2 windDir;
uniform float hopDist;
uniform float maxHops;

const int maxAvalancheSteps = 100;

void main(){
    vec2 st = gl_FragCoord.xy/iResolution.xy;

    float sandHeight = texture2D(heightTexture, st).x;

    // Check if site is being deposited on
    vec2 posCheck = gl_FragCoord.xy;
    int nHopsCheck;
    float deposit = 0.0;
    for(int i = 0; i < maxHops; ++i)
    {
        posCheck = round(posCheck - hopDist * windDir);

        nHopsCheck = int(texture2D(depositTexture, posCheck / iResolution.xy).x * maxHops);

        deposit = mix(1.0 - step(0.0, -float(abs(i - nHopsCheck))), deposit, deposit);
    }

    gl_FragColor = vec4(vec3(nHopsCheck/maxHops), 1.0);
}