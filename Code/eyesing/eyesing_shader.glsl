//#version 150

#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

#define PROCESSING_COLOR_SHADER;

// ----------------------
//  SHADERTOY UNIFORMS  -
// ----------------------

uniform vec3      iResolution;           // viewport resolution (in pixels)
uniform float     iTime;                 // shader playback time (in seconds) (replaces iGlobalTime which is now obsolete)
uniform float     iTimeDelta;            // render time (in seconds)
uniform int       iFrame;                // shader playback frame
uniform vec4      iMouse;                // mouse pixel coords. xy: current (if MLB down), zw: click
uniform vec4      iDate;                 // (year, month, day, time in seconds)

// ----------------------
//  PROCESSING UNIFORMS  -
// ----------------------
uniform float iSeedA;
uniform float iSeedB;
uniform vec2 iRepeat;
uniform vec3 iCol1;
uniform vec3 iCol2;

#define PI 3.14159265358979323846

// Random generator
// highp float rand(vec2 co)
// {
//     highp float a = 12.9898;
//     highp float b = 78.233;
//     highp float c = 43758.5453;
//     highp float dt= dot(co.xy ,vec2(a,b));
//     highp float sn= mod(dt,3.14);
//     return fract(sin(sn) * c);
// }

float rand(vec2 st) {
    st = fract(st * 0.3183099);  // Scale to make the randomness denser
    st += dot(st, st + 33.333);   // More mixing
    return fract(st.x * st.y * 12345.6789); // Final randomness with deep mixing
}

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


void main(){

    int numCells = 10;

    vec2 st = gl_FragCoord.xy/iResolution.xy;

    uvec3 rndVal = pcg3d(uvec3(st*iResolution.xy, iTime));
    float rndValUnit = float(rndVal.x ^ rndVal.y ^ rndVal.z) / 4294967295.0;;
    vec3 color = vec3(rndValUnit);

	gl_FragColor = vec4(color, 1.);
}