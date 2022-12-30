#iChannel0 "file://textures/icon2.png"

vec4 lightColor(vec2 orgUV)
{
    float gap = 0.01;
    vec4 colors = texture(iChannel0,orgUV+vec2(0.0,gap))+texture(iChannel0,orgUV+vec2(gap,0.0))+ texture(iChannel0,orgUV+vec2(0.0,-gap))+texture(iChannel0,orgUV+vec2(-gap,0.0));
    return colors*0.5*vec4(1.,1.,1.,texture(iChannel0,orgUV).a);
}

// t -> 0-1.0
float easeOut(float t)
{
    return sin(0.5*3.1415*t);
}

float easeIn(float t)
{
    return 1.0-cos(0.5*3.1415*t);
}


vec2 norm(vec2 orgUV)
{
    vec2 offset = vec2(0.5,0.5)-orgUV;
    float dis = distance(offset,vec2(0.0,0.0));
    float disLerp = min(dis/distance(vec2(2.8,0.8),vec2(0.0,0.0)),1.0);
    return (1.0-disLerp)*offset;
}

vec4 sampling(vec2 orgUV,float len,vec2 dir)
{

    vec2 normledUV = orgUV +norm(orgUV);

    float lineX = -1.0*normledUV.y-0.1+2.2*easeIn(mod(0.5*iGlobalTime,1.0));

    float width = 0.1;

    float lerpW = smoothstep(width,0.0,abs(lineX-normledUV.x));

    vec4 light =lightColor(orgUV);

    vec4 lerpedColorW = (1.0-lerpW)*texture(iChannel0,orgUV)+lerpW*light;

    return lerpedColorW;
}


void main() {
    
    float threshold = 0.7;
    vec2 dir = vec2(-1.0,0);

    float time = iGlobalTime * 1.0;
    vec2 uv = (gl_FragCoord.xy / iResolution.xy);

    vec4 sampleColor = sampling(uv,0.11,normalize(dir));

    gl_FragColor = sampleColor;


}