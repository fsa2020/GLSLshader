float ndot( in vec2 a, in vec2 b ) { return a.x*b.x - a.y*b.y; }

// Material
struct Material{
    vec3 col_a; // ambient
    vec3 col_d; // diffuse
    vec3 col_s; // spec
    float roughness;
};

// Phong 
vec4 PS(Material mat, vec3 p, vec3 norm, vec3 view, vec3 l_pos, vec3 l_col){
    vec3 l_dir = normalize(l_pos - p);
    vec3 ambient = mat.col_a;
    vec3 diffuse = mat.col_d * max(0., dot(norm, l_dir)) ;
    
    vec3 v_ref = normalize(view + 2. * norm); 
    vec3 spec = mat.col_s * pow(max(0., dot(v_ref, l_dir)), mat.roughness);
    
    vec4 res = vec4((ambient + diffuse + spec) * l_col, 1.);
    return res;
}

mat2 rot(float a) {
	float c = cos(a), s = sin(a);
	return mat2(c,s,-s,c);
}

float sdPlane( vec3 p )
{
	return p.y;
}

float sdSphere( vec3 p, float s )
{
    return length(p)-s;
}

float sdBox( vec3 p, vec3 b )
{
	vec3 q = abs(p) - b;
	return length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0);
}

float sdBoxFrame( vec3 p, vec3 b, float e )
{
       p = abs(p  )-b;
  vec3 q = abs(p+e)-e;

  return min(min(
      length(max(vec3(p.x,q.y,q.z),0.0))+min(max(p.x,max(q.y,q.z)),0.0),
      length(max(vec3(q.x,p.y,q.z),0.0))+min(max(q.x,max(p.y,q.z)),0.0)),
      length(max(vec3(q.x,q.y,p.z),0.0))+min(max(q.x,max(q.y,p.z)),0.0));
}

//椭圆
float sdEllipsoid( vec3 p, vec3 r ) // approximated
{
    float k0 = length(p/r);
    float k1 = length(p/(r*r));
    return k0*(k0-1.0)/k1;
}

// 圆环
float sdTorus( vec3 p, vec2 t )
{
    return length( vec2(length(p.xz)-t.x,p.y) )-t.y;
}

// 部分圆环					完整度 ：an/pi  环大小   环粗细
float sdCappedTorus(vec3 p, float an, float ra, float rb)
{
	vec2 sc = vec2(sin(an),cos(an));
    p.x = abs(p.x);
    float k = (sc.y*p.x>sc.x*p.y) ? dot(p.xy,sc) : length(p.xy);
    return sqrt( dot(p,p) + ra*ra - 2.0*ra*k ) - rb;
}

//圆柱
float sdCylinder( vec3 p, float r, float hi )
{
	vec2 h = vec2(r,hi);
    vec2 d = abs(vec2(length(p.xz),p.y)) - h;
    return min(max(d.x,d.y),0.0) + length(max(d,0.0));
}

//三棱柱                  
float sdTriPrism( vec3 p, float r, float hi )
{
    const float k = sqrt(3.0);
	vec2 h = vec2(r,hi);
    h.x *= 0.5*k;
    p.xy /= h.x;
    p.x = abs(p.x) - 1.0;
    p.y = p.y + 1.0/k;
    if( p.x+k*p.y>0.0 ) p.xy=vec2(p.x-k*p.y,-k*p.x-p.y)/2.0;
    p.x -= clamp( p.x, -2.0, 0.0 );
    float d1 = length(p.xy)*sign(-p.y)*h.x;
    float d2 = abs(p.z)-h.y;
    return length(max(vec2(d1,d2),0.0)) + min(max(d1,d2), 0.);
}

//六棱柱                  
float sdHexPrism( vec3 p, float r, float hi )
{
    vec3 q = abs(p);
	vec2 h = vec2(r,hi);
    const vec3 k = vec3(-0.8660254, 0.5, 0.57735);
    p = abs(p);
    p.xy -= 2.0*min(dot(k.xy, p.xy), 0.0)*k.xy;
    vec2 d = vec2(
       length(p.xy - vec2(clamp(p.x, -k.z*h.x, k.z*h.x), h.x))*sign(p.y - h.x),
       p.z-h.y );
    return min(max(d.x,d.y),0.0) + length(max(d,0.0));
}

//八棱柱                
float sdOctogonPrism( vec3 p, float r, float h )
{
  const vec3 k = vec3(-0.9238795325,   // sqrt(2+sqrt(2))/2 
                       0.3826834323,   // sqrt(2-sqrt(2))/2
                       0.4142135623 ); // sqrt(2)-1 
  // reflections
  p = abs(p);
  p.xy -= 2.0*min(dot(vec2( k.x,k.y),p.xy),0.0)*vec2( k.x,k.y);
  p.xy -= 2.0*min(dot(vec2(-k.x,k.y),p.xy),0.0)*vec2(-k.x,k.y);
  // polygon side
  p.xy -= vec2(clamp(p.x, -k.z*r, k.z*r), r);
  vec2 d = vec2( length(p.xy)*sign(p.y), p.z-h );
  return min(max(d.x,d.y),0.0) + length(max(d,0.0));
}

