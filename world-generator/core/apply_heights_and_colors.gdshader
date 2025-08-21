shader_type spatial;
render_mode unshaded;

uniform sampler2D vertex_colors;
uniform sampler2D vertex_heights;

void vertex() {
	COLOR = texelFetch(vertex_colors,ivec2(VERTEX_ID,0),0);
	VERTEX.y += texelFetch(vertex_heights,ivec2(VERTEX_ID,0),0).r;
}

