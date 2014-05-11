
#ifdef GL_ES
precision mediump float;
#endif
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

/*
 * inspired by http://www.fractalforums.com/new-theories-and-research/very-simple-formula-for-fractal-patterns/
 * a slight(?) different 
 * public domain
 */

#define N 60
void main( void ) {
	vec2 v = (gl_FragCoord.xy - resolution/2.0) / min(resolution.y,resolution.x) * 20.0;

	float rsum = 0.0;
	float pi2 = 3.1415926535 * 1.*clamp(offset.z+offset.x+offset.y, 3., 4.);
	float a = (1./5.)*pi2;
	float C = cos(a)*(5. + 20.*max(volume,lowerMid));
	float S = sin(a)*5.;
	vec2 xaxis=vec2(C, -S);
	vec2 yaxis=vec2(S, C);
	#define MAGIC 0.618
	vec2 shift = vec2( 0, 1.0+MAGIC);
	float zoom = 1.0 + time*8.0;

	for ( int i = 0; i < N; i++ ){
		float rr = dot(v,v);
		if ( rr > 1.0 )
		{
			rr = (1.0)/rr ;
			v.x = v.x * rr ;
			v.y = v.y * rr;
		}
		rsum *= 1.01;
		rsum += rr/10.;

		v = vec2( dot(v, xaxis), dot(v, yaxis)) + shift +offset.x + offset.y;
	}
	float col1 = fract(rsum);
	col1 = 2.0 * min(col1, 1.0-col1);
	gl_FragColor = vec4(col1, col1, col1, 1.0); 
}
