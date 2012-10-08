MODULE XNXLTexVox;
IMPORT XNXLBase, XNXLAudio, XNXLMath, Raster, Graphics := WMGraphics, Random, Math,Out := KernelLog; 

TYPE PT=XNXLBase.PT;
TYPE Ray = XNXLBase.Ray;
TYPE Voxel = XNXLBase.Voxel;
TYPE Name = XNXLBase.Name;
TYPE TexCube = XNXLBase.TexCube;

TYPE TexVox* = OBJECT(Voxel);
VAR
	txTF*: BOOLEAN;
	texcube*: TexCube;

PROCEDURE & init*(n: Name);
BEGIN
	NEW(texcube,n,FALSE);
	texscale(1000);	
END init;

PROCEDURE deepcopy*():Voxel;
VAR
	v: TexVox;
BEGIN
	NEW(v,"fake");
	v.texcube:=texcube;
	v.tscale:=tscale;	
	RETURN v
END deepcopy;

PROCEDURE texscale*(a: LONGINT);
BEGIN
	tscale.x:=a;
	tscale.y:=a;
	tscale.z:=a;
END texscale;

PROCEDURE Shade (VAR ray: Ray);
VAR
	p: Raster.Pixel;
	x,y,xi,yj: LONGINT;
	X,Y, xblend, yblend,blendx,blendy: REAL;
	r,g,b,a: REAL;
	dr,dg,db,da,blackness:REAL;
	bb,c, lx, ly: REAL;
	i,j: INTEGER;
	dot, nx, ny, nz: REAL;
	bpdx,bpdy: REAL;
	xov,yov,zov:REAL;
	inside: BOOLEAN;
	color: XNXLBase.Color;
	txcube: TexCube;
BEGIN
	CASE ray.face OF
		 0: lx := ray.lxyz.y; ly := ray.lxyz.z; 
		|1: lx := ray.lxyz.x; ly := ray.lxyz.z; 
		|2: lx := ray.lxyz.x; ly := ray.lxyz.y;
		|3: lx := ray.lxyz.y; ly := ray.lxyz.z; 
		|4: lx := ray.lxyz.x; ly := ray.lxyz.z; 
		|5: lx := ray.lxyz.x; ly := ray.lxyz.y;  
	ELSE
	END;
	color:=texcube.side[ray.face].pixel(lx,ly);
	dot := ABS(ray.normal.x*ray.dxyz.x + ray.normal.y*ray.dxyz.y+ ray.normal.z*ray.dxyz.z)*0.8+0.2; 
	da:=color.alpha;
	dr:=color.red*dot*da*ray.ra;
	dg:=color.green*dot*da*ray.ga;
	db:=color.blue*dot*da*ray.ba;	
	ray.r := ray.r + dr;
	ray.g := ray.g + dg;
	ray.b := ray.b + db;
	ray.ra := ray.ra - dr - 0.1;
	ray.ga := ray.ga - dg - 0.1;
	ray.ba := ray.ba - db - 0.1;	
	ray.terminate:=TRUE
END Shade;

PROCEDURE play*();
BEGIN
(*	XNXLAudio.LoadWav("grollard.wav");
	XNXLAudio.Play *)
END play;
END TexVox;

TYPE TexCubeVox* = OBJECT(Voxel);
VAR
	txTF*: BOOLEAN;
	texcube*: TexCube;
	tscale*:PT;

PROCEDURE & init*(n: Name);
BEGIN
	NEW(texcube,n,FALSE);
	texscale(10000);	
END init;

PROCEDURE texscale*(a: LONGINT);
BEGIN
	tscale.x:=a;
	tscale.y:=a;
	tscale.z:=a;
END texscale;

PROCEDURE deepcopy*():Voxel;
VAR
	v: TexCubeVox;
BEGIN
	NEW(v,"fake");
	v.texcube:=texcube;
	v.tscale:=tscale;
	RETURN v
END deepcopy;


PROCEDURE Shade (VAR ray: Ray);
VAR
	p: Raster.Pixel;
	x,y,xi,yj: LONGINT;
	X,Y, xblend, yblend,blendx,blendy: REAL;
	r,g,b,a: REAL;
	dr,dg,db:REAL;
	bb,c, lx, ly: REAL;
	i,j: INTEGER;
	dot, nx, ny, nz: REAL;
	bpdx,bpdy: REAL;
	xov,yov,zov:REAL;
	inside: BOOLEAN;
	color: XNXLBase.Color
BEGIN
	CASE ray.face OF
		 0: lx := ray.lxyz.y; ly := ray.lxyz.z; 
		|1: lx := ray.lxyz.x; ly := ray.lxyz.z; 
		|2: lx := ray.lxyz.x; ly := ray.lxyz.y;
		|3: lx := ray.lxyz.y; ly := ray.lxyz.z; 
		|4: lx := ray.lxyz.x; ly := ray.lxyz.z; 
		|5: lx := ray.lxyz.x; ly := ray.lxyz.y;  
	ELSE
	END;
	color:=texcube.side[ray.face].pixel(lx,ly);
	dot := ABS(ray.normal.x*ray.dxyz.x + ray.normal.y*ray.dxyz.y+ ray.normal.z*ray.dxyz.z)*0.7+0.3; 
	dr:=color.red*dot*ray.ra;
	dg:=color.green*dot*ray.ga;
	db:=color.blue*dot*ray.ba;
	ray.r := ray.r + dr;
	ray.g := ray.g + dg;
	ray.b := ray.b + db;
	ray.ra := ray.ra - (dg+db)/2-0.2;
	ray.ga := ray.ga - (dr+db)/2-0.2;
	ray.ba := ray.ba - (dr+dg)/2-0.2;
	ray.bla := ray.bla -(dr+dg+db)/3-0.2;	
	ray.terminate:=TRUE;
END Shade;

PROCEDURE play*();
BEGIN
(*	XNXLAudio.LoadWav("grollard.wav");
	XNXLAudio.Play *)
END play;
END TexCubeVox;

END XNXLTexVox.