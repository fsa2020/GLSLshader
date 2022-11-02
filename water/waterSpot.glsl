vec2 transWaterSpot(vec2 uv){
    float t = mod(iTime,5.0);
    uv.y = uv.y+0.9*t*t;
    return vec2(1.2-uv.y,uv.x-0.5)*15.0;
}
bool isWaterSpot(vec2 uv){
    vec2 c = transWaterSpot(uv);
    return pow(c.x*c.x+c.y*c.y,2.0)-2.0*c.x*(c.x*c.x+c.y*c.y)+3.0*c.y*c.y <= 0.0;
}

// fast reach top and slow to bottom
float lerpFunc(float t,float tMin, float tMax)
{
    float pi = 3.1415926;
    float l = 0.1;
    if(t<tMin) { t=tMin;}
    if(t>tMax) { t=tMax;}
    if ((t-tMin) < (tMax-tMin)*l) {
        return sin((t-tMin)*((pi*0.5)/((tMax-tMin)*l)));
    }
    else{
       return cos((t-tMin-(tMax-tMin)*l)*((pi*0.5)/((tMax-tMin)*(1.0-l)))) ;
    }    
}

float waterFloating(float x){
    return 0.2+0.05*(0.5-abs(x-0.5))*cos(100.0*pow(x-0.5,2.0)-5.0*iTime);
}

bool isWaterPanel(vec2 uv){
    float arriveTime = 1.5;
    float t = mod(2.0+iTime-arriveTime,5.0);
    float lp = lerpFunc(t,arriveTime,3.0);

    // float lp = 1.0;

    return lp*waterFloating(uv.x)+(1.0-lp)*0.2 > uv.y;
    // return false;
}



bool isWater(vec2 uv){
    return isWaterSpot(uv) || isWaterPanel(uv);
}
void main() {
    float time = iGlobalTime * 1.0;
    vec2 uv = (gl_FragCoord.xy / iResolution.xy);
    if(! isWater(uv)){
        gl_FragColor = vec4(0,0,0,1);
    }
    else{
        gl_FragColor = vec4(1,1,1,1);;
    }
}