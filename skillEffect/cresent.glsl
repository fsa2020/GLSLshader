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

float sdSphere2D( vec2 p, float r )
{
    return length(p)-r;
}

float map(vec2 uv)
{
    float d = sdSphere2D(uv,0.8);
    if(d<0.0)
    {
        d = -sdSphere2D(uv-vec2(0.9,0.0),1.1);
    }
    return d; 
}

vec4 simple(vec2 uv)
{
    vec2 dir = vec2(.1,0);
    float noiseOffset = gradientNoise(28.0*vec2(uv.x-0.5*mod(iTime,10.0),uv.y))-0.5;
    
    float lerp = smoothstep(1.6,.1,length(uv-vec2(0.5,0.0)));

    vec2 p = uv+noiseOffset*dir*lerp*7.0;
    float d = map(p);

    vec4 color = vec4(0.0,0.0,0.0,0.0);
    if(d<0.0){
        color =  vec4(0.5,0.5,0.0,1.0);
    }

    return color;
}
void main() {
	vec2 p = (gl_FragCoord.xy * 2. - iResolution.xy) / iResolution.y;
    vec2 move = vec2(p.x-8.0+mod(5.*iTime,15.0),p.y);
	gl_FragColor = simple(p+move);
}