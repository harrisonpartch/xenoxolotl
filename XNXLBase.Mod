MODULE XNXLBase;

IMPORT  Math:=Math, Random, Out:=KernelLog (*DebugLog*), XNXL, 
Strings, Streams, WMFontManager, Raster, Graphics := WMGraphics, XNXLAudio;
CONST
	W*=XNXL.W;
	H*=XNXL.H;
	W2*=W DIV 2;
	W25*=W DIV 25;
	H25*=H DIV 25;	
	tiles*=W25*H25;
	BPS*=9; 
	NL*=24;
	
TYPE Name* = ARRAY NL OF CHAR;

TYPE PT*= RECORD
	x*,y*,z*: REAL
END

TYPE FRF*=PROCEDURE(p:PT):BOOLEAN;

TYPE IPT*=RECORD
	i*,j*,k*: INTEGER
END;

TYPE BOX*=RECORD
	p*,q*: PT;
END;

TYPE Aperture* = RECORD
	width*, height*: REAL
END;

TYPE Color*=RECORD
	red*,green*,blue*,alpha*: REAL
END;

TYPE V*= OBJECT  (*abstract base type for voxel and texture and anything else that may animate *)
PROCEDURE tick*;
END tick;
PROCEDURE register*;
VAR i: INTEGER;
BEGIN
	i := 0;
	WHILE voxelist[i] # NIL DO INC(i) END;
	IF i < 99 THEN voxelist[i] := SELF END;
END register;

END V;

TYPE Texture*=OBJECT(V)
VAR
	img*: Raster.Image;
	fmt: Raster.Format;
	W*,H*, bpr,adr: LONGINT;
	transparent*: BOOLEAN;

PROCEDURE & init*(n: ARRAY OF CHAR);
BEGIN
	Raster.InitMode(copy,Raster.srcCopy);
	img :=Graphics.LoadImage(n, TRUE); (* img format is BGRA8888 *)
	IF img#NIL THEN 
		W:=img.width-1; H:=img.height-1;
	END;
END init;

PROCEDURE pixel*(x,y:REAL):Color;
VAR
	i,j: LONGINT;
	p: Raster.Pixel;
	c: Color;
BEGIN
	IF img#NIL THEN
		i:=ENTIER(x*W) MOD W; j:=ENTIER(y*H) MOD H;	
    		   Raster.Get(img,i,j,p,copy);
		c.red := ORD(p[2])/255; c.green := ORD(p[1])/255; c.blue := ORD(p[0])/255; c.alpha:= ORD(p[3])/255;	
	ELSE
		c.red:=1; c.blue:=1;
	END;
	RETURN c
END pixel;
	
END Texture;

TYPE TexCube*=OBJECT(V)
VAR
	side*:ARRAY 6 OF Texture;
PROCEDURE & init*(CONST name: ARRAY OF CHAR; five:BOOLEAN);
VAR
	nstring: Strings.String;
BEGIN
	IF five THEN
		nstring:=Strings.ConcatToNew(name,".0.png");
		NEW(side[0],nstring^);
		nstring:=Strings.ConcatToNew(name,".1.png");
		NEW(side[1],nstring^);	
		nstring:=Strings.ConcatToNew(name,".2.png");
		NEW(side[2],nstring^);		
		nstring:=Strings.ConcatToNew(name,".3.png");
		NEW(side[3],nstring^);
		nstring:=Strings.ConcatToNew(name,".4.png");
		NEW(side[4],nstring^);	
		nstring:=Strings.ConcatToNew(name,".5.png");
		NEW(side[5],nstring^);	
	ELSE
		NEW(side[0],name);
		NEW(side[1],name);	
		NEW(side[2],name);		
		NEW(side[3],name);
		NEW(side[4],name);	
		NEW(side[5],name);			
	END
END init;	
END TexCube;

TYPE BPE*=RECORD
	red*,green*,blue*: REAL
END;

TYPE BPATCH*=ARRAY BPS,BPS OF BPE;

