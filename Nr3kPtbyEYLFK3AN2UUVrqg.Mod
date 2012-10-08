MODULE Nr3kPtbyEYLFK3AN2UUVrqg;IMPORT Base:=XNXLBase, XNXLVoxel, XNXLVoxel4, XNXLLifeVox, XNXLTexVox, Random, 
M2:=XNXLM3Space, M3:=XNXLM3Space, XNXLFRep, XNXLRotaVox, XNXLSierp, XNXLHalfSpace;
  
TYPE 	PT=Base.PT;
		Ray = Base.Ray;
		Voxel = Base.Voxel;
		
TYPE DiffuseMVox* = OBJECT(Voxel);
VAR
	r, g, b, mf, a: REAL;
PROCEDURE Shade (VAR ray: Ray);
VAR 
	nx, ny, nz: INTEGER;
	dot,d: REAL;
	inside: BOOLEAN;
BEGIN
	CASE ray.face OF
		0: inside := TRUE
		|1: nx := -1
		|2: ny := -1
		|3: nz := -1
		|4: nx := 1
		|5: ny := 1
		|6: nz := 1
	ELSE
	END; 
	ray.normal.x:=ray.lxyz.x-1/2;
	ray.normal.y:=ray.lxyz.y-1/2;	
	ray.normal.z:=ray.lxyz.z-1/2;	
	Base.normalizePT(ray.normal);
	ray.ra := ray.ra- 0.1; 
	ray.ga := ray.ga- 0.1; 
	ray.ba := ray.ba- 0.1; 
	mirror(ray);
END Shade;

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

END DiffuseMVox; 

VAR
	vox:  DiffuseMVox;
PROCEDURE thisvox*():Base.Voxel;
BEGIN
	RETURN vox
END thisvox;

BEGIN
	NEW(vox) 
END Nr3kPtbyEYLFK3AN2UUVrqg. 