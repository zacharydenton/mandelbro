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

#ifdef GL_ES
precision mediump float;
#endif

#define pi    3.1415926535897932384626433832795 //pi

vec3 hsv2rgb(vec3 c)
{
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

vec4 spuke(vec4 pos)
{
	vec2 p   =((pos.z+offset.xy*pi)+(sin((((length(sin(offset.xy*(pos.xy)+time*pi)))+(cos((offset.xy-time*pi)/pi)))))*offset.xy))+pos.xy*pos.z; 
	vec3 col = vec3( 0.0, 0.0, 0.0 );
	float ca = 0.0;
	for( int j = 1; j < 10; j++ )
	{
		p *= 1.4;
		float jj = float( j );
		
		for( int i = 1; i <6; i++ )  
		{
			vec2 newp = p*0.96;
			float ii = float( i );
			newp.x += 1.2 / ( ii + jj ) * sin( ii * p.y + (p.x*.3) + cos(time/pi/pi)*pi*pi + 0.003 * ( jj / ii ) ) + 1.0;
			newp.y += 0.8 / ( ii + jj ) * cos( ii * p.x + (p.y*.3) + sin(time/pi/pi)*pi*pi + 0.003 * ( jj / ii ) ) - 1.0;
			p=newp;
			
		
		}
		p   *= 0.9;
		col += vec3( 0.5 * sin( pi * p.x ) + 0.5, 0.5 * sin( pi * p.y ) + 0.5, 0.5 * sin( pi * p.x ) * cos( pi * p.y ) + 0.5 )*(0.5*sin(pos.z*pi)+0.5);
		ca  += 0.7;
	}
	col /= ca;
	return vec4( col * col * col, 1.0 );
}
float w=time;

float o(vec3 p)
{
	return min(cos(p.x)+cos(p.y)+cos(p.z)+cos(p.y*20.)*.02,length(max(abs(p-vec3(cos(p.z)*.2,cos(p.z)*.2-.5,.0))-vec3(.2,.02,w+3.),vec3(0))));
}

vec3 n(vec3 p)
{
	return normalize(vec3(o(p+vec3(.02,0,0)),o(p+vec3(0,.02,0)),o(p+vec3(0,0,.02))));
}

void main()
{
	vec2 pos = ((gl_FragCoord.xy / resolution.xy)-.5)*vec2(1. + upperMid,1.);
	vec3 s=vec3(cos(w),-cos(w*.5)*.5+.5,w);
	vec3 e=normalize(vec3(pos,0.29 + 0.01* beat));
	vec3 p=s;
	for(int i=0;i<55;i++)
		p+=e*o(p);
	vec3 pp=p+=e=reflect(e,n(p));
	for(int i=0;i<55;i++)
		p+=e*o(p);
	gl_FragColor=spuke(abs(dot(n(p),vec3(0.1)))+vec4(0.2,cos(w*.5)*.5+.5,sin(w*.5)*.5+.5,1.)*length(p-s)*0.01+length(p-s)*.01+(1.-min(pp.y+2.,1.))*vec4(hsv2rgb(vec3(fract(time / 30.0), 0.7, 0.3)), 1.));
}
