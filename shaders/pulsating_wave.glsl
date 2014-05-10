#ifdef GL_ES
precision mediump float;
#endif

uniform float time; // float in range 0-1 representing normalized song position
uniform vec2 resolution; // vector with screen resolution (x pixels, y pixels)
uniform float speed; // to adjust animation speed (starts at 1.0)
uniform vec3 offset; // (offset.x, offset.y, offset.z) to support panning/zoom (either with controller or mouse)
uniform float volume; // float in range 0-1 measuring overall song volume
uniform float beat; // close to 1.0 when the beat strikes, 0 off beat
uniform float bass; // float in range 0-1 measuring bass volume (0-150 hz)
uniform float lowerMid; // float in range 0-1 measuring lower midrange volume (150-600 hz)
uniform float upperMid; // float in range 0-1 measuring upper midrange volume (600-2000 hz)
uniform float highEnd; // float in range 0-1 measuring high end volume (2000-20000 hz)


uniform sampler2D backbuffer;
#define PI 3.14159

float rand(vec2 co){ 
	return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453); 
}

void main(){

	float speed = sin(time)*0.001 + 0.5;
	vec2 p = (gl_FragCoord.xy - 0.5 * resolution) / min(resolution.x, resolution.y);
	vec2 t = vec2(gl_FragCoord.xy / resolution);
	
	vec3 c = vec3(0);
	
	for(int i = 0; i < 30; i++) {
		float t = 0.1 * PI * float(i+1) / 50.0 * time * speed;
		float x = cos(5.0*t)*beat + offset.x*sin(t) + lowerMid - upperMid;
		float y = sin(20.0*fract(t))*beat*volume*2. + offset.y*sin(t) + bass - highEnd;
		vec2 o = 0.30 * vec2(x, y);
		float r = fract(x-y*t);
		float g = 0.5 - r;
		c += 0.01 / (length(sin(p)-o)) * vec3(r, g, 0.8);
	}
	
	gl_FragColor = vec4(c, 1);
}
