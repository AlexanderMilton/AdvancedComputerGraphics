
surface galaxy(
	float reachFrequency	=	(12.0);				// The diameter/"reach" of the spirals
	float ovalFactor		=	(3.5);				// How intensely the spirals are twisted
	float galaxySize		=	(0.5);				// The size/diameter of the final galaxy
	color galaxyColor		=	(0.0, 0.4, 0.045);	// The color of the galaxy
)
{  
	// Create alternative coordinates depending on u and v.
	float uu = (u - 0.5) * reachFrequency;
	float vv = (v - 0.5) * reachFrequency;
	
	// Create two points, one center (origo) and one at the alternative coordinates uu and vv.
	point p1 = point(uu, vv, 0);
	point p2 = point(0, 0, 0);
	
	// Calculate the distance between the origo point (p1) and the new point (p2).
	float dist = distance(p1,p2);
	
	// Create spiraling stripes from the center towards the edges of the texture.
	// atan(uu, vv) is utilized to create the curved lines.
	float spirals = step(1.2, mod(atan(uu, vv * ovalFactor) + dist, 1.57));
	
	// Smoothstep the spirals to fade out the stripes toward the edges
	spirals = spirals * (clamp(1 - (smoothstep(1.0 * galaxySize, 4.0 * galaxySize, dist)), 0, 1));
	
	// Add a glowing "haze", filling the galaxy with a lit substance
	spirals = spirals + clamp(1 - (smoothstep(0.8 * galaxySize, 3.5 * galaxySize, dist)), 0, 1);
	
	// Finalize the output by adding color
	Ci = spirals * galaxyColor;
	Oi = spirals;
} 

