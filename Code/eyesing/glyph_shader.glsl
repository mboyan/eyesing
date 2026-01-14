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
uniform float iContrast;

#define PI 3.14159265358979323846

vec2 rotate2D(vec2 _st, float _angle){
    _st -= 0.5;
    _st =  mat2(cos(_angle),-sin(_angle),
                sin(_angle),cos(_angle)) * _st;
    _st += 0.5;
    return _st;
}

float shape(in vec2 _st, in vec2 _at){
	float seed = iSeedA;
	float mod = smoothstep(0.01, 0.4, distance(_st, _at));

	vec2 frame = smoothstep(0.05, 0.051, _st)-smoothstep(0.949, 0.95, _st);
	_st = rotate2D(_st, 2.*seed*PI+0.5*mod*PI);
	_st = rotate2D(_st, seed*PI+dot(_at, vec2(1.,1.)*PI));
	_st.y = fract(3.*_st.y);

	float fig = smoothstep(0.85, 0.9, _st.x+_st.y)-smoothstep(1.1, 1.15, _st.x+_st.y);
	return fig*frame.x*frame.y;
}

float pattern(in vec2 _st, in vec2 repeat){
	float seed = iSeedB;
	_st *= repeat;
	vec2 i = floor(_st);
	vec2 at = vec2(0.5) + vec2(0.35*cos(seed*PI+i.x*2.*PI/repeat.x), 0.35*sin(seed*PI+i.y*2.*PI/repeat.y)); // attractor
	return shape(fract(_st), at);
}

void main()
{
	vec2 st = gl_FragCoord.xy/iResolution.xy;

	vec3 color = vec3(pattern(st, iRepeat) * iContrast + (1. - iContrast));

	gl_FragColor = vec4(color, 1.);
}
