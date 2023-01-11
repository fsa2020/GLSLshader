// 2d gradient noise
vec2 random2(vec2 st){
    st = vec2( dot(st,vec2(127.1,311.7)),
              dot(st,vec2(269.5,183.3)) );
    return -1.0 + 2.0*fract(sin(st)*43758.5453123);
}

float gradientNoise(vec2 st) {
    vec2 i = floor(st);
    vec2 f = fract(st);

    vec2 u = f*f*(3.0-2.0*f);

    return mix( mix( dot( random2(i + vec2(0.0,0.0) ), f - vec2(0.0,0.0) ),
                     dot( random2(i + vec2(1.0,0.0) ), f - vec2(1.0,0.0) ), u.x),
                mix( dot( random2(i + vec2(0.0,1.0) ), f - vec2(0.0,1.0) ),
                     dot( random2(i + vec2(1.0,1.0) ), f - vec2(1.0,1.0) ), u.x), u.y);
}

float sdStar5(vec2 p, float r, float rf)
{
    const vec2 k1 = vec2(0.809016994375, -0.587785252292);
    const vec2 k2 = vec2(-k1.x,k1.y);
    p.x = abs(p.x);
    p -= 2.0*max(dot(k1,p),0.0)*k1;
    p -= 2.0*max(dot(k2,p),0.0)*k2;
    p.x = abs(p.x);
    p.y -= r;
    vec2 ba = rf*vec2(-k1.y,k1.x) - vec2(0,1);
    float h = clamp( dot(p,ba)/dot(ba,ba), 0.0, r );
    return length(p-ba*h) * sign(p.y*ba.x-p.x*ba.y);
}


mat2 rot(float a) {
	float c = cos(a), s = sin(a);
	return mat2(c,s,-s,c);
}

float map(vec2 uv)
{

    float noiseOffset = gradientNoise(1.5*vec2(iTime,0.0))-0.5;
    

    float t = -iTime*1.5;
    vec2 floating = vec2(0.0,0.05)*sin(t);
    vec2 p1 = (uv+floating)*rot(.5*t);
    float d = sdStar5(p1,0.5,0.4);

    vec2 p2 = (uv+vec2(-0.45,0.4)+floating+vec2(0.1,0.1)*(gradientNoise(1.5*vec2(iTime,0.0))-0.5))*rot(1.8*t);
    d = min(d,sdStar5(p2,0.15,0.4));

    vec2 p3 = (uv+vec2(-0.5,-0.4)+floating+vec2(0.1,0.1)*(gradientNoise(1.5*vec2(iTime-0.5,0.0))-0.5))*rot(1.8*t);
    d = min(d,sdStar5(p3,0.13,0.4));

    vec2 p4 = (uv+vec2(-0.78,0.4)+floating+vec2(0.1,0.1)*(gradientNoise(1.5*vec2(iTime-1.0,0.0))-0.5))*rot(2.5*t);
    d = min(d,sdStar5(p4,0.1,0.4));

    vec2 p5 = (uv+vec2(-0.8,-0.4)+floating+vec2(0.1,0.1)*(gradientNoise(1.5*vec2(iTime-2.0,0.0))-0.5))*rot(2.5*t);
    d = min(d,sdStar5(p5,0.1,0.4));

    vec2 p6 = (uv+vec2(-0.99,-0.4)+floating+vec2(0.1,0.1)*(gradientNoise(1.5*vec2(iTime-2.5,0.0))-0.5))*rot(2.5*t);
    d = min(d,sdStar5(p6,0.08,0.4));
    return d; 
}


float easeIn(float t)
{
    return 1.0-cos(0.5*3.1415*t);
}

vec4 simple(vec2 uv)
{    
    float d = map(uv);

    vec4 color = vec4(0.0,0.0,0.0,0.0);
    float lerp2 = smoothstep(0.0,-0.02,d);
   
    color = lerp2*vec4(0.7,0.7,0.25,1.0);
    return color;
}

void main() {
	vec2 p = (gl_FragCoord.xy * 2. - iResolution.xy) / iResolution.y;

    vec2 move = vec2(-4.0+mod(4.*iTime,10.0),0.0);

	gl_FragColor = simple(p+move);
}