TYPE Ray* = RECORD
	xyz*, dxyz*, ddxyz*, lxyz*, txyz*, origin*, oxyz*, popdelta*: PT;	
	cellred*,cellgreen*,cellblue*,cellblack*: REAL;
	texcube*:TexCube;
	texcubeTF*:BOOLEAN;
	r*, g*, b*, ra*, ga*, ba*, bla*,ulfire*: REAL; (* ulfire is an invisible color *)
	terminate*: BOOLEAN;
	i*, j*, k*: INTEGER;
	scale*,tscale*: REAL;
	length*: REAL; 
	di*,dj*,dk*: BOOLEAN;
	changed*: BOOLEAN; 
	face*: INTEGER;
	mirrortf*:BOOLEAN;	
	normal*,bloxnorm*: PT;  
	normalTF*: BOOLEAN;
	corner*:PT;
	dtl*: LONGINT;	
END; 

TYPE RAYS*= POINTER TO ARRAY W, H OF Ray;
TYPE CORERAYS*= POINTER TO ARRAY W2, H OF Ray;
TYPE IMAGE*= POINTER TO ARRAY W*BPS,H*BPS OF BPE;


TYPE Voxel*=OBJECT(V)
VAR
	complex*, passable*: BOOLEAN;
	imposter*: Voxel;
	lockTF*,copymarker*,emptysplit*: BOOLEAN;
	DTL*: REAL;
	code*:Name;
	tscale*: PT;
PROCEDURE Shade*(VAR ray: Ray);
END Shade;
PROCEDURE proberay*(VAR ray: Ray):Voxel;
VAR v:Voxel;
BEGIN
	NEW(v);
	RETURN(v)
END proberay;
PROCEDURE probe*(p:PT; resolution: LONGINT):Voxel;
BEGIN
	RETURN(SELF);
END probe;
PROCEDURE passprobe*(p:PT):BOOLEAN;
BEGIN
	RETURN(passable);
END passprobe;
PROCEDURE stroke*(p:PT; resolution: LONGINT; voxel:Voxel);
END stroke;
PROCEDURE strokerec*(p:PT; resolution,scale: LONGINT; voxel:Voxel);
END strokerec;
PROCEDURE mstroke*(a,b,c: LONGINT; resolution: LONGINT; vname: Name);
BEGIN
END mstroke;
PROCEDURE erase*(p:PT; resolution:LONGINT);
END erase;
PROCEDURE lock*;
BEGIN
	lockTF:=TRUE
END lock;
PROCEDURE unlock*;
BEGIN
	lockTF:=FALSE
END unlock;
PROCEDURE copy*():Voxel;
BEGIN
	RETURN(SELF)
END copy;
PROCEDURE deepcopy*():Voxel;
BEGIN
	RETURN(SELF)
END deepcopy;
PROCEDURE copyclear*;
BEGIN
	copymarker:=FALSE;
END copyclear;
PROCEDURE engrain*(w: Streams.Writer);
BEGIN
	w.Bytes(code,0,NL);	 
END engrain;
PROCEDURE sprout*(r: Streams.Reader);
BEGIN
END sprout;

PROCEDURE play*();
BEGIN
(*	XNXLAudio.LoadWav("grain.wav");
	XNXLAudio.Play *)
END play;

END Voxel; 

TYPE VoxelFackery = PROCEDURE ( ): Voxel;

(*TYPE VoxelList*=OBJECT;
VAR
	voxel:Voxel;
	next,previous: VoxelList;
PROCEDURE push*(v: Voxel);
BEGIN
	NEW(next);
	next.voxel:=v;
END push;
END VoxelList;
*)

TYPE NCube*=OBJECT(Voxel);
VAR
	normal: PT; 
	color: Color;
	
PROCEDURE Shade (VAR ray: Ray);
VAR
	dot,omm,r,g,b,bl: REAL;	
BEGIN
	dot := ABS(normal.x*ray.dxyz.x + normal.y*ray.dxyz.y+ normal.z*ray.dxyz.z); 
	ray.r := ray.r + color.red * ray.ra*dot;
	ray.g := ray.g + color.green * ray.ga*dot;
	ray.b := ray.b + color.blue * ray.ba*dot; 		
	ray.terminate:=TRUE
END Shade;

PROCEDURE&init*(n: PT; c: Color);
BEGIN
	normal:=n;
	color:= c;
END init;

END NCube;

