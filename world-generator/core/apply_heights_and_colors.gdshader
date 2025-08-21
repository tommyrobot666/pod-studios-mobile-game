shader_type spatial;
//render_mode unshaded;

uniform sampler2D vertex_colors;
uniform sampler2D vertex_heights;
uniform int mesh_detail;

vec3 calculate_normal(float vertex_height, float pos_x_height, float pos_z_height) {
	return normalize(cross(vec3(1.0,pos_x_height,0.0),vec3(0.0,pos_z_height,1.0)));
}

void vertex() {
	int row = VERTEX_ID / mesh_detail;
    int col = VERTEX_ID % mesh_detail;
	ivec2 pos = ivec2(col, row);
	
	COLOR.rgb = texelFetch(vertex_colors,pos,0).rgb;
	VERTEX.y += texelFetch(vertex_heights,pos,0).r;
	if (row < mesh_detail) {
		NORMAL = calculate_normal(
			texelFetch(vertex_heights,pos,0).r,
			texelFetch(vertex_heights,pos+1,0).r,
			texelFetch(vertex_heights,pos+mesh_detail,0).r
		);
	}
}

