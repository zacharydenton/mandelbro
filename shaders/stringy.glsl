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

#define NumberOfParticles 64
#define Pi 3.141592

vec3 palette(float x)
{
	return vec3(
		sin(x*2.0*Pi)+1.5,
		sin((x+1.0/3.0)*2.0*Pi)+1.5,
		sin((x+2.0/3.0)*2.0*Pi)+1.5
	)/2.5;
}

float starline(vec2 relpos,float confradius,float filmsize)
{
	if(abs(relpos.y)>confradius) return 0.0;
	float y=relpos.y/confradius;
	float d=abs(relpos.x/filmsize);
	return sqrt(1.0-y*y)/(0.0001+d*d)*0.00001;
}

float star(vec2 relpos,float confradius,float filmsize)
{
	vec2 rotpos=mat2(cos(Pi/3.0),-sin(Pi/3.0),sin(Pi/3.0),cos(Pi/3.0))*relpos;
	vec2 rotpos2=mat2(cos(Pi/3.0),sin(Pi/3.0),-sin(Pi/3.0),cos(Pi/3.0))*relpos;
	return starline(relpos,confradius,filmsize)+
		starline(rotpos,confradius,filmsize)+
		starline(rotpos2,confradius,filmsize);
}

void main(void)
{
	vec2 screenpos=(2.0*gl_FragCoord.xy-resolution.xy)/max(resolution.x,resolution.y);

	float focaldistance=0.5+sin(time*0.05)*0.013;
	float focallength=0.100 ;
	float filmsize=0.036;
	float minconf=filmsize/1000.0;
	float lensradius=focallength/1.4 * beat * bass;

	float filmdistance=1.0/(1.0/focallength-1.0/focaldistance);
	
	vec3 c=vec3(0.0);
	for(int i=0;i<NumberOfParticles;i++)
	{
		float t=float(i)/float(NumberOfParticles) * sin(time);
		float a=t*2.0*Pi+time*0.7;

		vec3 pos=vec3(sin(a)+2.0*sin(2.0*a),cos(a)-2.0*cos(2.0*a),-sin(3.0*a))*0.01 * bass;

		float a1=0.1*time;
		pos.xz*=mat2(cos(a1),-sin(a1),sin(a1),cos(a1));
		//float a2=0.1;
		//pos.yz*=mat2(cos(a2),-sin(a2),sin(a2),cos(a2));

		pos.z+=0.5;
		
		float intensity=0.0000002 * bass;

		vec2 filmpos=pos.xy/pos.z*filmdistance;
		float confradius=lensradius*filmdistance*abs(1.0/focaldistance-1.0/pos.z)+minconf * 5.0* bass;

		float diffusedintensity=intensity/(confradius*confradius) * 5. * volume;

		vec3 colour=palette(t) * beat;

		vec2 relpos=filmpos-screenpos/2.0*filmsize;
		c+=smoothstep(0.0, -0.0001, length(relpos)-confradius)*colour*diffusedintensity;
		c+=colour*diffusedintensity*star(relpos,confradius,filmsize) * bass	;
	}

	gl_FragColor=vec4(pow(c,vec3(1.0/2.2)),1.0);
}
