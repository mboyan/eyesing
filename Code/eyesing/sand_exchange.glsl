//#version 150

#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

#define PROCESSING_COLOR_SHADER
#define PI 3.14159265358979323846

// ----------------------
// -      UNIFORMS      -
// ----------------------

uniform vec3      iResolution;           // viewport resolution (in pixels)
uniform float     iTime;                 // shader playback time (in seconds) (replaces iGlobalTime which is now obsolete)
uniform float     iTimeDelta;            // render time (in seconds)
uniform int       iFrame;                // shader playback frame
uniform vec4      iMouse;                // mouse pixel coords. xy: current (if MLB down), zw: click
uniform vec4      iDate;                 // (year, month, day, time in seconds)

uniform sampler2D exchangeTexture;
uniform float grainSize;

// const float grainSize = 1.0 / 32.0;//15.0 / 255.0;//256.0;
const float valRatio = 256./248.;

const ivec2 offsets[8] = ivec2[8](
    ivec2(1, 0),
    ivec2(1, 1),
    ivec2(0, 1),
    ivec2(-1, 1),
    ivec2(-1, 0),
    ivec2(-1, -1),
    ivec2(0, -1),
    ivec2(1, -1)
);

void main(){
    vec2 st = gl_FragCoord.xy/iResolution.xy;

    float sandHeight = texture2D(exchangeTexture, st).x;

    vec2 nbOffset;
    float iCompare;
    vec2 iDiff;
    float deposit = 0.0;
    float erode = 0.0;
    vec2 exchangeTextureSample;
    for (int i = 0; i < 8; ++i)
    {
        nbOffset = vec2(offsets[i]);

        // For this neighbour, get the angle index of deposition/erosion
        exchangeTextureSample = texture2D(exchangeTexture, (gl_FragCoord.xy + nbOffset) / iResolution.xy).yz * valRatio;

        // Erode to this neighbour
        iCompare = exchangeTextureSample.y * 8. - 1.;
        erode += step(0.0, -abs(float(i) - mod(iCompare + 4., 8.))) * step(0.0, iCompare);
        
        // Deposit from this neighbour
        iCompare = exchangeTextureSample.x * 8. - 1.;
        deposit += step(0.0, -abs(float(i) - mod(iCompare + 4., 8.))) * step(0.0, iCompare);
    }

    sandHeight += deposit * grainSize;
    sandHeight -= erode * grainSize;

    gl_FragColor = vec4(sandHeight, 0.0, 0.0, 1.0);
}