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
	bb,c, lx, ly,lx1,ly1,lx2,ly2,tq: REAL;
	i,j: INTEGER;
	dot, nx, ny, nz: REAL;
	bpdx,bpdy: REAL;
	xov,yov,zov:REAL;
	inside: BOOLEAN;
	color,color1,color2: XNXLBase.Color;
	txcube: TexCube;
BEGIN
	CASE ray.face OF
		 0: lx := ray.xyz.y; ly := 1-ray.xyz.z; 
		|1: lx := ray.xyz.x; ly := 1-ray.xyz.z; 
		|2: lx := ray.xyz.x; ly := ray.xyz.y;
		|3: lx := ray.xyz.y; ly := 1-ray.xyz.z; 
		|4: lx := ray.xyz.x; ly := 1-ray.xyz.z; 
		|5: lx := ray.xyz.x; ly := ray.xyz.y;  
	ELSE
	END;
	lx1:=lx*1000-ENTIER(lx*1000); 
	ly1:=ly*1000-ENTIER(ly*1000); 
	lx2:=lx*10-ENTIER(lx*10); 
	ly2:=ly*10-ENTIER(ly*10); 
	color1:=texcube.side[ray.face].pixel(lx1,ly1);
	color2:=texcube.side[ray.face].pixel(lx2,ly2);	
	tq:=1/(ray.length*243);
	XNXLBase.clamp(tq);
	color.red:=(color1.red*tq+color2.red*(1-tq));
	color.green:=(color1.green*tq+color2.green*(1-tq));
	color.blue:=(color1.blue*tq+color2.blue*(1-tq));
	XNXLBase.clamp3(color.red,color.green,color.blue);
	dot := ABS(ray.normal.x*ray.dxyz.x + ray.normal.y*ray.dxyz.y+ ray.normal.z*ray.dxyz.z)*0.7+0.4; 
	dr:=color.red*dot*ray.ra;
	dg:=color.green*dot*ray.ga;
	db:=color.blue*dot*ray.ba;
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
	NEW(texcube,n,TRUE);
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
	dr,dg,db,da,blackness:REAL;
	bb,c, lx, ly,lx1,ly1,lx2,ly2,tq: REAL;
	i,j: INTEGER;
	dot, nx, ny, nz: REAL;
	bpdx,bpdy: REAL;
	xov,yov,zov:REAL;
	inside: BOOLEAN;
	color,color1,color2: XNXLBase.Color;
	txcube: TexCube;
BEGIN
	CASE ray.face OF
		 0: lx := ray.xyz.y; ly := 1-ray.xyz.z; 
		|1: lx := ray.xyz.x; ly := 1-ray.xyz.z; 
		|2: lx := ray.xyz.x; ly := ray.xyz.y;
		|3: lx := ray.xyz.y; ly := 1-ray.xyz.z; 
		|4: lx := ray.xyz.x; ly := 1-ray.xyz.z; 
		|5: lx := ray.xyz.x; ly := ray.xyz.y;  
	ELSE
	END;
	lx1:=lx*1000-ENTIER(lx*1000); 
	ly1:=ly*1000-ENTIER(ly*1000); 
	lx2:=lx*10-ENTIER(lx*10); 
	ly2:=ly*10-ENTIER(ly*10); 
	color1:=texcube.side[ray.face].pixel(lx1,ly1);
	color2:=texcube.side[ray.face].pixel(lx2,ly2);	
	tq:=1/(ray.length*243);
	XNXLBase.clamp(tq);
	color.red:=(color1.red*tq+color2.red*(1-tq));
	color.green:=(color1.green*tq+color2.green*(1-tq));
	color.blue:=(color1.blue*tq+color2.blue*(1-tq));
	XNXLBase.clamp3(color.red,color.green,color.blue);
	dot := ABS(ray.normal.x*ray.dxyz.x + ray.normal.y*ray.dxyz.y+ ray.normal.z*ray.dxyz.z)*0.7+0.4; 
	dr:=color.red*dot*ray.ra;
	dg:=color.green*dot*ray.ga;
	db:=color.blue*dot*ray.ba;
	ray.r := ray.r + dr;
	ray.g := ray.g + dg;
	ray.b := ray.b + db;
	ray.ra := ray.ra - (dg+db)/2;
	ray.ga := ray.ga - (dr+db)/2;
	ray.ba := ray.ba - (dr+dg)/2;
	ray.bla := ray.bla -(dr+dg+db)/3;	
	ray.terminate:=TRUE
END Shade;

PROCEDURE play*();
BEGIN
(*	XNXLAudio.LoadWav("grollard.wav");
	XNXLAudio.Play *)
END play;
END TexCubeVox;

END XNXLTexVox.