shader_type sky;

uniform vec3 sun_pos = vec3(0.0);
uniform vec3 sun_color = vec3(0, 0, 0);
uniform sampler2D ball_tex: source_color, filter_linear;
uniform float disco_ball_radius = 1000.0;

struct RayHit {
	bool is_hit;
	vec3 normal;
	vec3 hit_point;	
};

RayHit hit_sphere (vec3 origin, vec3 dir, vec3 sphere_center, float sphere_radius) {
	RayHit ray_hit;
	ray_hit.is_hit = false;
	vec3 oc = origin - sphere_center;
	float a = dot(dir, dir);
	float b = 2.0 * dot(oc, dir);
	float c = dot(oc, oc) - pow(sphere_radius, 2.0); 
	
	float delta = pow(b, 2.0) - 4.0 * a * c;
	
	if (delta < 0.0)
		return ray_hit;
	float root = sqrt(delta);
	float t1 = (-b - root) / (2.0 * a);
	float t2 = (-b + root) / (2.0 * a);

	float t_near = min(t1, t2);
	float t_far = max(t1, t2);
	
	if (t_near < 0.0) {
		if (t_far >= 0.0) 
			t_near = 0.0;
		else 
			return ray_hit;
	}
	
	ray_hit.hit_point = dir * vec3(t_near) + origin;
	ray_hit.normal = normalize(ray_hit.hit_point - sphere_center);
	ray_hit.is_hit = true;
	
	return ray_hit;
}

vec2 get_spherical_uv(vec3 point_on_sphere, float rotation) {
	vec3 n = normalize(point_on_sphere);
	float theta = atan(n.z, n.x);
	float phi = acos(n.y);
	theta += rotation;
	float u = (theta + PI) / TAU;
	float v = phi / PI;
	return vec2(u, v);
}


	

void sky() {
	if (AT_CUBEMAP_PASS) {
		COLOR = vec3(0.2, 0.6, 1.0);
	} else {
		vec3 ball_center = sun_pos;
		RayHit ball_hit = hit_sphere(POSITION, EYEDIR, ball_center, disco_ball_radius);
		if (ball_hit.is_hit) {
			vec2 uv = get_spherical_uv(ball_hit.hit_point - ball_center, TIME * 0.5);
			COLOR = texture(ball_tex, uv).rgb;
		} else {
			float ds = dot(normalize(sun_pos - POSITION), EYEDIR);
			COLOR += pow(vec3(pow(ds, sun_color.x), pow(ds, sun_color.y), pow(ds, sun_color.z)), vec3(13.0));
		}
	}
}
