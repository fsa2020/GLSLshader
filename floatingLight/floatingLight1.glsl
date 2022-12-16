#iChannel0 "file://textures/icon2.png"

float countGray(vec4 color){
    return color.r*0.3+color.g*0.59+color.b*0.11;
}

vec4 lightColor(vec2 orgUV)
{
    float gap = 0.01;
    vec4 colors = texture(iChannel0,orgUV+vec2(0.0,gap))+texture(iChannel0,orgUV+vec2(gap,0.0))+ texture(iChannel0,orgUV+vec2(0.0,-gap))+texture(iChannel0,orgUV+vec2(-gap,0.0));
    return colors*0.25*0.5+vec4(1.0,1.0,1.0,1.0);
}

// t -> 0-1.0
float easeOut(float t)
{
    return sin(0.5*3.1415*t);
}

vec4 sampling(vec2 orgUV,float len,vec2 dir)
{

    float lineX = -1.0*orgUV.y-0.1+2.2*easeOut(mod(0.3*iGlobalTime,1.0));

    float width = 0.1;

    float gray = countGray(texture(iChannel0,orgUV));

    float lerpW = smoothstep(width,0.0,abs(lineX-orgUV.x));
    
    float lerpG = smoothstep(0.3,1.0,gray);

    vec4 light =lightColor(orgUV);

    vec4 lerpedColorW = (1.0-lerpW)*texture(iChannel0,orgUV)+lerpW*light;

    vec4 lerpedColorG =  (1.0-lerpG)*texture(iChannel0,orgUV)+lerpG*lerpedColorW;

    return lerpedColorG;
}


void main() {
    
    float threshold = 0.7;
    vec2 dir = vec2(-1.0,0);

    float time = iGlobalTime * 1.0;
    vec2 uv = (gl_FragCoord.xy / iResolution.xy);

    vec4 sampleColor = sampling(uv,0.11,normalize(dir));

    gl_FragColor = sampleColor;


}