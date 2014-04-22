
surface galaxy(
	float stripeFrequency	=	(16.0);
	float ovalFactor		=	(3.5);
	//color diffuseColor	=	(0.5, 1.0, 0.8);
	//color specularColor	=	(1.0, 1.0, 0.7);
	//float roughness		=	(0.1);
	//float bumpdepth		=	(0.9);
)
{  
	// Create alternative coordinates depending on u and v.
	float uu = (u - 0.5) * stripeFrequency;
	float vv = (v - 0.5) * stripeFrequency;
	
	// Create two points, one center (origo) and one at the alternative coordinates uu and vv.
	point p1 = point(uu, vv, 0);
	point p2 = point(0, 0, 0);
	
	// Calculate the distance between the origo point (p1) and the new point (p2).
	float dist = distance(p1,p2);
	
	// Create spiraling stripes from the center towards the edges of the texture.
	// atan(uu, vv) is necessary for creating the curved lines.
	float spirals = step(0.7, mod(atan(uu, vv * ovalFactor) + dist, 1.57));
	
	spirals = spirals * (clamp(1 - (smoothstep(1.0, 4.0, dist)), 0, 1));
	
	// Output
	Ci = spirals;
	Oi = Os;
} 

