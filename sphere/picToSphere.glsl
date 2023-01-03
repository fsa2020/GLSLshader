#iChannel0 "file://textures/icon.png"

vec2 mouseClickPos(){
    return iMouse.zw/ iResolution.xy;
}
vec2 mouseFloatPos(){
    return vec2(iMouse.x,-iMouse.y) / iResolution.xy;
}
vec2 timePos(){
    return vec2(iGlobalTime*0.1);
}

vec2 uvToSphere(vec2 uv,float r)
{
    vec2 center = vec2(0.5,0.5);
    uv = uv-center;

    float rx = pow(r*r-uv.y*uv.y,0.5);
    float sx = min(1.0,rx/r);

    float ax = acos((uv.x)/(r*sx));


    float ry = pow(r*r-uv.x*uv.x,0.5);
    float sy = min(1.0,ry/r);

    float ay = acos((uv.y)/(r*sy));


    float pi = 3.1416;


    return vec2(ax/(pi),-ay/(pi));
}

void main() {
    float time = iGlobalTime * 1.0;
    vec2 uv = (gl_FragCoord.xy / iResolution.xy);
    gl_FragColor = texture(iChannel0,uvToSphere(uv,0.2)+timePos()+mouseFloatPos());
}