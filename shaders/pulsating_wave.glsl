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

#define PI 3.14159

void main(){
	vec2 p = (gl_FragCoord.xy - 0.5 * resolution) / min(resolution.x, resolution.y);

	vec2 t = vec2(gl_FragCoord.xy / resolution);

	vec3 c = vec3(0);

	for(int i = 0; i < 30; i++) {
		float t = 0.1 * PI * float(i+1) / 50.0 * time;
		float x = clamp(offset.x, 1., 2.)*cos(5.0*t)*sin(volume)*resolution.x/100.*bass;
		float y = clamp(offset.y,1.,2.)*sin(20.0*fract(t)) * volume *beat *lowerMid *bass*10.;
		vec2 o = 0.30 * vec2(x, y);
		float r = fract(x-y*t);
		float g = 0.5 - r;
		c += 0.01 / (length(sin(p)-o)) * vec3(r, g, sin(lowerMid));
	}

	gl_FragColor = vec4(c + clamp(offset.z, 0., .4), 1);

}
