#iChannel0 "file://textures/icon.png"

float sdSphere( vec3 p, float s )
{
    return length(p)-s;
}

float map(vec3 pos)
{
    return sdSphere(pos-vec3(.0,.0,.0), .5);
}

vec4 textureSphere(vec3 pos,float r)
{
    float pi = 3.1416;
    vec2 sphereUV = vec2(acos(pos.x/r)/pi,acos(pos.y/r)/pi);
    return texture(iChannel0,sphereUV);
}

void main() {
	vec2 p = (gl_FragCoord.xy * 2. - iResolution.xy) / iResolution.y;
	vec3 ro = vec3(0.0, 0. , -2.20)+vec3(vec2(-1.0*iMouse.xy/ iResolution.xy)+0.5,0.0);
	vec3 ray = normalize(vec3(p,3.0));
	float rayStep = 0.1;
	vec4 color = vec4(0.0,0.0,0.5,1.0);


	for (int i = 0; i < 30; i++){
		vec3 pos = ro + ray * rayStep;
		float d = map(pos);

		rayStep += max(abs(d),0.01)*0.5;

		if (d<0.0){
			color = textureSphere(pos,0.5);
            break;
		}
		else{
			rayStep += max(abs(d),0.01)*0.5;
		}
	}

	gl_FragColor = color;
}