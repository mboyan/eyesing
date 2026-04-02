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
uniform sampler2D iTexture;

void main(){
	vec2 st = gl_FragCoord.xy/iResolution.xy;

    vec2 tex = texture2D(iTexture, st).xy;

    gl_FragColor = vec4(tex.xxx, 1.0);
}