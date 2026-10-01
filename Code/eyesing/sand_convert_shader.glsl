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

void main(){
    vec2 st = gl_FragCoord.xy/iResolution.xy;

    vec3 texSample = texture2D(heightTexture, st).xyz;
    float sandHeight = texSample.x;

    float killGB = step(0.0, -texSample.y - texSample.z);

    gl_FragColor = vec4(sandHeight, vec2(sandHeight * killGB), 1.0);
}