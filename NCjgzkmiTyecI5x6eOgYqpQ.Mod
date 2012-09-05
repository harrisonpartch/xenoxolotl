MODULE NCjgzkmiTyecI5x6eOgYqpQ;IMPORT Math, Streams, XNXLBase, XNXLVoxel, XNXLLifeVox, XNXLTexVox, Random, 
M2:=XNXLM2Space, M3:=XNXLM3Space, XNXLFRep, XNXLVoxel4, XNXLSierp, XNXLHalfSpace;
  
CONST NL=XNXLBase.NL
TYPE PT = XNXLBase.PT;
	Color = XNXLBase.Color;
	Ray = XNXLBase.Ray;
	Voxel = XNXLBase.Voxel;  
  
TYPE TransparaVox*=OBJECT(XNXLBase.Voxel);
VAR
	r, g, b, black, a: REAL;	
	vox:Voxel;
PROCEDURE setcolor* (red, green, blue,bl,alpha  : REAL); 
BEGIN
	r := red;
	g := green;
	b := blue;
	black:=bl;
	a:=alpha;
	passable := TRUE;
END setcolor;

PROCEDURE Shade (VAR ray: Ray);
VAR 
	depth: REAL;
	exit:PT;
	dr,dg,db,dbl,da,ra,ga,ba: REAL;
BEGIN
	exit:=XNXLBase.Exit(ray);
	depth:=XNXLBase.dist(ray.lxyz,exit)/ray.scale;
	dr := r*depth;
	dg := g*depth;
	db := b*depth;
	dbl:=black*depth;
	ra := (ray.ra - dr)-dbl;
	ga := (ray.ga - dg)-dbl;
	ba := (ray.ba - db)-dbl; 
	ray.ulfire:=ray.ulfire+depth*a;
	IF ray.ulfire>3 THEN 
		vox.Shade(ray);
	ELSE
		ray.r := ray.r + dr;
		ray.g := ray.g + dg;
		ray.b := ray.b + db; 	
		ray.ra:=ra; 
		ray.ga:=ga;
		ray.ba:=ba;		
	END;
	IF (ray.ra<0.1)&(ray.ga<0.1)&(ray.ba<0.1) THEN 
		ray.terminate:=TRUE 
	END
END Shade;

PROCEDURE engrain(w: Streams.Writer);
BEGIN
	w.Bytes(code,0,NL);	
	w.RawReal(r);
	w.RawReal(g);
	w.RawReal(b);	
	w.RawReal(black);	
END engrain;
PROCEDURE sprout(rdr: Streams.Reader);
BEGIN
	rdr.RawReal(r);
	rdr.RawReal(g);
	rdr.RawReal(b);	
	rdr.RawReal(black);	
END sprout;

PROCEDURE reflect(VAR p: PT; n: PT);
VAR 
	a,b,c,dot: REAL;
BEGIN
	dot := p.x*n.x+p.y*n.y+p.z*n.z;
	a := 2*n.x*dot; b := 2*n.y*dot; c := 2*n.z*dot;
	p.x := p.x-a; p.y := p.y-b; p.z := p.z-c;
END reflect;

PROCEDURE mirror(VAR ray: Ray);
BEGIN
	reflect(ray.dxyz, ray.normal);	
	IF ray.dxyz.x < 0 THEN ray.di := FALSE  ELSE ray.di := TRUE END; 
	IF ray.dxyz.y < 0 THEN ray.dj := FALSE  ELSE ray.dj := TRUE END;
	IF ray.dxyz.z < 0 THEN ray.dk := FALSE  ELSE ray.dk := TRUE END;	
	ray.changed := TRUE;
	ray.mirrortf:=TRUE
END mirror;

END TransparaVox;  

VAR
	vox:  TransparaVox;
	t2:  XNXLVoxel.TransparaVox;	
	 die: XNXLTexVox.TexCubeVox;
	 bivox: XNXLVoxel4.SphereInVox;
	 RED,YELLOW: XNXLVoxel.DiffuseVox;
PROCEDURE  thisvox*():XNXLBase.Voxel;
BEGIN
	RETURN bivox
END thisvox;

BEGIN
	NEW(YELLOW); 
	YELLOW.setcolor(1/2,1/2,0);
	NEW(die,'die');
	die.texscale(1000);
	NEW(bivox,die,YELLOW);
	bivox.D2:=7/12;

END NCjgzkmiTyecI5x6eOgYqpQ. 