// 胶囊
float sdCapsule( vec3 p, vec3 a, vec3 b, float r )
{
	vec3 pa = p-a, ba = b-a;
	float h = clamp( dot(pa,ba)/dot(ba,ba), 0.0, 1.0 );
	return length( pa - ba*h ) - r;
}

// 圆角锥
float sdRoundCone( vec3 p, float r1, float r2, float h )
{
    vec2 q = vec2( length(p.xz), p.y );
    
    float b = (r1-r2)/h;
    float a = sqrt(1.0-b*b);
    float k = dot(q,vec2(-b,a));
    
    if( k < 0.0 ) return length(q) - r1;
    if( k > a*h ) return length(q-vec2(0.0,h)) - r2;
        
    return dot(q, vec2(a,b) ) - r1;
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

// 圓台
float sdCappedCone( vec3 p, float h, float r1, float r2 )
{
    vec2 q = vec2( length(p.xz), p.y );
    
    vec2 k1 = vec2(r2,h);
    vec2 k2 = vec2(r2-r1,2.0*h);
    vec2 ca = vec2(q.x-min(q.x,(q.y < 0.0)?r1:r2), abs(q.y)-h);
    vec2 cb = q - k1 + k2*clamp( dot(k1-q,k2)/dot(k2,k2), 0.0, 1.0 );
    float s = (cb.x < 0.0 && ca.y < 0.0) ? -1.0 : 1.0;
    return s*sqrt( min(dot(ca,ca),dot(cb,cb)) );
}

// 角
float sdSolidAngle(vec3 pos, float an, float ra)
{
	vec2 c = vec2(sin(an),cos(an));
    vec2 p = vec2( length(pos.xz), pos.y );
    float l = length(p) - ra;
	float m = length(p - c*clamp(dot(p,c),0.0,ra) );
    return max(l,m*sign(c.y*p.x-c.x*p.y));
}

//八面體
float sdOctahedron(vec3 p, float s)
{
    p = abs(p);
    float m = p.x + p.y + p.z - s;
 	vec3 q;
         if( 3.0*p.x < m ) q = p.xyz;
    else if( 3.0*p.y < m ) q = p.yzx;
    else if( 3.0*p.z < m ) q = p.zxy;
    else return m*0.57735027;
    float k = clamp(0.5*(q.z-q.y+s),0.0,s); 
    return length(vec3(q.x,q.y-s+k,q.z-k)); 

}

// 四棱錐
float sdPyramid( vec3 p, in float h )
{
    float m2 = h*h + 0.25;
    
    // symmetry
    p.xz = abs(p.xz);
    p.xz = (p.z>p.x) ? p.zx : p.xz;
    p.xz -= 0.5;
	
    // project into face plane (2D)
    vec3 q = vec3( p.z, h*p.y - 0.5*p.x, h*p.x + 0.5*p.y);
   
    float s = max(-q.x,0.0);
    float t = clamp( (q.y-0.5*p.z)/(m2+0.25), 0.0, 1.0 );
    
    float a = m2*(q.x+s)*(q.x+s) + q.y*q.y;
	float b = m2*(q.x+0.5*t)*(q.x+0.5*t) + (q.y-m2*t)*(q.y-m2*t);
    
    float d2 = min(q.y,-q.x*m2-q.y*0.5) > 0.0 ? 0.0 : min(a,b);
    
    // recover 3D and scale, and add sign
    return sqrt( (d2+q.z*q.z)/m2 ) * sign(max(q.z,-p.y));;
}


// 圓角菱體
float sdRhombus(vec3 p, float la, float lb, float h, float ra)
{
    p = abs(p);
    vec2 b = vec2(la,lb);
    float f = clamp( (ndot(b,b-2.0*p.xz))/dot(b,b), -1.0, 1.0 );
	vec2 q = vec2(length(p.xz-0.5*b*vec2(1.0-f,1.0+f))*sign(p.x*b.y+p.z*b.x-b.x*b.y)-ra, p.y-h);
    return min(max(q.x,q.y),0.0) + length(max(q,0.0));
}

// 馬蹄鉄
float sdHorseshoe( vec3 p, float an, float r, float le, vec2 w )
{
	vec2 c = vec2(sin(an),cos(an));
    p.x = abs(p.x);
    float l = length(p.xy);
    p.xy = mat2(-c.x, c.y, 
              c.y, c.x)*p.xy;
    p.xy = vec2((p.y>0.0 || p.x>0.0)?p.x:l*sign(-c.x),
                (p.x>0.0)?p.y:l );
    p.xy = vec2(p.x,abs(p.y-r))-vec2(le,0.0);
    
    vec2 q = vec2(length(max(p.xy,0.0)) + min(0.0,max(p.x,p.y)),p.z);
    vec2 d = abs(q) - w;
    return min(max(d.x,d.y),0.0) + length(max(d,0.0));
}

// u型
float sdU(vec3 p, float r, float le, vec2 w )
{
    p.x = (p.y>0.0) ? abs(p.x) : length(p.xy);
    p.x = abs(p.x-r);
    p.y = p.y - le;
    float k = max(p.x,p.y);
    vec2 q = vec2( (k<0.0) ? -k : length(max(p.xy,0.0)), abs(p.z) ) - w;
    return length(max(q,0.0)) + min(max(q.x,q.y),0.0);
}


float sdCat(vec3 pos){
	// head
	float res = sdEllipsoid(pos-vec3(.0,.0,.0), vec3(.22,.2,.15));
	// ears
	// res = min(res,sdHorseshoe(pos-vec3(.0,.0,.0),-0.08,0.12,0.2,vec2(0.08,0.04)));

	res = min(res,sdHorseshoe(pos-vec3(.0,.0,.0),-0.5,0.05,0.17,vec2(0.1,0.04)));

	// nose
	res = min(res,sdEllipsoid(pos-vec3(.0,-.05,.14), vec3(.05,.03,.03)));

	// mouth
	vec3 posTrans = vec3(pos.x,pos.y,pos.z)-vec3(.1,-.05,.14);
	posTrans.xy = posTrans.xy*rot(3.14159*0.8);
	res = min(res,sdCappedTorus(posTrans,.8,0.1,0.01));

	posTrans = vec3(-pos.x,pos.y,pos.z)-vec3(.1,-.05,.14);
	posTrans.xy = posTrans.xy*rot(3.14159*0.8);
	res = min(res,sdCappedTorus(posTrans,.8,0.1,0.01));

	posTrans = vec3(pos.x,pos.y,pos.z)-vec3(.0,-.1,.14);
	posTrans.xy = posTrans.xy*rot(3.14159*1.);
	res = min(res,sdCappedTorus(posTrans,.8,0.05,0.01));
	
	// eyes
	posTrans = vec3(pos.x,pos.y,pos.z)-vec3(.09,.038,.13);
	posTrans.xz = posTrans.xz*rot(-3.14159*0.1);
	res = min(res,sdEllipsoid(posTrans, vec3(.07,.06,.03)));

	posTrans = vec3(pos.x,pos.y,pos.z)-vec3(-.09,.038,.13);
	posTrans.xz = posTrans.xz*rot(3.14159*0.1);
	res = min(res,sdEllipsoid(posTrans, vec3(.07,.06,.03)));

	posTrans = vec3(pos.x,pos.y,pos.z)-vec3(.095,.038,.14);
	posTrans.xz = posTrans.xz*rot(-3.14159*0.1);
	res = min(res,sdEllipsoid(posTrans, vec3(.05,.05,.03)));

	posTrans = vec3(pos.x,pos.y,pos.z)-vec3(-.095,.038,.14);
	posTrans.xz = posTrans.xz*rot(3.14159*0.1);
	res = min(res,sdEllipsoid(posTrans, vec3(.05,.05,.03)));

	return res;
}


float map(vec3 pos) {
	vec2 mouse = vec2(-1.0*iMouse.xy/ iResolution.xy)+0.5;
	pos.xz = pos.xz*rot(mouse.x*10.0);
	pos.yz = pos.yz*rot(mouse.y*10.0);
	// float res = sdBox(pos-vec3(.0,.0,.0),vec3(0.2,0.2,0.2));
    float res = sdCat(pos-vec3(.0,.0,.0));

    return res;
}

vec3 calcNormal(vec3 pos )
{
	vec2 e = vec2(1.0,-1.0)*0.5773*0.0005;
	return normalize( e.xyy*map( pos + e.xyy ) + e.yyx*map( pos + e.yyx ) + e.yxy*map( pos + e.yxy ) + e.xxx*map( pos + e.xxx ) ); 
}

void main() {
	vec2 p = (gl_FragCoord.xy * 2. - iResolution.xy) / iResolution.y;
	vec3 ro = vec3(0.0, 0. , -2.0)+vec3(vec2(-1.0*iMouse.xy/ iResolution.xy)+0.5,0.0);
	vec3 ray = normalize(vec3(p,3.0));
	float rayStep = 0.1;

    // get the light 
    vec3 light_pos = 3.0 * vec3(cos(iTime), 1.0, sin(iTime));
    vec3 light_color = vec3(1.);


    //set material
    Material objM = Material(vec3(0.5,0.2,0.2),
                                        vec3(0.2),
                                        vec3(0.1),
                                        1.);

    vec4 color = vec4(0.,0.,0.5,1.0 );

	for (int i = 0; i < 30; i++){
		vec3 pos = ro + ray * rayStep;
		float d = map(pos);

		rayStep += max(abs(d),0.01)*0.5;
		if (d<0.0){
            vec3 normal = calcNormal(pos);
            color = PS(objM, pos, normal, ro, light_pos, light_color);
            break;
		}
		else{
			rayStep += max(abs(d),0.01)*0.5;
		}
	}
	gl_FragColor = color;
}
