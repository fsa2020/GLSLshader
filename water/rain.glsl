#iChannel0 "file://shaders/textures/123.jpg"

vec2 TILE_NUM = vec2(8,2);

vec2 TILE_NUM2 = vec2(15,5);

vec2 TILE_NUM3 = vec2(20,7);

// simple noise
vec2 hash( vec2 p )
{
    p = vec2( dot(p,vec2(127.1,311.7)), dot(p,vec2(269.5,183.3)) );
    return -1.0 + 2.0*fract(sin(p)*43758.5453123);
}

float simpleNoise( vec2 p )
{
    const float K1 = 0.366025404; 
    const float K2 = 0.211324865;

    vec2  i = floor( p + (p.x+p.y)*K1 );
    vec2  a = p - i + (i.x+i.y)*K2;
    float m = step(a.y,a.x); 
    vec2  o = vec2(m,1.0-m);
    vec2  b = a - o + K2;
    vec2  c = a - 1.0 + 2.0*K2;
    vec3  h = max( 0.5-vec3(dot(a,a), dot(b,b), dot(c,c) ), 0.0 );
    vec3  n = h*h*h*h*vec3( dot(a,hash(i+0.0)), dot(b,hash(i+o)), dot(c,hash(i+1.0)));
    return dot( n, vec3(70.0) );
}

// -0.5 ~ 0.5
vec2 getCircleScaledUV(vec2 orgUV,vec2 uv,vec2 p,float r,vec2 tileNum){
    float dis = length(uv-p);
    float scale = 5.5;
    dis += clamp(0.1*simpleNoise(5.0*orgUV),0.0,r);
    if(dis>r ){
        return vec2(0,0);
    }
    else{
        scale = mix(scale,1.0,dis/r);
        vec2 orgP = vec2(floor(orgUV.x*TILE_NUM.x)+p.x,floor(orgUV.y+TILE_NUM.y)+p.y);
        vec2 orgOffset = vec2((uv-p).x/TILE_NUM.x,(uv-p).y/TILE_NUM.y);
        return orgOffset/scale;
    }
}

vec2 getTiledUV(vec2 uv,vec2 tileNum){
    float tiledX = uv.x*(tileNum.x);
    float tiledY = uv.y*(tileNum.y);
    return fract(vec2(tiledX,tiledY+clamp(simpleNoise(10.0*uv),-0.2,0.2)));
}

vec2 getMove(float speed,vec2 uv){
    float t = iGlobalTime * 1.0;
    vec2 dir = normalize(vec2(0.5,1.0));
    dir *=dir*speed*t;
    dir = vec2(dir.x,dir.y+0.001*simpleNoise(0.5*t+8.0*uv));
    return dir;
}

bool mouseClean(float r,vec2 uv){
    vec2 mPos = iMouse.xy/ iResolution.xy;
    if(length(mPos-uv)>r){
        return false;
    }
    else{
        return true;
    }
}

void main() {
  float time = iGlobalTime * 1.0;
  vec2 uv = (gl_FragCoord.xy / iResolution.xy);

  vec2 uvTiled = getTiledUV(uv+getMove(0.6,uv),TILE_NUM);
  uvTiled = getCircleScaledUV(uv,uvTiled,vec2(0.5,0.5),0.12,TILE_NUM);

  vec2 uvTiled2 = getTiledUV(uv+getMove(0.3,uv),TILE_NUM2);
  uvTiled2 = getCircleScaledUV(uv,uvTiled2,vec2(0.5,0.5),0.12,TILE_NUM2);

  vec2 uvTiled3 = getTiledUV(uv+getMove(0.15,uv),TILE_NUM3);
  uvTiled3 = getCircleScaledUV(uv,uvTiled3,vec2(0.5,0.5),0.1,TILE_NUM3);

  if(mouseClean(0.2,uv)){
    gl_FragColor = texture(iChannel0,uv);
  }
  else{
    //gl_FragColor = texture(iChannel0,uv);
    gl_FragColor = texture(iChannel0,uv+uvTiled+uvTiled2+uvTiled3);
  }
}