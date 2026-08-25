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
uniform float hopDist;

const int maxHops = 100;

void main(){
	vec2 st = gl_FragCoord.xy/iResolution.xy;

    // Get sand height
    float sandHeight = texture2D(heightTexture, st).x;

    // Calculate normalised wind direction
    vec2 normWindDir = normalize(winDir);

    // Select sand grains
    float sel = step(selDensity, texture2D(noiseTexture, st).x);
    float sandCovered = 1.0 - step(0.0, -sandHeight);
    sel *= sandCovered;

    // Check if in shadow against wind direction
    float maxShadowDist = length(iResolution.xy);
    float shadowStepSize = 0.1;
    int shadowSteps = floor(maxShadowDist / shadowStepSize);
    float shadow = 0.0;
    vec2 shadowProbePos = gl_FragCoord.xy;
    float shadowProbeVal = 0.0;
    for(int i = 0; i < shadowSteps; ++i)
    {
        shadowProbePos = round(shadowProbePos - shadowStepSize * normWindDir);
        // GUARD AGAINST OUT-OF-BOUNDS!!!!
        shadowProbeVal = texture2D(heightTexture, shadowProbePos / iResolution.xy).x;
        shadow = step(0.5, 1.0 - shadow) * step(i * shadowStepSize, shadowProbeVal); // shadow turns true if height is larger than distance from source
    }

    // Determine number of windward hops
    vec2 newPos = gl_FragCoord.xy;
    for(int i = 0; i < maxHops; ++i)
    {
        newPos = round(newPos + hopDist * windDir);

        // Probe new position
    }
}