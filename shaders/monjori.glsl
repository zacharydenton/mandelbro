// http://code.ikriz.nl/unity-shaders/src/1aa94147d53f/GLSL%20Shaders/Monjori.shader

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

void main(void)
{
	vec2 vPixel=gl_FragCoord.xy;

	vec2 vScreen=resolution;
	vec2 vMouse=vec2(0.1,0.1)+offset.xy;

	float fTime=(1.0 + sin(time / 10.0)*0.5) * 20.0;

	vec2 p=-1.0+2.0*vPixel/vScreen;

	float a=fTime*40.0;
	float d,e,f,g=(1.0-(0.05 * bass))/40.0,h,i,r,q;

	e=(vMouse.x*400.0)*(p.x*0.5+0.5);
	f=(vMouse.y*400.0)*(p.y*0.5+0.5);
	i=(vMouse.x*200.0)+sin(e*g+a/150.0)*20.0;
	d=(vMouse.y*200.0)+cos(f*g/2.0)*18.0+cos(e*g)*7.0;
	r=sqrt(pow(i-e,2.0)+pow(d-f,2.0));
	q=f/r;
	e=(r*cos(q))-a/2.0;f=(r*sin(q))-a/2.0;
	d=sin(e*g)*176.0+sin(e*g)*164.0+r;
	h=((f+d)+a/2.0)*g;
	i=cos(h+r*p.x/1.3)*(e+e+a)+cos(q*g*6.0)*(r+h/3.0);
	h=sin(f*g)*144.0-sin(e*g)*212.0*p.x;
	h=(h+(f-e)*q+sin(r-(a+h)/7.0)*10.0+i/4.0)*g;
	i+=cos(h*2.3*sin(a/(350.0-10.0*highEnd)-q))*184.0*sin(q-(r*4.3+a/12.0)*g)+tan(r*g+h)*184.0*cos(r*g+h);
	i=mod(i/3.6,256.0)/64.0;

	if(i<0.0) i+=4.0;
	if(i>=2.0) i=4.0-i;

	d=r/350.0;
	d+=sin(d*d*8.0)*0.52;
	f=(sin(a*g)+1.0)/2.0;

	gl_FragColor=vec4(vec3(f*i/1.6,i/2.0+d/(13.0-3.0 * bass),i)*d*p.x+vec3(i/(1.0 * 0.9 * lowerMid)+d/(8.0 + 4.0 * bass),i/2.0+d/(10.0 + 8.0 * upperMid),i)*d*beat*(1.0-p.x),1.0);
}
