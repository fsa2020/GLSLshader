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

float sdRing( vec2 p,float r, float w )
{
    float d = length(p)-r;
    if(d<-w)
    {
        d = - d;
    }
    return d;
}

mat2 rot(float a) {
	float c = cos(a), s = sin(a);
	return mat2(c,s,-s,c);
}

float map(vec2 uv)
{

    float t = mod(iTime*1.5,12.0)+11.0;
    vec2 p1 = uv*rot(2.1*t);
    float d = sdRing(p1*vec2(1.3,1.0),0.5,0.05);

    vec2 p2 = uv*rot(2.2*t);
    d = min(d,sdRing(p2*vec2(1.3,1.0),0.5,0.05));

    vec2 p3 = uv*rot(2.3*t);
    d = min(d,sdRing(p2*vec2(1.3,1.2),0.6,0.05));


    return d; 
}


float easeIn(float t)
{
    return 1.0-cos(0.5*3.1415*t);
}

vec4 simple(vec2 uv)
{    

    vec2 dir = vec2(.1,0);
    float noiseOffset = gradientNoise(50.0*vec2(uv.x-0.5*mod(iTime,10.0),uv.y))-0.5;
    
    float lerp = smoothstep(0.0,1.0,uv.x+0.1);
    float lerpY = smoothstep(0.25,1.0,abs(uv.y));

    vec2 p = uv+noiseOffset*dir*lerpY*lerp*30.;

    float d = map(p*rot(-8.3*iTime));

    vec4 color = vec4(0.0,0.0,0.0,0.0);
    float lerp2 = smoothstep(0.1,-0.1,d);
   
    color = lerp2*vec4(0.7,0.7,0.95,1.0);
    return color;
}

void main() {
	vec2 p = (gl_FragCoord.xy * 2. - iResolution.xy) / iResolution.y;

    vec2 move = vec2(-4.0+mod(4.*iTime,10.0),0.0);

	gl_FragColor = simple(p);
}