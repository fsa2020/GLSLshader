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



// 圓锥
float sdCone( vec3 p, float an, float h )
{

	vec2 c = vec2(sin(an),cos(an));
    vec2 q = h*vec2(c.x,-c.y)/c.y;
    vec2 w = vec2( length(p.xz), p.y );
    
	vec2 a = w - q*clamp( dot(w,q)/dot(q,q), 0.0, 1.0 );
    vec2 b = w - q*vec2( clamp( w.x/q.x, 0.0, 1.0 ), 1.0 );
    float k = sign( q.y );
    float d = min(dot( a, a ),dot(b, b));
    float s = max( k*(w.x*q.y-w.y*q.x),k*(w.y-q.y)  );
	return sqrt(d)*sign(s);
}

mat2 rot(float a) {
	float c = cos(a), s = sin(a);
	return mat2(c,s,-s,c);
}

float map(vec3 pos) {
	vec2 mouse = vec2(-1.0*iMouse.xy/ iResolution.xy)+0.5;
	pos.xz = pos.xz*rot(0.0);
	pos.yz = pos.yz*rot(0.2);

    //  deal pos
    
    pos = pos-vec3(.0,-0.5,.0);
    vec3 move = vec3(-3.0+mod(iTime,6.0),0.0,0.0);
    pos += move;
    pos.y = -pow(pos.y,3.0);    

	float res = sdCone(pos, 0.3,0.7);

	return res;
}


void main() {
	vec2 p = (gl_FragCoord.xy * 2. - iResolution.xy) / iResolution.y;
	vec3 ro = vec3(0.0, 0. , -2.0)+vec3(0.0,0.0,0.0);
	vec3 ray = normalize(vec3(p,3.0));
	float rayStep = 0.1;
	float ac = 0.0;


	for (int i = 0; i < 30; i++){
		vec3 pos = ro + ray * rayStep;

        vec3 dir = vec3(.1,-0.05,.0);

        float noiseOffset = gradientNoise(18.0*vec2(pos.x-0.5*mod(iTime,10.0),pos.y))-0.5;
        
        float lerp = smoothstep(-.5,0.5,length(pos.y-0.0));

        pos = pos+noiseOffset*dir*0.8*lerp;
        
		float d = map(pos);

		rayStep += max(abs(d),0.01)*0.5;

		if (d<0.0){
			ac += exp(-max(abs(d),0.1))*0.025;
			rayStep += 0.001;
		}
		else{
			rayStep += max(abs(d),0.01)*0.5;
		}
	}

	vec3 col = vec3(ac);
	col +=vec3(0.,0.0,0.0);
	gl_FragColor = vec4(col ,0.0 );
}
