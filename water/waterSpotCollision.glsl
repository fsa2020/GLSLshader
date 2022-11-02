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


float getModTime()
{
    float ep = 5.0;
    float arriveTime = 1.45;
    return mod(ep+iTime-arriveTime,ep);
}

float targetBox(vec2 uv){
    vec2 center = vec2(0.5,0.25);
    return pow(uv.x-center.x,2.0)+pow(uv.y-center.y,2.0) -0.04;
}

float waterFloating(vec2 uv){
    float t =getModTime();
    float torY = uv.y+0.04*cos(uv.y+t);
    float torX = uv.x+0.01*cos(1000.0*uv.x+t);
    return targetBox(vec2(torX,torY));
}

bool isWaterPanel(vec2 uv){
    float t = getModTime();
    float lp = lerpFunc(t,4.4,5.0);
    return lp*waterFloating(uv)+(1.0-lp)*targetBox(uv) < 0.0;
}

bool isWater(vec2 uv){
    float t = getModTime();
    return (isWaterSpot(uv) && t < 4.6) || isWaterPanel(uv);
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