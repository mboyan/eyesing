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

void main(){
    vec2 st = gl_FragCoord.xy/iResolution.xy;

    float sandHeight = texture2D(exchangeTexture, st).z;
    float erode = 1.0 - step(0.0, -texture2D(exchangeTexture, st).x);
    sandHeight -= erode * grainSize;

    float nbAngle;
    int nbx, nby;
    float dia = sqrt(2);
    float nbAngleCompare, iCompare;
    float deposit = 0.0;
    for (int i = 0; i < 9; ++i)
    {
        nbAngle = i / 9.0;
        nbx = int(gl_FragCoord.x) + int(floor(dia * cos(2 * PI * nbAngle)));
        nby = int(gl_FragCoord.y) + int(floor(dia * sin(2 * PI * nbAngle)));

        iCompare = (texture2D(exchangeTexture, vec2(float(nbx), float(nby)) / iResolution.xy).y * 10. - 0.1);
        deposit += step(0.0, -round(abs(i - iCompare)));
    }

    sandHeight += deposit * grainSize;

    gl_FragColor = vec4(vec3(sandHeight), 1.0);
}