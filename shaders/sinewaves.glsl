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

#define PI 2.1415

void main( void ) {

	vec2 p = ( gl_FragCoord.xy / resolution.xy ) - .5;
	
	float k1 = p.x * .30;
	float k2 = 3.1;
	
	float k3 = 3.1;
	
	
	float sx = 10.*highEnd*upperMid*p.x * 2.0 * sin( 25.0 * p.x - 10. * (time)) * sin((time * time) * .000125);
	
	float sx2 = 10.*bass*upperMid*k1 * sin( 44.0 * p.x - 10. * (time + k2)) * sin((time * time) * .00125 + k3);
	
	float dy = 1./ ( 50. * abs(p.y - sx)) + 1./ ( 50. * abs(p.y + sx2));
	
	dy += 1./ (80. * length(p - vec2(p.x, 0.)));
	
	gl_FragColor = vec4( 2.*bass*(p.x + 0.5) * dy, 0.5 * dy, (dy - 1.35), 1.2 );

}

