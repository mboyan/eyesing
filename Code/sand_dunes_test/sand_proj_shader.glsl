//#version 150

#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

#define PROCESSING_COLOR_SHADER

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
uniform sampler2D shadowTexture;
uniform sampler2D noiseTextureSel;
uniform sampler2D noiseTextureDeposit;

uniform vec2 windDir;
uniform float selDensity;
uniform float hopDist;
uniform float maxHops;

void main(){
	vec2 st = gl_FragCoord.xy/iResolution.xy;

    // Get sand height
    float sandHeight = texture2D(heightTexture, st).x;

    // Calculate normalised wind direction
    vec2 normWindDir = normalize(windDir);

    // Select sand grains
    float selNoiseSample = texture2D(noiseTextureSel, st).x;
    float sel = step(selDensity, selNoiseSample);
    float sandCovered = 1.0 - step(0.0, -sandHeight);
    sel *= sandCovered;

    float shadow = texture2D(shadowTexture, st).x;

    // Determine number of windward hops
    vec2 newPos;
    vec2 newPosCandidate;
    vec2 stCandidate;
    float newPosHeight;
    float depositProb;
    float candidateShadow;
    float depositTry = 0.0;
    float deposited = 0.0;
    float nHopsDeposited = 0.0;
    for(int i = 0; i < maxHops; ++i)
    {
        newPosCandidate = gl_FragCoord.xy + round((i + 1) * hopDist * windDir);
        stCandidate = newPosCandidate / iResolution.xy;

        // Probe new position
        newPosHeight = texture2D(heightTexture, stCandidate).x;
        
        // Check if candidate in shadow
        candidateShadow = texture2D(shadowTexture, stCandidate).x;

        // Deposition probability: 0.4 (bare) / 0.6 (covered) / 1.0 (in shadow)
        depositProb = mix(mix(0.4, 0.6, 1.0 - step(0.0, -newPosHeight)), 1.0, candidateShadow);
        depositTry = fract(texture2D(noiseTextureDeposit, st).x + texture2D(noiseTextureDeposit, stCandidate).x + 73.3247418*selNoiseSample*selNoiseSample*i);
        deposited = mix(1.0 - step(depositProb, depositTry), deposited, 1.0 - step(0.0, -deposited));
        newPos = mix(newPos, newPosCandidate, deposited);

        // Save number of hops until deposition
        nHopsDeposited = mix((i + 1) / maxHops, nHopsDeposited, deposited);
    }

    // gl_FragColor = vec4(vec3((1. - shadow) * sel), 1.0);
    gl_FragColor = vec4(vec3(nHopsDeposited * sel), 1.0);
    // gl_FragColor = vec4(vec3(sel), 1.0);
}