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

uniform vec2 windDir;

const float shadowStepSize = 0.25;
const float maxShadowDist = 1000;//1920 * 1080;
const int nShadowSteps = int(floor(maxShadowDist / shadowStepSize));

void main(){
	vec2 st = gl_FragCoord.xy/iResolution.xy;

    float sandHeight = texture2D(heightTexture, st).x;

    // Calculate normalised wind direction
    vec2 normWindDir = normalize(windDir);

    // Check if in shadow against wind direction
    float shadowFound = 0.0;
    float shadow = 0.0;
    vec2 shadowProbePos = gl_FragCoord.xy;
    float shadowProbeHeight = 0.0;
    for(int i = 0; i < nShadowSteps; ++i)
    {
        shadowProbePos = round(shadowProbePos - shadowStepSize * normWindDir);
        shadowProbeHeight = texture2D(heightTexture, shadowProbePos / iResolution.xy).x;
        shadow = step((i + 1) * shadowStepSize, shadowProbeHeight - sandHeight);
        shadowFound = mix(shadow, shadowFound, shadowFound); // shadow turns true if height difference is larger than distance from source
    }

    gl_FragColor = vec4(vec3(shadowFound), 1.0);
}