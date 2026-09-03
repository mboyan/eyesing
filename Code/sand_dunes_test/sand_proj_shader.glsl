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
uniform sampler2D noiseTextureSel;
uniform sampler2D noiseTextureDeposit;

uniform vec2 windDir;
uniform float selDensity;
uniform float hopDist;

const float maxHops = 100.;
const float shadowStepSize = 0.1;
const float maxShadowDist = 1000;//1920 * 1080;
const int nShadowSteps = int(floor(maxShadowDist / shadowStepSize));;

float checkShadow(inout float shadowSteps[nShadowSteps], vec2 currentPos, vec2 normWindDir, float sandHeight){
    // Check if in shadow against wind direction
    // float maxShadowDist = length(iResolution.xy);
    // float shadowStepSize = 0.1;
    // int nShadowSteps = int(floor(maxShadowDist / shadowStepSize));
    // float shadowSteps[nShadowSteps];
    
    // Scan backwards
    float shadowFound = 0.0;
    float shadow = 0.0;
    vec2 shadowProbePos = currentPos;
    float shadowProbeHeight = 0.0;
    for(int i = 0; i < nShadowSteps; ++i)
    {
        shadowProbePos = round(shadowProbePos - shadowStepSize * normWindDir);
        shadowProbeHeight = texture2D(heightTexture, shadowProbePos / iResolution.xy).x;
        shadow = step((i + 1) * shadowStepSize, shadowProbeHeight - sandHeight);
        shadowFound = mix(shadow, shadowFound, shadowFound); // shadow turns true if height difference is larger than distance from source
        // shadowSteps[i] = shadow;
    }
    // Scan windwards
    shadowProbePos = currentPos;
    for(int i = 0; i < nShadowSteps; ++i)
    {
        shadowProbePos = round(shadowProbePos + shadowStepSize * normWindDir);
        shadowProbeHeight = texture2D(heightTexture, shadowProbePos / iResolution.xy).x;
        shadow = step((i + 1) * shadowStepSize, sandHeight - shadowProbeHeight);
        shadowSteps[i] = shadow;
    }
    return shadowFound;
}

void main(){
	vec2 st = gl_FragCoord.xy/iResolution.xy;

    // float diagLen = length(iResolution.xy);

    // Get sand height
    float sandHeight = texture2D(heightTexture, st).x;

    // Calculate normalised wind direction
    vec2 normWindDir = normalize(windDir);

    // Select sand grains
    float sel = step(selDensity, texture2D(noiseTextureSel, st).x);
    float sandCovered = 1.0 - step(0.0, -sandHeight);
    sel *= sandCovered;

    // maxShadowDist = length(iResolution.xy);
    // nShadowSteps = int(floor(maxShadowDist / shadowStepSize));
    float shadowSteps[nShadowSteps];

    float shadow = checkShadow(shadowSteps, gl_FragCoord.xy, normWindDir, sandHeight);

    // Determine number of windward hops
    vec2 newPos = gl_FragCoord.xy;
    vec2 newPosCandidate;
    float newPosHeight;
    float depositProb;
    float candidateShadow;
    float depositTry;
    float deposited = 0.0;
    float nHopsDeposited = 0.0;
    for(int i = 0; i < maxHops; ++i)
    {
        newPosCandidate = round(newPos + hopDist * windDir);

        // Probe new position
        newPosHeight = texture2D(heightTexture, newPosCandidate / iResolution.xy).x;
        
        // Check if candidate in shadow
        // candidateShadow = checkShadow(newPosCandidate, normWindDir, newPosHeight);
        // USE shadowSteps!!!!!!!!!!

        // Deposition probability: 0.4 (bare) / 0.6 (covered) / 1.0 (in shadow)
        depositProb = mix(mix(0.4, 0.6, 1.0 - step(0.0, -newPosHeight)), 1.0, candidateShadow);
        depositTry = texture2D(noiseTextureDeposit, st).x;
        deposited = mix(1.0 - step(depositProb, depositTry), deposited, 1.0 - step(0.0, -deposited));
        newPos = mix(newPos, newPosCandidate, deposited);

        // Save number of hops until deposition
        nHopsDeposited = mix(nHopsDeposited + (i / maxHops), nHopsDeposited, deposited);
    }

    gl_FragColor = vec4(vec3((1. - shadow) * sel), 1.0);
    // gl_FragColor = vec4(vec3(nHopsDeposited), 1.0);
}