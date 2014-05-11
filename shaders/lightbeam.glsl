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


void main( void ) {

	vec2 position = ( gl_FragCoord.xy / resolution.xy );
	float light = pow(1.0-abs(position.y-0.5),10.*beat+clamp(offset.z, 0., 100.));
	gl_FragColor = vec4( pow(light,bass+abs(cos(-time+position.x*(1.0+cos(position.x-time)))/1.0))*2.0,light*1.0,light/2.0, 500000.0 );

}


