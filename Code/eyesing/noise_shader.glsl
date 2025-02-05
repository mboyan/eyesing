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


#define PI 3.14159265358979323846

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

    vec2 st = gl_FragCoord.xy/iResolution.xy;

    uvec3 rndVal = pcg3d(uvec3(st*iResolution.xy, iTime));
    float rndValUnit = float(rndVal.x ^ rndVal.y ^ rndVal.z) / 4294967295.0;
    vec3 color = vec3(rndValUnit);

	gl_FragColor = vec4(color, 1.);
}