float sdLineX( vec2 p,float y, float r )
{
    return abs(p.y-y)-r;
}

float map(vec2 uv)
{
    float d = sdLineX(uv,0.0,0.24);
    d = min(d,sdLineX(uv,0.3,0.02));
    d = min(d,sdLineX(uv,-0.3,0.02));
    d = min(d,sdLineX(uv,0.36,0.005));
    d = min(d,sdLineX(uv,-0.36,0.005));
    d = min(d,sdLineX(uv,0.4,0.001));
    d = min(d,sdLineX(uv,-0.4,0.001));

    return d; 
}

float easeIn(float t)
{
    return 1.0-cos(0.5*3.1415*t);
}

vec4 simple(vec2 uv)
{    
    float holdTime = 3.0;

    float t = mod(iTime,holdTime*1.25);
    t =   easeIn(easeIn(easeIn(easeIn(t))));
    float atkTime = easeIn(easeIn(easeIn(easeIn(0.8))));

    float d = map(uv);
    float o = min(t,1.0);
    float s = min(0.25,t*t*(1.0/(holdTime*holdTime)));
    float lerp = smoothstep(s,0.0,d);
    vec4 color = (1.0-lerp)*vec4(0.0,0.0,0.0,0.0)+lerp*vec4(0.7,0.7,0.7,1.0);

    color = color*o;
    return color;
}

void main() {
	vec2 p = (gl_FragCoord.xy * 2. - iResolution.xy) / iResolution.y;
	gl_FragColor = simple(p);
}