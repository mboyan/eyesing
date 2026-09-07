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

uniform sampler2D heightTexture;
uniform sampler2D depositTexture;

uniform vec2 windDir;
uniform float hopDist;
uniform float maxHops;

// const int maxAvalancheSteps = 100;
const float grainSize = 1.0 / 256.0;

void main(){
    vec2 st = gl_FragCoord.xy/iResolution.xy;

    float sandHeight = texture2D(heightTexture, st).x;

    // Check if site is being eroded
    float erode = 1.0 - step(0.0, -texture2D(heightTexture, st).x);
    float newSandHeight = sandHeight - erode * grainSize;

    // Check if site is being deposited on
    vec2 posCheck;
    int nHopsCheck;
    float deposit = 0.0;
    for(int i = 0; i < maxHops; ++i)
    {
        posCheck = gl_FragCoord.xy - round((i + 1) * hopDist * windDir);

        nHopsCheck = int(texture2D(depositTexture, posCheck / iResolution.xy).x * maxHops);

        deposit = mix(step(0.0, -float(abs(i + 1 - nHopsCheck))), deposit, deposit);
    }

    newSandHeight = newSandHeight + deposit * grainSize; // THIS IS NOT OUTPUT CURRENTLY!!!

    // Check gradient
    float nbAngle, nbAngleEncode;
    int nbx, nby;
    float dia = sqrt(2);
    float nbHeight, heightDiff;
    float minHeightDiff = 0.0;
    float maxHeightDiff = 0.0;
    vec2 avalancheIndicator = vec2(0.0);
    for (int i = 0; i < 9; ++i)
    {
        nbAngle = i / 9.0;
        nbx = int(gl_FragCoord.x) + int(floor(dia * cos(2 * PI * nbAngle)));
        nby = int(gl_FragCoord.y) + int(floor(dia * sin(2 * PI * nbAngle)));
        nbHeight = texture2D(heightTexture, vec2(float(nbx), float(nby)) / iResolution.xy).x;
        heightDiff = newSandHeight - nbHeight;

        nbAngleEncode = 0.1 + (i / 10.0);
        avalancheIndicator.x = mix(avalancheIndicator.x, step(2.0 * grainSize, heightDiff) * nbAngleEncode, step(maxHeightDiff, heightDiff));     // avalanche due to deposition, should give to this neighbour
        maxHeightDiff = max(maxHeightDiff, heightDiff);
        avalancheIndicator.y = mix(avalancheIndicator.y, 1.0 - step(-grainSize, -heightDiff) * nbAngleEncode, step(minHeightDiff, -heightDiff));   // avalanche due to erosion, should take from this neighbour
        minHeightDiff = max(minHeightDiff, -heightDiff);
    }

    gl_FragColor = vec4(avalancheIndicator * erode * deposit, newSandHeight, 1.0);
}