TYPE Cell*=OBJECT(Voxel);
VAR 
	red*,green*,blue*,black*,alpha*: REAL;
	colored*,frozen*:BOOLEAN;
	offset*:PT;
	texcube*:TexCube;
PROCEDURE setcolor* (r,g,b,bl,a: REAL); 
END setcolor;
PROCEDURE setcolorrec*(r,g,b,bl,a: REAL); 
END setcolorrec;
PROCEDURE erase*(p:PT; resolution:LONGINT);
END erase;
PROCEDURE copyclear*;
END copyclear;
PROCEDURE fill*(v: Voxel);
END fill;
PROCEDURE line*(a,b: PT; level: LONGINT; v: Voxel);
END line;
PROCEDURE proberec*(p:PT; resolution,scale:LONGINT):Voxel;
END proberec;
PROCEDURE FRaster*( f: FR; resolution: LONGINT); 
END FRaster;
PROCEDURE FRasterrec*(f: FR; resolution: LONGINT; origin: PT; scale: LONGINT); 
END FRasterrec;
PROCEDURE FRasterSolid*( f: FR; resolution: LONGINT); 
END FRasterSolid;
PROCEDURE FRasterrecSolid*(f: FR; resolution: LONGINT; origin: PT; scale: LONGINT); 
END FRasterrecSolid;
END Cell;

TYPE FR*=OBJECT
VAR
	bbc1*,bbc2*,norml*: PT;		(*any two diagonally opposite corners of the bounding box of the object *)
	scale*: REAL; 	(*might be needed as this object is handed down to mcell levels in v-rasterization*)
	vox*,imposter*: Voxel;
	mir*: REAL;
	color*:Color;
	allowdeath*,passable*:BOOLEAN;
	
PROCEDURE in*(p:PT):BOOLEAN;
VAR
	d:REAL;
BEGIN
	d:=d2s(p);
	RETURN(d<0)
END in;

PROCEDURE d2s*(p:PT):REAL;  (* distance to surface *)
BEGIN
	norml:=p;
	RETURN 0
END d2s;

PROCEDURE closestPT*(p:PT):PT;  
VAR
	cp: PT;
BEGIN
	RETURN cp
END closestPT;

PROCEDURE normaltf*(p:PT):BOOLEAN;
BEGIN
	RETURN FALSE
END normaltf;

PROCEDURE normal*(p:PT):PT;
BEGIN
	normalizePT(norml);		(* norml is often calculated in d2s but not normalized there *)
	RETURN norml					(* this is the normal for the most recent point handed to d2s *)
END normal;

PROCEDURE setvoxel*(v:Voxel);  
BEGIN
	vox:=v;
	imposter:=v
END setvoxel;

PROCEDURE setcolor*(r,g,b: REAL);  
BEGIN
	color.red:=r; color.green:=g; color.blue:=b; 
END setcolor;

PROCEDURE getcolor*(p:PT):Color;
BEGIN
	RETURN color
END getcolor;

PROCEDURE setimposter*(v:Voxel);  
BEGIN
	imposter:=v
END setimposter;

PROCEDURE getimposter*(p:PT):Voxel;
BEGIN
	RETURN imposter
END getimposter;

PROCEDURE mirror*(p:PT):REAL;
BEGIN
	RETURN mir
END mirror;

PROCEDURE voxel*(p:PT):Voxel;
BEGIN
	RETURN vox
END voxel;

PROCEDURE ncube*(p:PT):Voxel;
BEGIN	
	RETURN NIL			
END ncube;

PROCEDURE death*(p:PT):BOOLEAN;
BEGIN
	RETURN allowdeath
END death;

PROCEDURE pass*(p:PT):BOOLEAN;
BEGIN
	RETURN passable
END pass;

END FR;

TYPE P=PROCEDURE (v:Voxel):Voxel;

