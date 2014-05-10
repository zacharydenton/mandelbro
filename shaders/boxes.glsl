#ifdef GL_ES
precision mediump float;
#endif

uniform float time;
uniform vec2 mouse;
uniform vec2 resolution;

vec3   iResolution = vec3(resolution, 1.0);
float  iGlobalTime = time;
vec4   iMouse = vec4(mouse, 0.0, 1.0);


uniform float speed; // to adjust animation speed (starts at 1.0)
uniform vec3 offset; // (offset.x, offset.y, offset.z) to support panning/zoom (either with controller or mouse)
uniform float volume; // float in range 0-1 measuring overall song volume
uniform float beat; // close to 1.0 when the beat strikes, 0 off beat
uniform float bass; // float in range 0-1 measuring bass volume (0-150 hz)
uniform float lowerMid; // float in range 0-1 measuring lower midrange volume (150-600 hz)
uniform float upperMid; // float in range 0-1 measuring upper midrange volume (600-2000 hz)
uniform float highEnd; // float in range 0-1 measuring high end volume (2000-20000 hz)


// uniform vec3       iResolution;
// uniform float      iGlobalTime;
// uniform float      iChannelTime[4];
// uniform vec3       iChannelResolution[4];
// uniform vec4       iMouse;
// uniform vec4       iDate;




// I/O fragment shader by movAX13h, August 2013

#define SHOW_BLOCKS

float rand(float x)
{
    return fract(sin(x) * 4358.5453123);
}

float rand(vec2 co)
{
    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5357);
}

float box(vec2 p, vec2 b, float r)
{
  return length(max(abs(p)-b,0.0))-r;
}

float sampleMusic()
{
	return 0.5;
}

void main(void)
{
	const float speed = 0.7;
	const float ySpread = 1.6;
	const int numBlocks = 70;

	float pulse = sampleMusic() * bass;
	
	vec2 uv = gl_FragCoord.xy / iResolution.xy - 0.5;
	float aspect = iResolution.x / iResolution.y;
	vec3 baseColor = uv.x > 0.0 ? vec3(0.0,0.3, 0.6) : vec3(0.6, 0.0, 0.3);
	
	vec3 color = pulse*baseColor*0.5*(0.9-cos(uv.x*8.0));
	uv.x *= aspect;
	
	for (int i = 0; i < numBlocks; i++)
	{
		float z = 1.0-0.7*rand(float(i)*1.4333); // 0=far, 1=near
		float tickTime = iGlobalTime*z*speed + float(i)*1.23753;
		float tick = floor(tickTime);
		
		vec2 pos = vec2(0.6*aspect*(rand(tick)-0.5), sign(uv.x)*ySpread*(0.5-fract(tickTime)));
		pos.x += 0.24*sign(pos.x); // move aside
		if (abs(pos.x) < 0.1) pos.x++; // stupid fix; sign sometimes returns 0
		
		vec2 size = 1.8*z*vec2(0.04, 0.04 + 0.1*rand(tick+0.2)) * 1.5 * (upperMid + lowerMid);
		float b = box(uv-pos, size, 0.01) * cos(lowerMid);
		float dust = z*smoothstep(0.22, 0.0, b)* pulse*0.5 * volume;
		#ifdef SHOW_BLOCKS
		float block = 0.2*z*smoothstep(0.002, 0.0, b) * sin(upperMid);
		float shine = 0.6*z*pulse*smoothstep(-0.002, b, 0.007) * sin(beat) * bass;
		color += dust*baseColor + block*z + shine;
		#else
		color += dust*baseColor;
		#endif
	}
	
	color -= rand(uv)*0.04;
	gl_FragColor = vec4(color, 1.0);
}
