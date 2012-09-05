MODULE XNXLMarsh;
IMPORT  Base:=XNXLBase , XNXLEngrainer, XNXLVoxel, XNXLVoxel4, XNXLLifeVox, XNXLTexVox, Random, 
M2:=XNXLM2Space, M3:=XNXLM3Space, XNXLFRep, XNXLRotaVox, XNXLSierp, XNXLHalfSpace,
(*XNXLUDPClient, *)Files, Streams, Out:=KernelLog;

CONST sfile="marshstrokes.text"
TYPE Voxel=Base.Voxel;
	Cell=Base.Cell;
	PT=Base.PT;
	Color=Base.Color;  
	VA=ARRAY 5 OF Voxel;

TYPE mstroker=OBJECT
VAR f: Files.File; w: Files.Writer;
strokes: INTEGER;

PROCEDURE &init;
BEGIN
	f := Files.New(sfile);
	IF (f # NIL) THEN
		Files.OpenWriter(w, f, 0);
	END;
END init;

PROCEDURE tofile;
BEGIN
	IF (w.res = Streams.Ok) THEN
		w.Update;
		Files.Register(f)
	END
END tofile;

PROCEDURE stroke(p:PT; resolution: LONGINT; voxel:Voxel);
BEGIN
	IF (w.res = Streams.Ok)  THEN
		w.String("B.world.mstroke(");
		w.Int(ENTIER(p.x*1000000),6);
		w.Char(',');
		w.Int(ENTIER(p.y*1000000),6);
		w.Char(',');		
		w.Int(ENTIER(p.z*1000000),6);
		w.Char(',');	
		w.Int(resolution,4);
		w.Char(',');	
		w.String('"d41d8cd98f00b204e9800998ecf8427e"');
		w.String(");");
		w.Ln;
	END;
	INC(strokes);
	IF strokes>10 THEN
		strokes:=0;
		tofile;
	END	
END stroke;

END mstroker;

VAR
	Cursor: XNXLVoxel.BiVox;
	cursormark: XNXLTexVox.TexCubeVox;
	cursorsave,drawvox: Voxel;
	cursorTF*,lines*:BOOLEAN;
	ms: mstroker;
	sfish,gxy,w10,w11,v,EMPTY,lobster, btx,ash, dotz, GREEN,PURPLE,MCUBE:Voxel;
	rd,blu, die,gren,granite,sand,whiteblock,pdestroyer,axolotl,xen,sky1,sky2,tigerlily: Voxel;
	die0,die1,die2,die3,die4,die5,etile0,etile1,etile2,etile3,etile4,grass,sparx:Voxel;
	sky,dieone, serp,cthulhu,greenball,rat,conglomerate,conglo2: Voxel;
	i,j,k,ii,jj,kk,iii,jjj,kkk,t,s: LONGINT;
	cost: REAL;
	up,flat,down,right,away,slant,p,pp,q,qq,center,undercenter, normal,xaxis,yaxis,zaxis: PT;
	skybox,skysabot, b3, b33, b333: M3.cell;
	r,g,b: Base.Color;
	red,blue,green: REAL;
	EARTH: XNXLVoxel.DiffuseVox;
	rand: Random.Generator;
	z10: M3.torus;
	q10,x10,y10: M3.cell;
	YELLOW: XNXLVoxel.DiffuseVox;
	BLACK,GREY, WHITE: XNXLVoxel.DiffuseVox;
	 GREENO: XNXLVoxel.COutlineVox;
	MIRROR: XNXLVoxel.DiffuseMVox;
	PINK, BROWN: XNXLVoxel.OutlineVox;
	NIGHT, TGREEN, TDGREEN, TYELLOW, TBROWN, TORANGE: M3.cell;
	TWHITE, TBLACK: XNXLVoxel.TransparaVox;
	RED, BLUE: XNXLVoxel.DiffuseVox;	
	RDYELLOW: XNXLVoxel.TransparaVox;	
	LW, LG: XNXLVoxel.TransparaVox;
	TBLUE,TRED, TPURPLE,TColor: XNXLVoxel.TransparaVox;
	sphere, sphere2: XNXLVoxel. DiffuseSphVox;
	LIFE: XNXLLifeVox.RDVolVox;
	L: XNXLLifeVox.LifeVox;
	MPURPLE, MGREEN: XNXLVoxel.ColoredMVox;
	 sky3, sky4, TEX, weev, meeba,mutatis,qdog,galaxy,jwater,
	penrose,slats,arrow,founder,rwal,gwal,bwal,
	manifesto,beholdthexenopus, googlepocalypse,firetile,starfish,stone, linolium,formica, checkerfloor: XNXLTexVox.TexVox;
	escherfiretile, serptile, stile: VA;
	azure,crimson,yellow: Base.Color;
	cp: PT;
	av: LONGINT;
	title: Base.Name;
	frame: ARRAY 8 OF CHAR;	
	diameter:REAL;
	blacktick:INTEGER;
	fr: Base.FRF;
	ball, whiteball: XNXLFRep.sphere;
	plane:XNXLFRep.halfspace;
	cyl: XNXLFRep.cyl;
	lobsterplane,gorgeplane:XNXLFRep.landscape;
	lobstercone: XNXLFRep.texturedcone;
	hexgrid: XNXLFRep.hexgrid;
	yel: XNXLFRep.ellipsoid;
	tnoise: XNXLFRep.tilednoise;	
	noise: XNXLFRep.noise;
	cube: XNXLFRep.cube;
	checker,checker1,checker2: M3.cell;
	cosmos: Base.Cell;
	QHOLDER:M3.cell;	
	sperea,spereb: XNXLVoxel4.SphereInVox; 
	mspere:XNXLVoxel4.MirrorSphereInVox;
	Q,R,S,T,U,V:XNXLRotaVox.RVox;
	alfBoxWorld,boxsky: M3.cell;
	pa,pb: PT;
	hs: XNXLHalfSpace.halfvox;
	hsar: ARRAY 100 OF Voxel;
	vlistN, vN*: INTEGER;
	cursorsize*,previouscursorsize: LONGINT;
	A,B: PT;
	SNIPE*,SNIPEINTO*:BOOLEAN;

PROCEDURE draw*;
VAR 
	p: PT;
	ray: Base.Ray;
BEGIN
	
	stroke(Base.cursorPT,cursorsize,Base.vlist[vN])
END draw;

PROCEDURE clear*;
VAR 
	p: PT;
	ray: Base.Ray;
BEGIN
	drawcursor;	
	stroke(Base.cursorPT,cursorsize,EMPTY)
END clear;

PROCEDURE line*;
BEGIN
	Base.world.line(A,B,cursorsize,Cursor.v2);	
END line;

PROCEDURE stroke(p:PT; resolution:LONGINT; voxel:Voxel);
BEGIN
	A:=B;
	B:=p;
	Base.world.stroke(p,resolution,voxel);
	IF lines THEN line END
END stroke;

PROCEDURE drawcursor*;
VAR
	p:PT;
	v: Voxel;
	d:REAL;
BEGIN
	p:= Base.rays[Base.W DIV 2, Base.H DIV 2].xyz;
	IF SNIPEINTO THEN
		p.x:=p.x+Base.rays[Base.W DIV 2, Base.H DIV 2].dxyz.x/100000;
		p.y:=p.y+Base.rays[Base.W DIV 2, Base.H DIV 2].dxyz.y/100000;
		p.z:=p.z+Base.rays[Base.W DIV 2, Base.H DIV 2].dxyz.z/100000;
	ELSE 
		p.x:=p.x-Base.rays[Base.W DIV 2, Base.H DIV 2].dxyz.x/100000;
		p.y:=p.y-Base.rays[Base.W DIV 2, Base.H DIV 2].dxyz.y/100000;
		p.z:=p.z-Base.rays[Base.W DIV 2, Base.H DIV 2].dxyz.z/100000;
	END;
	Base.cursorPT:=p; 
END drawcursor;

PROCEDURE drawHUD*;
VAR
	p:PT;
	v: Voxel;
	d:REAL;
BEGIN
	Base.world.stroke(Base.cameraPT,729,cursormark); 	
END drawHUD;

PROCEDURE push*(v: Voxel);
BEGIN
	IF vlistN<98 THEN
		Base.vlist[vlistN]:=v;
		INC(vlistN);	
	END
END push;

PROCEDURE incVN*;
BEGIN
	REPEAT
		vN:=vN+1;
	UNTIL (Base.vlist[vN]#NIL) OR (vN=vlistN);
	vN:= vN MOD vlistN;
	drawvox:=Base.vlist[vN];
END incVN;

PROCEDURE decVN*;
BEGIN
	REPEAT
		vN:=vN-1;
	UNTIL (vN=-1) OR (Base.vlist[vN]#NIL);
	vN:= vN MOD vlistN;
	drawvox:=Base.vlist[vN];
END decVN;

PROCEDURE drawavatar*;
BEGIN
(*	XNXLUDPClient.stroke(Base.previouscursorPT,3000,0);	
	IF Base.world.passprobe(Base.cursorPT.x,Base.cursorPT.y,Base.cursorPT.z) THEN
		XNXLUDPClient.stroke(Base.cursorPT,3000,1)
	END *)
END drawavatar;

PROCEDURE engrain*;
BEGIN
	XNXLEngrainer.engrain(Base.world); 
END engrain;

PROCEDURE sprout*;
VAR v:Voxel;
BEGIN
	Out.String("sprouting...");
	v:=XNXLEngrainer.sprout(); 
	IF (v#NIL) & (v IS Cell) THEN
		WITH  v:Cell DO 
			Base.world:=v;
		END
	ELSE
		NEW(x10);
		Base.world:=x10;
	END
END sprout;

PROCEDURE randPT*():PT;
VAR
	p:PT;
BEGIN
	p.x :=1/2+((1/2-rand.Uniform())*0.97);	
	p.y := 1/2+((1/2-rand.Uniform())*0.97);
	p.z := 1/2+((1/2-rand.Uniform())*0.97);	
	RETURN p
END randPT;

PROCEDURE dawn*;
BEGIN
	NEW(ms);
	NEW(Cursor);
	NEW(EMPTY);
	EMPTY.passable:=TRUE;
	Cursor.v1:=EMPTY;
	Cursor.v2:=EMPTY;
	Cursor.passable:=TRUE;
      rand:=Base.rand;	
      Out.String("EEEEP!");
    	 dotz:=Base.VoxelFromName("Nahf6T7P6CYGfcImQTejDpg");	
	btx:=Base.VoxelFromName("NVY1hEGnyr7z8DtULRMOZIQ");	
	GREEN:=Base.VoxelFromName("NIqy3HQ4ZK8iRwAXelYYnsQ");	
	ash:=Base.VoxelFromName("NDQ0mOQYqpYYaLXJy4MS8BQ");	(*leaves.png*)    
	PURPLE:=Base.VoxelFromName("NMdslbwjsXFOAzH64DQMliA");	
	MCUBE:=Base.VoxelFromName("Nr3kPtbyEYLFK3AN2UUVrqg");
	lobster:=Base.VoxelFromName("NznGx2ySiHIGrO5t9Pzcw5Q"); 
	gxy:=Base.VoxelFromName("NmOgKSH5ZXYP3DODELOkO7g"); 	
	sfish:=Base.VoxelFromName("NcufbYokzVEuEfN5MYiDlhA"); 	
	die:=Base.VoxelFromName("NCjgzkmiTyecI5x6eOgYqpQ"); 		
	rd:=Base.VoxelFromName("NIXARXB2vH6ieKZmsc6mODg"); 	
	gren:=Base.VoxelFromName("NUeconrGpx7plz7ym76ibLw"); 		
	granite:=Base.VoxelFromName("NH6nvNlOJNlCtpkDB56ljSw"); 	
	sand:=Base.VoxelFromName("NnTJ6nDktAth4WTAUdr8HYQ"); 		
	whiteblock:=Base.VoxelFromName("NwPicBWw4NfcserX4ELaQ3A"); 	
	pdestroyer:=Base.VoxelFromName("N7Z9LarKWKBcwXrDkSXezPg"); 	
	axolotl:=Base.VoxelFromName("NnKyXYNiHwdxuM6wHrbxwuQ"); 	
	etile0:=Base.VoxelFromName("NMRR8eVl6DBZXeJLNZ0KC6g"); 	
	etile1:=Base.VoxelFromName("NhYOBdcESgNhNEXS2S3OXsw"); 	
	etile2:=Base.VoxelFromName("NiHWuC6tiaYe9Qxl3e1DNqw"); 	
	etile3:=Base.VoxelFromName("N6illtDKEH5g6dsUifexH1Q"); 	
	etile4:=Base.VoxelFromName("NxrglfWf3ZTXHHNB8BJ3sSQ"); 	
	grass:=Base.VoxelFromName("NJOFc7qhMXMly3lot71bNUw"); 	
	sparx:=Base.VoxelFromName("NSIsnYBTYL9BajD8fbPDSqg"); 
	xen:=Base.VoxelFromName("NZjDHYA8YHHcuymIh1fhHgg"); 		
	serp:=Base.VoxelFromName("NXWCxXWLIcD2LegvoGXXBiQ"); 	
	sky:=Base.VoxelFromName("NtxxZorqH5oWxECOCwH59AQ"); 	
	cthulhu:=Base.VoxelFromName("NuDxZaSfDCnI8xZnbp6c5ew"); 	
	greenball:=Base.VoxelFromName("NnviGAernhjFK40xASZZVoQ"); 	
	rat:=Base.VoxelFromName("NGJBlQ95mTkoMhozr6XOJYg"); 	
	conglomerate:=Base.VoxelFromName("N2qeD84Fv78X2XEj8PtUZOQ"); 	
	conglo2:=Base.VoxelFromName("NsOET4PW7wEUqBGE1Dr3rBQ"); 	
	sky1:=Base.VoxelFromName("N5a2g4M6HYjPJxYSNQvYyvw"); 	
	sky2:=Base.VoxelFromName("NUzl1lqmBmaKyswkc70kO3w"); 	
	tigerlily:=Base.VoxelFromName("NUzl1lqmBmaKyswkc70kO1w"); 				
      Out.String("EEEEP!");	
	push(greenball);
	push(rat);
	push(serp);
	push(rd);
	push(blu);
	push(gren);
	push(MCUBE);
	push(lobster);
	push(dieone);	
	push(GREEN);
	push(ash);      
	push(PURPLE);
	push(gxy);
	push(sfish);
	push(granite);
	push(sand);
	push(whiteblock);
	push(pdestroyer);
	push(axolotl);
	push(granite);
	push(etile1);
	push(etile2);
	push(etile3);
	push(grass);
	push(sparx);	
	push(cthulhu);
	push(greenball);
	push(conglomerate);
	push(conglo2);
	push(tigerlily);
	
	xaxis:=Base.mkPT(1,0,0);
	yaxis:=Base.mkPT(0,1,0);	
	zaxis:=Base.mkPT(0,0,1);	

	NEW(LIFE,axolotl,NIL,die);
	LIFE.passable:=TRUE;
	Base.setPT(center,1/2,1/2,1/2);	push(LIFE);	
	Base.setPT(slant,1,1,1);
	NEW(hs,grass,center,slant);
	push(hs);
	NEW(z10);
	xaxis:=Base.mkPT(1,0,0);
	yaxis:=Base.mkPT(0,1,0);	
	zaxis:=Base.mkPT(0,0,1);	
	NEW(plane,center,zaxis);
	plane.setvoxel(sand);	
	NEW(dieone);
	NEW(noise);
	noise.setvoxel(granite);
	noise.seed:=54362;
	noise.octaves:=4;
	noise.persistence:=5;
	noise.a:=3;
	noise.b:=3;
	noise.c:=3;
	z10.FRasterSolid(plane,9);		
	z10.FRasterSolid(noise,9);		
	noise.setvoxel(greenball);
	noise.seed:=54362;
	noise.octaves:=4;
	noise.persistence:=5;
	noise.a:=1;
	noise.b:=1;
	noise.c:=1;   
	z10.FRasterSolid(noise,9);		
     Base.setPT(center,1/2,1/2,1/2);
	Base.world:=z10; 	
(*	engrain;  
	sprout;	
*)	push(Base.world);
	NEW(cursormark,"harrisonavatar.png");
	push(cursormark);
	NEW(x10);
	NEW(Q,x10,xaxis,zaxis,0.012,0.015);	
	x10.stroke(center,3,rd);
	Cursor.v1:=EMPTY;
	Base.setPT(center,1/2,1/2,1/2);
	NEW(x10);
	FOR i:=0 TO 1000 DO
		x10.stroke(Base.randPT(),28,sparx);
	END;
	x10.stroke(center,1,rd);	
	NEW(Q,x10,xaxis,zaxis,0.02,0.01);	
	Q.passable:=FALSE;
	push(Q);
	push(x10);
	NEW(manifesto,"manifesto.png");
	manifesto.tscale.x:=243*243*9;
	manifesto.tscale.y:=243*243*9;
	manifesto.tscale.z:=243*243*9;
	push(manifesto);
	sparx.passable:=TRUE;
	sparx.emptysplit:=TRUE;
  END dawn;

BEGIN
	cursorsize:=243*9;
	cursorTF:=TRUE;
	SNIPEINTO:=TRUE;
END XNXLMarsh.

XNXL.ourfounder.png


