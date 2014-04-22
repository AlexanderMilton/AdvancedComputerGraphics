
#define snoise(p) (2 * (float noise(p)) - 1)

float fBm (point p; uniform float octaves, lacunarity, gain)
{
	uniform float amp = 1;
	varying point pp = p;
	varying float sum = 0;
	uniform float i;

	for (i = 0;  i < octaves;  i += 1) {
		sum += amp * snoise (pp);
		amp *= gain;
		pp *= lacunarity;
	}
	return sum;
}

// The Worley cell noise function that creates cells and measures the distance between them
// and offsetting them by random values. This creates an irregular "noisy" cell pattern.
// We utilize these scattered cells by inverting and narrowing their color values, creating a realistic
// and spectacular night sky texture with distant, glowing stars.
void voronoi_f1f2_2d (float ss, tt; output float f1; output float spos1, tpos1; output float f2; output float spos2, tpos2;)
{
	float jitter=1.0;
	float sthiscell = floor(ss)+0.5;
	float tthiscell = floor(tt)+0.5;
	f1 = f2 = 100;
	uniform float i, j;

	for (i = -1;  i <= 1;  i += 1) {
		float stestcell = sthiscell + i;
		for (j = -1;  j <= 1;  j += 1) {
			float ttestcell = tthiscell + j;
			float spos = stestcell + jitter * (cellnoise(stestcell, ttestcell) - 0.5);
			float tpos = ttestcell + jitter * (cellnoise(stestcell+23, ttestcell-87) - 0.5);
			float soffset = spos - ss;
			float toffset = tpos - tt;
			float dist = soffset*soffset + toffset*toffset;
			
			if (dist < f1) {
				f2 = f1;
				spos2 = spos1;
				tpos2 = tpos1;
				f1 = dist;
				spos1 = spos;
				tpos1 = tpos;
			}
			
			else if (dist < f2) {
				f2 = dist;
				spos2 = spos;
				tpos2 = tpos;
			}
		}
	}
f1 = sqrt(f1);  f2 = sqrt(f2);
}


surface stars(
	color white 				= (1.0, 1.0, 1.0); 	// White color
	color grey 					= (0.5, 0.5, 0.5); 	// Grey color
	color black 				= (0.0, 0.0, 0.0); 	// Black color
	color red 					= (1.0, 0.0, 0.2); 	// Red color
	color blue	 				= (0.2, 0.0, 1.0); 	// Blue color
	float frequency				= (1.0);
	float starlightThreshold 	= (0.8);
	float lacunarity			= (2.0);
	float octaves				= (2.0);
	float gain					= (0.4);
)
{
	//
	float f1;
	float spos1, tpos1; 
	float f2; 
	float spos2, tpos2;
	
	//
	voronoi_f1f2_2d(s*0.1, t*0.1, f1, spos1, tpos1, f2, spos2, tpos2);
	
	// Create two smoothsteps to manage the strength and fade of the starlight
	// The second smoothstep will take an in-parameter to control the total light strength
	float f1a;
	float f1b; 
	f1a = smoothstep(0.05, 0.15, f1);
	f1b = smoothstep(0.05, starlightThreshold, f1)*0.5;
	// Sum and invert the two smoothsteps to gain a potent center light for effect
	f1 = 1 - (f1a+f1b);
	
	// Darken the color range by applying a gray color
	color newColor = f1 * grey;
	
	//
	float fBm1 = clamp( abs(fBm(P*0.05, octaves, lacunarity, gain) ), 0, 1);
	newColor = (newColor * fBm1);
	
	//
	color fBm2a = clamp(fBm((P+332.23)*0.05, 5, lacunarity, gain), 0, 1)*red;
	color fBm2b = clamp(fBm((P+182.778)*0.05, 5, lacunarity, gain), 0, 1)*blue;
	newColor = (newColor + fBm2a + fBm2b);
	
	//
	Ci = Cs * newColor;
	Oi = Os;
} 
