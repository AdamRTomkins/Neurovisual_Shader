float3 cube_round(float3 c) {
	float rx = round(c.x);
	float ry = round(c.y);
	float rz = round(c.z);

	float x_diff = abs(rx - c.x);
	float y_diff = abs(ry - c.y);
	float z_diff = abs(rz - c.z);

	if (x_diff > y_diff && x_diff > z_diff) {
		rx = -ry - rz;
	} 
	else if (y_diff > z_diff) {
		ry = -rx - rz;
	}
	else {
		rz = -rx - ry;
	}
	return float3(rx, ry, rz);
}

float3 hex_to_cube(float2 h) { // axial
	float x = h.x;  //h.q
	float z = h.y; //h.r
	float y = -x - z;
	return float3(x, y, z);
}

float2 cube_to_hex(float3 h) { // axial
	float q = h.x; //h.x
	float r = h.z; //h.z
	return float2(q, r);
}

float2 hex_round(float2 h) {
	return cube_to_hex(cube_round(hex_to_cube(h)));
}



float2 pixel_to_hex(float x, float y, float CellSize) {

	float q = x * 2 / 3 / CellSize;
	float r = (-x / 3 + sqrt(3) / 3 * y) / CellSize;

	return hex_round(float2(q, r));
}

float2 hex_to_pixel(float q, float r, float CellSize) {
	float x = CellSize * 3 / 2 * q;
	float y = CellSize * sqrt(3) * (r + q / 2);
	return float2(x, y);
}
