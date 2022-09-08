mat2 rot(float a) {
	float c = cos(a), s = sin(a);
	return mat2(c,s,-s,c);
}

float sdBox( vec3 p, vec3 b )
{
	vec3 q = abs(p) - b;
	return length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0);
}

float box(vec3 pos) {
	// rotate box in xy
	pos.xy *=   rot(.8*iTime);
				 	        //  box size
	float box = sdBox(pos, vec3(.2,.2,.1));
	float result = box;
	return result;
}

float box_set(vec3 pos) {
				 	//  pos - center pos
	float box1 = box(pos-vec3(.5,.3,1.5));
	float box2 = box(pos-vec3(.7,.3,1.5));
	float result = min(box1,box2);
	return result;
}

float map(vec3 pos) {
	float box_set1 = box_set(pos);
	return box_set1;
}

vec3 modPos(vec3 pos){
	vec3 mod3 = vec3(0.,2.,0.);
	return vec3(mod(pos.x,2.),mod(pos.y,1.),mod(pos.z,1.5));
}

void main() {
	vec2 p = (gl_FragCoord.xy * 2. - iResolution.xy) / iResolution.y;
	vec3 ro = vec3(0.0+iTime, 0.+iTime , 0.0+iTime);
	vec3 ray = normalize(vec3(p,3.0));
	float rayStep = 0.1;
	float ac = 0.0;


	for (int i = 0; i < 80; i++){
		vec3 pos = ro + ray * rayStep;
		pos = modPos(pos);
		float d = map(pos);

		rayStep += max(abs(d),0.01)*0.5;

		if (d<0.0){
			ac += exp(-min(abs(d),0.1))*0.025;
		}
	}

	vec3 col = vec3(ac);
	col +=vec3(0.,0.0,0.5);

	gl_FragColor = vec4(col ,1.0 );
}
