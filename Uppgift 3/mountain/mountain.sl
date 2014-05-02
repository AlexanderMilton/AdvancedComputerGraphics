
#define snoise(p) (2 * (float noise(p)) - 1)

float RidgedMultifractal(point p; uniform float octaves, lacunarity, gain, H, sharpness, threshold)
{
	float result, signal, weight, i, exponent;
	varying point PP=p;

	for( i = 0; i < octaves; i += 1 ) {
       	if ( i == 0) {
          		signal = snoise( PP );
          		if ( signal < 0.0 ) signal = -signal;
          		signal = gain - signal;
          		signal = pow( signal, sharpness );
          		result = signal;
          		weight = 1.0;
        	}
			else{
          		exponent = pow( lacunarity, (-i*H) );
			PP = PP * lacunarity;
          		weight = signal * threshold;
          		weight = clamp(weight,0,1);    		
          		signal = snoise( PP );
          		signal = abs(signal);
          		signal = gain - signal;
          		signal = pow( signal, sharpness );
          		signal *= weight;
          		result += signal * exponent;
       		}
		}
		return(result);
}

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

float turbulence (point p; uniform float octaves, lacunarity, gain)
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
	abs(sum);
	return sum;
}

// The Worley cell noise function creates cells and measures the distance between them,
// offsetting them by random values. This creates an irregular "noisy" cell pattern.
/* Voronoi cell noise (a.k.a. Worley noise) -- 2-D, 2-feature version. */
void voronoi_gravelNoise (float ss, tt; output float gravelNoise; output float spos1, tpos1; output float f2; output float spos2, tpos2;)
{
	float jitter=1.0;
	float sthiscell = floor(ss)+0.5;
	float tthiscell = floor(tt)+0.5;
	gravelNoise = f2 = 1000;
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
			
			if (dist < gravelNoise) { 
				f2 = gravelNoise;
				spos2 = spos1;
				tpos2 = tpos1;
				gravelNoise = dist;
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
gravelNoise = sqrt(gravelNoise);  f2 = sqrt(f2);
}


surface mountain (
	float 	worldTop		= (50);
	float 	worldBottom		= (10);
	float 	beachEdge		= (worldBottom + 0.01);
	float	gravelReach		= (worldBottom + 1.6);
	float	cliffReach		= (worldTop - 0.001);
	
	color 	water			= (0.3,		0.6,	1.0		);
	color 	gravel			= (0.35,	0.4,	0.35	);
	color 	grass			= (0.0,		0.55,	0.0		);
	color 	river 			= (0.2,		0.8, 	1.0		);
	color	cliff			= (0.96,	0.92, 	0.88	);
	color	rock			= (0.96,	0.96, 	0.82	);
	color	haze			= (0.9,		0.9,	0.9		);
	
	float waterOctaves		= (2.5);			// 
	float waterLacunarity	= (3.25);			// Level of "gappiness" or inhomogeneity
	float waterGain			= (0.55);			// 
	
	float grassOctaves		= (5.0);			// 
	float grassLacunarity	= (1.4);			// Level of "gappiness" or inhomogeneity
	float grassGain			= (0.8);			// 
	
	float bumpFrequency		= (40.0);			// The frequency of the bump mapped irregularity
	float bumpHeight		= (5.8);			// The depth of the texture bumps
	float roughness 		= (0.5);			// The roughness of the bump map
	color diffuseColor 		= (0.6, 0.8, 0.9);	// Diffuse color
	color specularColor 	= (0.8, 0.8, 0.9);	// Specular color
	
	float fogDistance 		= (550);			// Fog effective distance
	color fogColor 			= (0.9, 0.9, 0.9);	// Fog color
	)
{
	// (point p; uniform float octaves, lacunarity, gain, H, sharpness, threshold)
    float magnitude = 2.1*(RidgedMultifractal((P)*0.002,8, 2.2, 0.94, 0.8, 6.4, 5)*120.00001);
	float mountainAtt = distance(zcomp(P),55)/1000.0;

	// Set the height of the landscape
	float height = magnitude * mountainAtt;

	// Clamp the world bounds to create a water surface and a maximum cliff height
	height=clamp(height, worldBottom, worldTop);
	
	// Calculate and even out normals to avoid bugs
    P += height * normalize(N);
    N = calculatenormal(P);
    normal Nf = faceforward (normalize(N),I);
	
	
	
	// Create a copy of the point P, add bump map noise and calculate the new normal
	point pTemp = P;
	// Execute a bump map noise function to create a water texture
	pTemp += noise(pTemp * bumpFrequency) * N * bumpHeight;
	N = calculatenormal(pTemp);
	
	// Normalize
	normal Nn = normalize(N);
	vector V  = normalize(-I);
	
	// Create diffuse and specular water colors
	color waterTextureA = Cs*(diffuseColor * diffuse(Nf));
	color waterTextureB = Cs*(specularColor * specular(Nn, V, roughness));
	// Add them together
	color waterTexture = waterTextureA + waterTextureB;
	
	// Execute a turbulence noise algorithm to create water noise
	// Nota Bene: This has been replaced by bump mapping
	// float waterNoise = clamp((turbulence(P, waterOctaves, waterLacunarity, waterGain)), 0, 1);
	
	// Voronoi parameters, gravelNoise is the desired output
	float gravelNoise, spos1, tpos1, f2, spos2, tpos2;
	
	// Execute a Worley Cell Noise algorithm to create gravel noise
	voronoi_gravelNoise(u*10000.0, v*10000.0, gravelNoise, spos1, tpos1, f2, spos2, tpos2);
	
	// Execute an fBm noise algorithm to create the grass noise
	float grassNoise = clamp((fBm(P, grassOctaves, grassLacunarity, grassGain)), 0, 1);
		
	
	
	// Mix the water texture with the gravel texture to create a beach edge
	color outputColor = mix((water * waterTexture), (gravel * gravelNoise), smoothstep(worldBottom, beachEdge, height));
	
	// Mix the gravel texture with the cliff texture to create a cliff foot
	outputColor = mix(outputColor, cliff, smoothstep(beachEdge, gravelReach, height));
	
	// Mix the cliff texture with the grass texture to create a cliff edge
	outputColor = mix(outputColor, (grass * grassNoise), step(cliffReach, height));
	
	
	
	// Diffuse the product
	outputColor = Cs*(outputColor * diffuse(Nf));

	// Create fog
	float d = 1 - exp((-length(I) + 100)/fogDistance);
	outputColor = mix (outputColor, fogColor, d);
	
	
	
	// Output
    Ci = outputColor;
    Oi = Os;  

    
}
