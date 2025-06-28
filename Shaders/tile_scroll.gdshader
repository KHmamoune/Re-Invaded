shader_type canvas_item;

uniform float scroll_speed_y : hint_range(-10.0, 10.0) = 0.0;

void fragment() {
    vec2 uv = UV;

    uv.y = mod(uv.y - TIME * scroll_speed_y, 0.99);

    vec4 tile_color = texture(TEXTURE, uv);

    COLOR = tile_color;
}