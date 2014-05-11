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

vec3 hsv2rgb(vec3 c)
{
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

void main(void)
{
	float scale = pow(0.01, offset.z);
	vec2 z, c;

	c.x = (resolution.x / resolution.y) * (gl_FragCoord.x / resolution.x - 0.5) * scale + offset.x * 2.0;
	c.y = (gl_FragCoord.y / resolution.y - 0.5) * scale + offset.y * 2.0;

	int iters = 0;
	z = c;
	float minMag = 999999.0;
	for(int i=0; i<150; i++) {
		float x = (z.x * z.x - z.y * z.y) + c.x;
		float y = (z.y * z.x + z.x * z.y) + c.y;

		float mag = length(z);
		if (mag < minMag) {
			minMag = mag;
		}

		if((x * x + y * y) > 4.0) {
			iters = i;
			break;
		}
		z.x = x;
		z.y = y;
	}

	if (iters == 150) {
		gl_FragColor = vec4(0.0, 0.0, 0.0, 1.0);
	} else {
		float center = mod(time / 30.0, 1.0);
		gl_FragColor = vec4(hsv2rgb(vec3(center + bass * 0.5 * minMag, 1.0 - (0.5 * volume), 1.0 - minMag)), 1.0);
	}
}
