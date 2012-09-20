MODULE NH6nvNlOJNlCtpkDB56ljSw;
IMPORT XNXLBase, XNXLAudio,XNXLTexVox,  XNXLVoxel, XNXLVoxel4, XNXLMath, Raster, Graphics := WMGraphics, Random, Math,Out := KernelLog; 

TYPE PT=XNXLBase.PT;
TYPE Ray = XNXLBase.Ray;
TYPE Voxel = XNXLBase.Voxel;
TYPE Name = XNXLBase.Name;
TYPE Texture = XNXLBase.Texture;


TYPE TexMirVox* = OBJECT(Voxel);
VAR
	img*: Raster.Image;
	fmt: Raster.Format;
	copy : Raster.Mode;
	W,H, bpr,adr: LONGINT;
	transparent*: BOOLEAN;
	texture*: Texture;
	mirrorfraction*:REAL; 
	
PROCEDURE & init*(n: Name);
BEGIN
	Raster.InitMode(copy,Raster.srcCopy);
	img :=Graphics.LoadImage(n, TRUE); (* img format is BGRA8888 *)
	IF img=NIL THEN 
		Out.String("unable to load image ");
		Out.String(n);
		Out.Ln;
	ELSE
		W:=img.width-1; H:=img.height-1;
		Out.String(n);
		Out.Ln;
	END;
	mirrorfraction:=0.5;
END init;

PROCEDURE Shade (VAR ray: Ray);
VAR
	p: Raster.Pixel;
	x,y,xi,yj: LONGINT;
	X,Y, xblend, yblend,blendx,blendy: REAL;
	r,g,b,a: REAL;
	dr,dg,db:REAL;
	bb,c, lx, ly: REAL;
	i,j,nx, ny, nz: INTEGER;
	dot: REAL;
	bpdx,bpdy: REAL;
	xov,yov,zov:REAL
BEGIN
	CASE ray.face OF
			|1: nx := -1
			|2: ny := -1
			|3: nz := -1
			|4: nx := 1
			|5: ny := 1
			|6: nz := 1
		ELSE
			nx:=1
		END;
		dot := 0.3+ ABS(nx*ray.dxyz.x + ny*ray.dxyz.y+ nz*ray.dxyz.z)*0.7; 
		CASE ray.face OF
			1: lx := ray.xyz.y; ly :=  ray.xyz.z;
			| 2:  lx := ray.xyz.x; ly := ray.xyz.z;
			| 3: lx := ray.xyz.x; ly := ray.xyz.y;
			| 4: lx := ray.xyz.y; ly := ray.xyz.z;
			| 5: lx := ray.xyz.x; ly := ray.xyz.z;
			| 6: lx := ray.xyz.x; ly := ray.xyz.y;
		ELSE
		END; 
		IF img#NIL THEN	
			X:=lx;
			Y:=ly;		
			xi:=ENTIER(X*10000)MOD W; yj:=H - (ENTIER(Y*10000) MOD H);
			Raster.Get(img,xi,yj,p,copy);
			r := ORD(p[2])/255; g := ORD(p[1])/255; b := ORD(p[0])/255; a:= ORD(p[3])/255;
			IF r+g+b<0.1 THEN mirrorfraction:=0.50 ELSE mirrorfraction:=1 END;
			dot:=dot*a;
			dr:=r*ray.ra*dot*mirrorfraction;
			dg:=g*ray.ga*dot*mirrorfraction;
			db:=b*ray.ba*dot*mirrorfraction;
			ray.r := ray.r + dr;
			ray.g := ray.g + dg;
			ray.b := ray.b + db;
			ray.ra:=ray.ra - dr-mirrorfraction;
			ray.ga:=ray.ga-dg-mirrorfraction;
			ray.ba:=ray.ba-db-mirrorfraction;		
			mirror(ray);
			IF mirrorfraction>1/2 THEN ray.terminate:=TRUE END
		END						
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
END TexMirVox;
  
VAR 
	insect: XNXLTexVox.TexCubeVox;
	bivox: XNXLVoxel.BiVox;
	RED,YELLOW: XNXLVoxel.DiffuseVox;
	grid: XNXLVoxel.GridVox;
PROCEDURE thisvox*():XNXLBase.Voxel;
BEGIN
	IF bivox=NIL THEN 
		NEW(insect,'granite'); 
		insect.texscale(1000);
		NEW(grid);	
		NEW(bivox);
		bivox.set(grid,insect); 
	END;
	RETURN insect
END thisvox;

 END NH6nvNlOJNlCtpkDB56ljSw. 