MODULE NXWCxXWLIcD2LegvoGXXBiQ;

IMPORT Base:=XNXLBase, XNXLVoxel, XNXLTexVox, M3:=XNXLM3Space, V4:=XNXLVoxel4, Streams;

TYPE PT = Base.PT;
	Ray = Base.Ray;
	Voxel = Base.Voxel;  
	
TYPE TransparaVox*=OBJECT(Base.Voxel);
VAR
	r, g, b, black: REAL;	
PROCEDURE setcolor* (red, green, blue,bl : REAL); 
BEGIN
	r := red;
	g := green;
	b := blue;
	black:=bl;
END setcolor;

PROCEDURE Shade (VAR ray: Ray);
VAR 
	depth: REAL;
	exit:PT;
	dr,dg,db,dbl: REAL;
BEGIN
	exit:=Base.Exit(ray);
	depth:=Base.dist(ray.lxyz,exit)/ray.scale;
	dr := r*depth;
	dg := g*depth;
	db := b*depth;
	dbl:=black*depth;
	ray.r := ray.r + dr;
	ray.g := ray.g + dg;
	ray.b := ray.b + db; 
	ray.ra := (ray.ra - dr)-dbl;
	ray.ga := (ray.ga - dg)-dbl;
	ray.ba := (ray.ba - db)-dbl; 
	IF (ray.ra<0.1)&(ray.ga<0.1)&(ray.ba<0.1) THEN ray.terminate:=TRUE END;
END Shade;

END TransparaVox;  
TYPE AlphaVox* = OBJECT(Voxel);
VAR
	r, g, b : REAL;
PROCEDURE setcolor* (red, green, blue, alpha  : REAL);
BEGIN
	r := red * alpha;
	g := green * alpha;
	b := blue * alpha;
END setcolor;
PROCEDURE Shade(VAR ray: Ray);
VAR 
	dr, dg, db: REAL;
BEGIN
	dr :=  r*ray.ra;
	dg :=  g*ray.ga;
	db :=  b*ray.ba;
	ray.r := ray.r + dr;
	ray.g := ray.g + dg;
	ray.b := ray.b + db;
	ray.ra := ray.ra - (dg+db)/2;
	ray.ga := ray.ga - (dr+db)/2;
	ray.ba := ray.ba - (dr+dg)/2;
	ray.bla := ray.bla -(dr+dg+db)/3;
	IF (ray.ra<0.1)&(ray.ga<0.1)&(ray.ba<0.1) THEN ray.terminate:=TRUE END;
END Shade;
PROCEDURE deepcopy*():Voxel;
VAR	v:AlphaVox;
BEGIN
	NEW(v);
	v.setcolor(r,g,b,1);
	RETURN(v)
END deepcopy;
END AlphaVox; 

TYPE Serp* = OBJECT(Voxel);
VAR
	innard: M3.cell;
PROCEDURE Shade (VAR ray: Ray);
BEGIN
	ray.dtl:=Base.DTL2;
	innard.Shade(ray)
END Shade;
PROCEDURE tick;
VAR	
	v:Voxel;
	a,b,c,d,e,f:LONGINT;

BEGIN
	a:=Base.rand.Dice(3);
	b:=Base.rand.Dice(3);	
	c:=Base.rand.Dice(3);	
	d:=Base.rand.Dice(3);	
	e:=Base.rand.Dice(3);	
	f:=Base.rand.Dice(3);	
	v:=innard.blox[a,b,c];
	innard.blox[a,b,c]:=innard.blox[d,e,f];
	innard.blox[d,e,f]:=v
END tick;
END Serp;

VAR 
	serp,rserp: M3.cell;
	thisserp: Serp;
	blue: AlphaVox;
	leaf, granite: XNXLTexVox.TexVox;
	abc:XNXLTexVox.TexCubeVox;
	mirrorball: V4.MirrorSphereInVox;
	
PROCEDURE thisvox*():Base.Voxel;
BEGIN
	IF thisserp=NIL THEN 
		NEW(abc,'whiteblock');
		abc.passable:=FALSE;
		NEW(mirrorball);
		NEW(leaf,'leaf.png'); 
		NEW(granite,'galaxy.png'); 	
		granite.passable:=FALSE;	
		NEW(blue);
		blue.setcolor(1/10,0,0,0);
		blue.passable:=TRUE;
		NEW(rserp);
		rserp.passable:=TRUE;
		rserp.lockTF:=TRUE; 
		rserp.fill(blue);
		rserp.blox[1,1,0]:=rserp;
		rserp.blox[1,1,2]:=rserp;
		rserp.blox[0,1,1]:=rserp;
		rserp.blox[2,1,1]:=rserp;
		rserp.blox[1,0,1]:=rserp;
		rserp.blox[1,2,1]:=rserp;
		rserp.blox[1,1,1]:=rserp;			
		rserp.imposter:=granite;
		NEW(serp);
		serp.passable:=TRUE;
		serp.lockTF:=TRUE; 
		serp.fill(serp);
		serp.blox[1,1,0]:=blue;
		serp.blox[1,1,2]:=blue;
		serp.blox[0,1,1]:=blue;
		serp.blox[2,1,1]:=blue;
		serp.blox[1,0,1]:=blue;
		serp.blox[1,2,1]:=abc;
		serp.blox[1,1,1]:=blue;			
		serp.imposter:=abc;
		granite.texscale(243*243*243);
		granite.passable:=FALSE;
		abc.passable:=FALSE;		
		serp.frozen:=TRUE;
		serp.probelock:=TRUE;
		NEW(thisserp);
		thisserp.passable:=TRUE;
		thisserp.innard:=serp;
		(* thisserp.register *)
	END;
	RETURN thisserp
END thisvox;
 END NXWCxXWLIcD2LegvoGXXBiQ. 