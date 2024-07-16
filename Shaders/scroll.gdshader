shader_type canvas_item;

uniform float speed = 0.03;

void vertex() {
	UV.y -= TIME * speed;
}