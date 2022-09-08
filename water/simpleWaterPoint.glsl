#iChannel0 "file://textures/123.jpg"

vec2 mouseClickPos(){
    return iMouse.zw/ iResolution.xy;
}
vec2 mouseFloatPos(){
    return iMouse.xy/ iResolution.xy;
}
vec2 getWaterCircle(vec2 uv,vec2 p,float maxR){
    float dis = length(uv-p);
    vec2 dir = normalize(uv-p);
    if(dis>maxR){
        return vec2(0,0);
    }
    else{
        float sin1 = sin(120.0*dis-1.5*iTime)*0.02;
        float sin2 = sin1+sin(80.0*dis-iTime*.8)*0.02;

        return dir*sin2*mix(1.0,0.0,dis/maxR);
    }
}

void main() {
    float time = iGlobalTime * 1.0;
    vec2 uv = (gl_FragCoord.xy / iResolution.xy);
    gl_FragColor = texture(iChannel0,uv+getWaterCircle(uv,vec2(0.5,0.5),0.2)+getWaterCircle(uv,mouseFloatPos(),0.3));
}