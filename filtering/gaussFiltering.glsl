#iChannel0 "file://textures/icon.png"

vec2 mouseFloatPos(){
    return vec2(iMouse.x,-iMouse.y) / iResolution.xy;
}
vec2 timePos(){
    return vec2(iGlobalTime*0.1);
}

float GaussFunc2D(float x,float y,float sigma)
{
    return pow(2.71828,-(x*x+y*y)/(2.0*sigma*sigma))/(3.14159*2.0*sigma*sigma);
}

vec4 biFilter(vec2 uv)
{
    float sumWeight = 0.0;
    vec4 color = vec4(0,0,0,0);
    float r = ;
    for(float i=-r; i<r; i = i+1.0)
    {
        for(float j=-r; j<r; j = j+1.0)
        {
            vec2 p = vec2(i*0.01,j*0.01)+uv;
            float w = GaussFunc2D(i*0.01,j*0.01,0.01);
            sumWeight += w;
            color += w*texture(iChannel0,p);
        }
    }
    color = color/sumWeight;
    return color;
}

void main() {
    float time = iGlobalTime * 1.0;
    vec2 uv = (gl_FragCoord.xy / iResolution.xy);
    vec4 filterColor = biFilter(uv);
    gl_FragColor =filterColor;
}