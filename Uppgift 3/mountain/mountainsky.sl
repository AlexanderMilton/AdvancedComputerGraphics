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

surface mountainsky(
	color skyColor 		= (0.54, 0.64, 0.74); 	
	color hazeColor 	= (1, 1, 1);	
	color cloudColor	= (0.9, 0.9, 0.9);
)
{
	// Create a base for the sky using the haze and sky colors
	float baseColor = (0.6 - v);
	color outputColor = mix(hazeColor, skyColor, baseColor);
	
	// Create cloud noise using an fBm algorithm, dependant on the y-coordinate of the scene
	float cloudFreq = ((1.0 - v) * 6.0);
	float cloudNoise = clamp(fBm(P * cloudFreq * 0.001, 5, 2.75, 0.6),0,1);
	
	// Mix the sky and the clouds to the cloud noise
	outputColor = mix(skyColor, cloudColor, cloudNoise);

	// Add a haze effect to fade the horizon
	float haze = pow(1.4-v,3);
	outputColor = mix(outputColor, hazeColor, haze);
	
	// Output
	Ci = outputColor;
	Oi = Os;
} 

