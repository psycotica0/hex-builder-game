shader_type particles;

uniform sampler2D bot_data;

const float SPEED = 2.0;
const float ACCEL = 4.0;
const float DROP_SPEED = 5.0;
const float DIST = 0.3;

const float inactive_height = 5.0;
const float active_height = 0.25;

float rand_from_seed(in uint seed) {
  int k;
  int s = int(seed);
  if (s == 0)
    s = 305420679;
  k = s / 127773;
  s = 16807 * (s - k * 127773) - 2836 * k;
  if (s < 0)
    s += 2147483647;
  seed = uint(s);
  return float(seed % uint(65536)) / 65535.0;
}

uint hash(uint x) {
  x = ((x >> uint(16)) ^ x) * uint(73244475);
  x = ((x >> uint(16)) ^ x) * uint(73244475);
  x = (x >> uint(16)) ^ x;
  return x;
}

vec2 move_towards_by_at_most(vec2 source, vec2 target, float max_amount) {
	vec2 dir = target - source;
	if (length(dir) < max_amount) {
		return target;
	} else {
		return source + max_amount * normalize(dir);
	}
}

vec4 color(float state) {
	vec4 white = vec4(1.0, 1.0, 1.0, 1.0);
	vec4 blue = vec4(0.3, 0.3, 1.0, 1.0);
	vec4 red = vec4(1.0, 0.3, 0.3, 1.0);
	
	switch(int(round(state))) {
		case 2:
			return blue;
		case 3:
			return red;
		default:
			return white;
	}
}

void vertex() {
	vec4 data = texelFetch(bot_data, ivec2(INDEX, 0), 0);
	
	if (data.b == 0.0) {
		VELOCITY.xyz = vec3(0,0,0);
		TRANSFORM[3][1] = inactive_height;
	} else if (RESTART || TRANSFORM[3][1] == inactive_height) {
		float rand = rand_from_seed(hash(NUMBER + RANDOM_SEED));
		TRANSFORM[3][0] = data.r + (0.5 * sin(6.28 * rand));
		TRANSFORM[3][1] = inactive_height - 0.01;
		TRANSFORM[3][2] = data.g + (0.5 * cos(6.28 * rand));
		VELOCITY.xyz = vec3(0,0,0);
		
	} else {
		vec2 pos = vec2(
			TRANSFORM[3][0],
			TRANSFORM[3][2]
		);
	
		vec2 target = vec2(data.r, data.g);
		COLOR = color(data.b);
	
		vec2 full_out = normalize(pos - target) * SPEED;
		vec2 full_in = normalize(target - pos) * SPEED;
		vec3 perp = normalize(cross(
			vec3(full_in, 0.0),
			vec3(0.0, 0.0, 1.0)
		)) * SPEED;
	
		float d = distance(pos, target) / DIST;
	
		if (d < 1.0) {
			vec2 v = mix(full_out, vec2(perp.x, perp.y), d);
			VELOCITY.xz = move_towards_by_at_most(VELOCITY.xz, v, ACCEL * DELTA);
		} else {
			vec2 v = mix(full_in, vec2(perp.x, perp.y), 1.0/d);
			VELOCITY.xz = move_towards_by_at_most(VELOCITY.xz, v, ACCEL * DELTA);
		}
		
		if (TRANSFORM[3][1] > active_height) {
			VELOCITY.y -= DROP_SPEED * DELTA;
		} else {
			TRANSFORM[3][1] = active_height;
			VELOCITY.y = 0.0;
		}
	}
}