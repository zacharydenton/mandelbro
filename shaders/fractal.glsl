//JRM

#ifdef GL_ES
precision mediump float;
#endif

uniform vec2 mouse;
uniform sampler2D backbuffer;

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

#define MAXIT 25.

float msin(float n){
    return (1. + sin(n))/2.;
}

vec4 color(float value){
    float r = msin(value + 0.);
    float g = msin(value + 1.);
    float b = msin(value + 2.);
    return vec4(r, g, b, 1);
}

vec2 cln(vec2 z){
    return vec2(log(z.x*z.x+z.y*z.y)*0.5, atan(z.y,z.x));
}


vec2 cpow(vec2 z, float n){
     vec2 c;
     float mag = pow(z.x*z.x + z.y*z.y, n/2.);
     float deg = n * atan(z.y,z.x);
     c.x = cos(deg)*mag;
     c.y = sin(deg)*mag;
     return c;
}

vec2 cexp(vec2 z){
    float ep = pow(2.718281,z.x);
    return vec2(ep*cos(z.y), ep*sin(z.y));
}

vec2 cmult(vec2 a, vec2 b){
    return vec2(a.x*b.x-a.y*b.y,a.x*b.y+a.y*b.x);
}

vec2 cdiv(vec2 a, vec2 b){
    float v = b.x*b.x + b.y*b.y;
    return vec2((a.x*b.x+a.y*b.y),(-a.x*b.y+a.y*b.x))/v;
}



void main() {
  vec2 pos = gl_FragCoord.xy/resolution.xy;
  pos -= 0.5;
  pos.x *= resolution.x/resolution.y;
  pos*=2.;


  vec2 z = pos;
  float minimum = 10e5;
  float tm=time * beat;
  vec2 v = vec2(-0.54 + (cos(tm)-1.0)*0.02, sin(tm)*0.02+.02);
  for(float n = 0.; n < MAXIT; n++){
    z = cexp(cpow(z,3.)) + v;

    float l = length(z-pos);
    if(l < minimum)
        minimum = l;
  }

  gl_FragColor = color(minimum*6.);

}
