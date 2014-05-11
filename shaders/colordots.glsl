// @paulofalcao
//
// Blue Pattern
//
// A old shader i had lying around
// Although it's really simple, I like the effect :)
// modified by @hintz

#ifdef GL_ES
precision highp float;
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
	vec2 u=(gl_FragCoord.xy/resolution.x)*2.0-vec2(1.0,resolution.y/resolution.x);
	float t=max(sin(offset.x*time),bass)*0.5;

	float tt=max(highEnd*10., 1.)*(sin(volume)+1.)*64.0;
	float x=u.x*tt+sin(t*2.1)*4.0;
	float y=u.y*tt+cos(t*2.3)*4.0;
	float c=sin(x)+sin(y);
	float zoom=sin(t)*sin(bass);
	x=(offset.z+1.)*x*zoom*2.0+sin(t*1.1);
	y=(offset.z+1.)*y*zoom*2.0+cos(t*1.3);
	float xx=cos(t*0.7)*x-sin(t*0.7)*y;
	float yy=sin(t*0.7)*x+cos(t*0.7)*y;
	c=(sin(c+(sin(xx)+sin(yy)))+1.0)*0.4;
	float v=2.0-length(u)*2.0;
	gl_FragColor=vec4(v*vec3(c+v*0.4,(offset.x+offset.y)*c*c-0.5+v*0.5,sin(bass)*c*2.),1.0);
}