VAR
	voxelist: ARRAY 100 OF V;
	fog*:REAL;
	rlimit*: INTEGER;
	iterlimit*: LONGINT;
	speed*:REAL;
	frame*: LONGINT;
	rand*:Random.Generator;
	worldalive*: BOOLEAN;
	gravity*:REAL;
	fuzzon*, STOP*: BOOLEAN;
	singleray*: Ray;	(* for when a single ray is most convenient *)
	blankray*: Ray;
	Face*: ARRAY 6 OF PT;
	EMPTY*,OPAQUE*: Voxel;
	deathflag*:BOOLEAN;
	rays*,frays*:RAYS;
	core0rays*,core1rays*: CORERAYS;  
	LOOK*, LLOOK*: Ray;
	image*, fimage:IMAGE;
	world*:Cell;
	injection*: Voxel;
	cameraPT*,cursorPT*,previouscursorPT*,Origin*: PT;
	cursorvox*:Voxel;
	aperture*: Aperture;
	m2sdelta*,m3sdelta*:REAL;
	DTL*,DTL2*: LONGINT;
	avatar*:Voxel;
	cursordist*:REAL;
	RVR*:BOOLEAN;
	vlist*: ARRAY 100 OF Voxel;
	copy*: Raster.Mode;

PROCEDURE VoxelFromName*(modname: Name): Voxel;
	VAR voxel: Voxel;  fackery: VoxelFackery;
	BEGIN
		IF modname[0]='N' THEN
			GETPROCEDURE(modname, "thisvox", fackery );
			IF (fackery # NIL) THEN  
				voxel := fackery();
				IF (voxel#NIL) THEN
					 voxel.code:=modname
				END
			END
		ELSE
			(* Out.String(modname) *)
		END;
		IF voxel=NIL THEN voxel:=EMPTY END;
		RETURN voxel; (* this may return EMPTY which is what we want *)
END VoxelFromName;

PROCEDURE getray*(VAR x,y: LONGINT):Ray;
BEGIN
	x:=ABS(x); y:=ABS(y);
	IF y<H THEN
		IF x<W THEN
			IF x<W2 THEN
				RETURN(core0rays[x,y])
			ELSE
				x:=x-W2;
				RETURN(core1rays[x,y])
			END
		END
	END;
	RETURN(blankray)
END getray;

PROCEDURE updatecamera*(x,y,z,a,b,c:  REAL);
BEGIN
	previouscursorPT:=cursorPT;
	cameraPT.x:=x; cameraPT.y:=y; cameraPT.z:=z;
	cursorPT.x:=x+a; cursorPT.y:=y+b; cursorPT.z:=z+c; 
END updatecamera;
	
PROCEDURE clearvoxelist*;
VAR i: INTEGER;
BEGIN
	FOR i:=0 TO 99 DO voxelist[i]:=NIL END 
END clearvoxelist;

PROCEDURE clamp*(VAR x: REAL);
BEGIN
	IF x < 0 THEN x := 0 ELSIF x>1 THEN x := 0.9999999 END;
END clamp;

PROCEDURE clamp3*(VAR r,g,b: REAL);
BEGIN
	IF r < 0 THEN r := 0 ELSIF r>1 THEN r := 0.9999999 END;
	IF g < 0 THEN g := 0 ELSIF g>1 THEN g := 0.9999999 END;
	IF b < 0 THEN b := 0 ELSIF b>1 THEN b := 0.9999999 END;
END clamp3;

PROCEDURE clamPT*(VAR a: PT);
BEGIN
	IF a.x < 0 THEN a.x := 0 ELSIF a.x>=1 THEN a.x := 0.9999999 END;
	IF a.y < 0 THEN a.y := 0 ELSIF a.y>=1 THEN a.y := 0.9999999 END;
	IF a.z < 0 THEN a.z := 0 ELSIF a.z>=1 THEN a.z := 0.9999999 END;
END clamPT;

PROCEDURE inzerodotdotonePT*(a: PT):BOOLEAN;
BEGIN
	IF a.x < 0 THEN  RETURN FALSE END;	
	IF a.x >1  THEN  RETURN FALSE END;
	IF a.y < 0 THEN  RETURN FALSE END;	
	IF a.y >1  THEN  RETURN FALSE END;
	IF a.z < 0 THEN  RETURN FALSE END;	
	IF a.z >1  THEN  RETURN FALSE END;	
	RETURN TRUE;
END inzerodotdotonePT;

PROCEDURE addPT*(p,q: PT):PT;
VAR
	r: PT;
BEGIN
	r.x:=p.x+q.x; r.y:=p.y+q.y; r.z:=p.z+q.z;
	RETURN(r);
END addPT;

PROCEDURE subPT*(p,q: PT):PT;
VAR
	r: PT;
BEGIN
	r.x:=p.x-q.x; r.y:=p.y-q.y; r.z:=p.z-q.z;
	RETURN(r);
END subPT;

PROCEDURE mulPT*(p: PT; d: REAL):PT;
VAR
	r: PT;
BEGIN
	r.x:=p.x*d; r.y:=p.y*d; r.z:=p.z*d;
	RETURN(r);
END mulPT;

PROCEDURE divPT*(p: PT; d: REAL):PT;
VAR
	r: PT;
BEGIN
	r.x:=p.x/d; r.y:=p.y/d; r.z:=p.z/d;
	RETURN(r);
END divPT;

PROCEDURE clampColor*(VAR a: Color);
BEGIN
	IF a.red < 0 THEN a.red := 0 ELSIF a.red>=1 THEN a.red := 0.9999999 END;
	IF a.green < 0 THEN a.green := 0 ELSIF a.green >=1 THEN a.green := 0.9999999 END;
	IF a.blue < 0 THEN a.blue := 0 ELSIF a.blue>=1 THEN a.blue := 0.9999999 END;
END clampColor;

PROCEDURE mkcolor*(r,g,b: REAL): Color;
VAR
	c:Color;
BEGIN
	c.red:=r; c.green:=g; c.blue:=b;
	RETURN(c);
END mkcolor;

PROCEDURE mkPT*(x,y,z: REAL): PT;
VAR
	p:PT;
BEGIN
	p.x:=x; p.y:=y; p.z:=z;
	RETURN(p);
END mkPT;

PROCEDURE fuzz3*(VAR x,y,z: REAL; fuzz: REAL);
VAR
	q: REAL;
BEGIN
	q := rand.Uniform()*fuzz - fuzz/2;
	x := x+q; y := y + q; z :=z + q;
	clamp3(x,y,z);
END fuzz3;

PROCEDURE fuzz3noclamp*(VAR x,y,z: REAL; fuzz: REAL);
VAR
	q: REAL;
BEGIN
	q := rand.Uniform()*fuzz - fuzz;
	x := x+q; y := y + q; z :=z + q;
END fuzz3noclamp;

PROCEDURE fuzznorm3*(VAR x,y,z: REAL; fuzz: REAL);
VAR
	q: REAL;
BEGIN
	q := rand.Uniform()*fuzz - fuzz;
	x := x+q; y := y + q; z :=z + q;
	normalize(x,y,z);
END fuzznorm3;

PROCEDURE fzz3*(VAR x,y,z: REAL; fuzz: REAL);
VAR
	q: REAL;
BEGIN
	q := rand.Uniform()*fuzz - fuzz;
	x := x+q; y := y + q; z :=z + q;
END fzz3;

PROCEDURE tick*;
VAR i: INTEGER;
BEGIN
    i := 0;
	WHILE i < 20 DO
		IF voxelist[i] # NIL THEN voxelist[i].tick END;
		INC(i);
	END;
	INC(frame);    
END tick; 

(*PROCEDURE sniprobe;
VAR
	v:Voxel;
	ray: Ray;
	x,y: LONGINT;
BEGIN
	x:=W DIV 2;
	y:=H DIV 2;
	ray:=XNXLBase.rays[x,y];
	v:=world.proberay(ray); 
(*	XNXLBase.cursordist:=2*ray.length/3; *)
END sniprobe;
*)
PROCEDURE cleartick*;
VAR i: INTEGER;
BEGIN
	i:=0;
	WHILE voxelist[i]#NIL DO
		voxelist[i]:=NIL;
		INC(i)
	END
END cleartick; 

PROCEDURE RESET*;
BEGIN
  frame:=0;
END RESET;

PROCEDURE STOPGO*;
BEGIN
 	STOP := ~STOP;
END STOPGO;

PROCEDURE normalize*(VAR x,y,z: REAL);
VAR
	d: REAL;
BEGIN
	d := Math.sqrt(x*x + y*y+z*z);
	IF d = 0 THEN 
		x := 1;
		d := 1;
	END;
	x := x/d; y := y/d; z:= z/d
END normalize;	

PROCEDURE printPT*(p:PT);
BEGIN
(* Where is AosOut.Real()? *)
(*	Out.Real(p.x, 10);
	Out.Real(p.y, 10);
	Out.Real(p.z, 10);
	Out.Ln; *)
END printPT;

PROCEDURE normalizePT*(VAR n:PT);
VAR
	d: REAL;
BEGIN
	d := Math.sqrt(n.x*n.x + n.y*n.y +n.z*n.z);
	IF d = 0 THEN 
		n.x := 1;
		d := 1;
	END;
	n.x := n.x/d; n.y := n.y/d; n.z:=n.z/d
END normalizePT;	

PROCEDURE normalizePTd*(VAR n:PT; VAR d:REAL);
BEGIN
	d := Math.sqrt(n.x*n.x + n.y*n.y +n.z*n.z);
	IF d = 0 THEN 
		n.x := 1;
		d := 1;
	END;
	n.x := n.x/d; n.y := n.y/d; n.z:=n.z/d
END normalizePTd;	

PROCEDURE distance*(a,b: PT):REAL;
VAR
	x,y,z,d: REAL;
BEGIN
	x := (b.x-a.x);
	y := (b.y-a.y);
	z := (b.z-a.z);
	RETURN(Math.sqrt(x*x+y*y+z*z)); 
END distance;

PROCEDURE string*(CONST s: ARRAY OF CHAR);
BEGIN
	Out.String(s); Out.Ln;
END string;

PROCEDURE setPT*(VAR p:PT; x,y,z: REAL);
BEGIN
	p.x := x; 
	p.y := y;
	p.z := z;
END setPT;

PROCEDURE setnormPT*(VAR p:PT; x,y,z: REAL);
BEGIN
	p.x := x; 
	p.y := y;
	p.z := z;
	normalizePT(p);
END setnormPT;

PROCEDURE setColor*(VAR p:Color; r,g,b: REAL);
BEGIN
	p.red := r; 
	p.green := g;
	p.blue := b;
END setColor;

PROCEDURE randPT*():PT;
VAR
	p:PT;
BEGIN
	p.x := rand.Uniform();	
	p.y := rand.Uniform();	
	p.z := rand.Uniform();	
	RETURN p
END randPT;

PROCEDURE randColor*():Color;
VAR
	c:Color;
BEGIN
	c.red:= rand.Uniform();	
	c.green:= rand.Uniform();	
	c.blue := rand.Uniform();	
	RETURN c
END randColor;

PROCEDURE randnormPT*():PT;
VAR
	p:PT;
BEGIN
	p.x := (rand.Uniform()*2)-1;	
	p.y := (rand.Uniform()*2)-1;	
	p.z := (rand.Uniform()*2)-1;	
	normalizePT(p);
	RETURN(p)
END randnormPT;

PROCEDURE randsphPT*(VAR p,n,center:PT; radius: REAL);
(*random point and surface normal on sphere *)
BEGIN
	p.x := (rand.Uniform()*2)-1;	
	p.y := (rand.Uniform()*2)-1;	
	p.z := (rand.Uniform()*2)-1;	
	normalizePT(p);
	n:=p;
	p.x:= center.x+(p.x*radius);
	p.y:= center.y+(p.y*radius);
	p.z:= center.z+(p.z*radius);	
END randsphPT;

PROCEDURE dot*(a,b:PT):REAL;
BEGIN
	normalizePT(a);
	normalizePT(b);
	RETURN(ABS(a.x*b.x+a.y*b.y+a.z+b.z));
END dot;

PROCEDURE dist*(a,b:PT):REAL;
VAR
	dx,dy,dz:REAL;
BEGIN
	dx := a.x-b.x;
	dy := a.y-b.y;
	dz := a.z-b.z;
	RETURN(Math.sqrt(dx*dx+dy*dy+dz*dz));
END dist;

PROCEDURE distsquared*(a,b:PT):REAL;
VAR
	dx,dy,dz:REAL;
BEGIN
	dx := a.x-b.x;
	dy := a.y-b.y;
	dz := a.z-b.z;
	RETURN(dx*dx+dy*dy+dz*dz);
END distsquared;

PROCEDURE midPT*(a,b:PT):PT;
VAR
	m:PT;
BEGIN
	m.x:=(a.x+b.x)/2;
	m.y:=(a.y+b.y)/2;
	m.z:=(a.z+b.z)/2;
	RETURN(m)
END midPT;

PROCEDURE Exit*(ray: Ray):PT;
VAR
	drx, dry, drz: REAL;
	exit:PT;
BEGIN
	clamPT(ray.lxyz);
	IF ray.dxyz.x>0 THEN
		drx:= (1-ray.lxyz.x)/ ray.dxyz.x
	ELSE
		drx :=  (-ray.lxyz.x) / ray.dxyz.x
	END;
	IF ray.dxyz.y > 0 THEN
		dry := (1 - ray.lxyz.y) / ray.dxyz.y
	ELSE
		dry :=  (-ray.lxyz.y) / ray.dxyz.y
	END;
	IF ray.dxyz.z > 0 THEN
		drz := (1-ray.lxyz.z) / ray.dxyz.z
	ELSE
		drz :=  (-ray.lxyz.z) / ray.dxyz.z
	END;
	IF (drx < dry) THEN
		IF (drx < drz ) THEN
			IF ray.dxyz.x>0 THEN
				exit.x:=1; exit.y:=ray.lxyz.y+drx*ray.dxyz.y; exit.z:=ray.lxyz.z+ drx*ray.dxyz.z;
			ELSE
				exit.x:=0; exit.y:=ray.lxyz.y+drx*ray.dxyz.y; exit.z:=ray.lxyz.z+ drx*ray.dxyz.z;
			END;	
		ELSE
			IF ray.dxyz.z>0 THEN
				exit.x:=ray.lxyz.x+drz*ray.dxyz.x; exit.y:=ray.lxyz.y+drz*ray.dxyz.y; exit.z:=1;
			ELSE
				exit.x:=ray.lxyz.x+drz*ray.dxyz.x; exit.y:=ray.lxyz.y+drz*ray.dxyz.y; exit.z:=0;
			END;		
		END;
	ELSIF (dry < drz) THEN
		IF ray.dxyz.y>0 THEN
			exit.x:=ray.lxyz.x+dry*ray.dxyz.x; exit.y:=1; exit.z:=ray.lxyz.z+dry*ray.dxyz.z;
		ELSE
			exit.x:=ray.lxyz.x+dry*ray.dxyz.x; exit.y:=0; exit.z:=ray.lxyz.z+dry*ray.dxyz.z;
		END;
	ELSE
		IF ray.dxyz.z>0 THEN
			exit.x:=ray.lxyz.x+drz*ray.dxyz.x; exit.y:=ray.lxyz.y+drz*ray.dxyz.y; exit.z:=1;
		ELSE
			exit.x:=ray.lxyz.x+drz*ray.dxyz.x; exit.y:=ray.lxyz.y+drz*ray.dxyz.y; exit.z:=0;
		END;		
	END;
	RETURN(exit);
END Exit;


BEGIN
	WMFontManager.Install;
	NEW(rand);
	NEW(rays);
	NEW(frays);
	NEW(EMPTY);
	NEW(OPAQUE);
	EMPTY.passable:=TRUE;
	NEW(world);
	worldalive := TRUE;
	frame:=0;
	fog := 1/10;
	rlimit := 4;
	iterlimit := 500;
	STOP:=TRUE;
	Origin:=mkPT(0,0,0);   (* unneeded initialization *)
	blankray.bla := 1;
	blankray.ra := 1;
	blankray.ga := 1;
	blankray.ba := 1;
	blankray.scale := 1; 
	blankray.length := 0;
	blankray.tscale:=1;
	Face[0].x := 1; Face[0].y := 0; Face[0].z := 0; 
	Face[3].x := -1; Face[3].y := 0; Face[3].z := 0; 
	Face[1].x := 0; Face[1].y := 1; Face[1].z := 0; 
	Face[4].x := 0; Face[4].y := -1; Face[4].z := 0; 
	Face[2].x := 0; Face[2].y := 0; Face[2].z := 1; 
	Face[5].x := 0; Face[5].y := 0; Face[5].z := -1; 	
	m2sdelta:=25;
	m3sdelta:=25;
	DTL:=25;	
	speed:=0.00051;
END XNXLBase.