shader_type canvas_item;

varying vec2 full_uv;
uniform vec2 size;
void vertex () {
  VERTEX.y += sin((VERTEX.x * 10. / size.x + TIME * 8.) * 2.) * size.y * 4.;
  full_uv = VERTEX.xy / size;
}

vec3 hsv2rgb(vec3 _c) {
    vec4 _K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 _p = abs(fract(_c.xxx + _K.xyz) * 6.0 - _K.www);
    return _c.z * mix(_K.xxx, clamp(_p - _K.xxx, 0.0, 1.0), _c.y);
}

void fragment() {
	COLOR.rgb = hsv2rgb(vec3(full_uv.x / 2. + TIME, 0.7, 1.0));
}

