shader_type canvas_item;

uniform float slider = 1.0;

void fragment() {
	COLOR = texture(TEXTURE, UV);
    float avg = (COLOR.r + COLOR.g + COLOR.b) / 3.0;
    COLOR.rgb = mix(COLOR.rgb, vec3(avg), slider);
}
