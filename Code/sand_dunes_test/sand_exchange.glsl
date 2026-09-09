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

const float grainSize = 1.0 / 256.0;


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

    // vec4 exchangeTextureSample = texture2D(exchangeTexture, st);
    // float sandHeight = exchangeTextureSample.z;
    // float erode = 1.0 - step(0.0, -exchangeTextureSample.x);
    // sandHeight -= erode * grainSize;

    float sandHeight = texture2D(exchangeTexture, st).z;

    // float nbAngle;
    // float nbx, nby;
    // float dia = sqrt(2);
    vec2 nbOffset;
    float iCompare;
    float deposit = 0.0;
    float erode = 0.0;
    vec4 exchangeTextureSample;
    for (int i = 0; i < 8; ++i)
    {
        // nbAngle = float(i) / 4.0;
        // nbx = gl_FragCoord.x + cos(2 * PI * nbAngle);
        // nby = gl_FragCoord.y + sin(2 * PI * nbAngle);

        nbOffset = vec2(offsets[i]);

        // For this neighbour, get the angle index of deposition/erosion
        exchangeTextureSample = texture2D(exchangeTexture, (gl_FragCoord.xy + nbOffset) / iResolution.xy);

        // Erode to this neighbour
        iCompare = exchangeTextureSample.y * 8. - 1.;
        erode += step(0.0, -round(abs(float(i) - mod(iCompare + 2., 4.)))) * step(0.0, iCompare);
        
        // Deposit from this neighbour
        iCompare = exchangeTextureSample.x * 8. - 1.;
        deposit += step(0.0, -round(abs(float(i) - mod(iCompare + 2., 4.)))) * step(0.0, iCompare);
    }

    sandHeight += deposit * grainSize;
    sandHeight -= erode * grainSize;

    gl_FragColor = vec4(vec3(sandHeight), 1.0);
}