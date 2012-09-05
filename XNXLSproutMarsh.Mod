MODULE XNXLMarsh;
IMPORT  XNXLBase , XNXLEngrainer, XNXLVoxel, XNXLVoxel4, XNXLLifeVox, XNXLTexVox, Random, 
M2:=XNXLM3Space, M3:=XNXLM3Space, XNXLFRep, XNXLRotaVox, XNXLSierp, XNXLHalfSpace,
(*XNXLUDPClient, *)Files, Streams, Out:=KernelLog;

CONST sfile="marshstrokes.text"
TYPE Voxel=XNXLBase.Voxel;
TYPE PT=XNXLBase.PT;
TYPE  COLOR=XNXLBase.COLOR;  
TYPE VA=ARRAY 5 OF Voxel;

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
	ms: mstroker;
	v,EMPTY,lobster, btx,ash, dotz, GREEN,PURPLE,MCUBE:Voxel;
	i,j,k,ii,jj,kk,iii,jjj,kkk,t,s: LONGINT;
	cost: REAL;
	up,flat,down,right,away,slant,p,pp,q,qq,center,undercenter, normal,xaxis,yaxis,zaxis: PT;
	x3,sand, cell,corridor, pillar,cage,building,FLOWER, CRIMSONFLOWER : M2.cell;
	five: M2.cell;
	six,sixsix, sixsixsix: M2.cell;
	skybox,skysabot, b3, b33, b333: M3.cell;
	r,g,b: XNXLBase.COLOR;
	red,blue,green: REAL;
	EARTH: XNXLVoxel.DiffuseVox;
	rand: Random.Generator;
	E: ARRAY 4 OF M2.cell;
	x10,z10: M2.cell;
	w10: M2.cell;
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
	TBLUE,TRED, TPURPLE,TCOLOR: XNXLVoxel.TransparaVox;
	SRP:  ARRAY 4 OF M2.cell;
	s3,s33,s333:XNXLSierp.Sierp;
	sphere, sphere2: XNXLVoxel. DiffuseSphVox;
	LIFE: XNXLLifeVox.RDVolVox;
	L: XNXLLifeVox.LifeVox;
	MPURPLE, MGREEN: XNXLVoxel.ColoredMVox;
	sky: XNXLVoxel.ColoredVox;
	sky1, sky2, sky3, sky4, TEX, weev, meeba,mutatis,qdog,sparx,galaxy,jwater,
	penrose,slats,arrow,founder,rwal,gwal,bwal,
	beholdthexenopus, googlepocalypse,firetile,rat,starfish,stone, linolium,formica, checkerfloor: XNXLTexVox.TexVox;
	escherfiretile, serptile, stile: VA;
	SIX: M2.cell;
	azure,crimson,yellow: XNXLBase.COLOR;
	cp: PT;
	av: LONGINT;
	title: XNXLBase.Name;
	frame: ARRAY 8 OF CHAR;	
	diameter:REAL;
	blacktick:INTEGER;
	fr: XNXLBase.FRF;
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
	DAISY, D2,D3BLOOM: M2.cell;
	cosmos,checker,checker1,checker2: M3.cell;
	QHOLDER:M3.cell;	
	SP,SP2:M2.cell;
	sperea,spereb: XNXLVoxel4.SphereInVox; 
	mspere:XNXLVoxel4.MirrorSphereInVox;
	Q,R,S,T,U,V:XNXLRotaVox.RVox;
	alfBoxWorld,boxsky: M3.cell;
	pa,pb: PT;
	hs: XNXLHalfSpace.halfvox;
	hsar: ARRAY 100 OF Voxel;
	water: XNXLVoxel.WaterVox;
	vlistN, vN*: INTEGER;
	cursorsize*: LONGINT;
	injectovox: Voxel;

PROCEDURE draw*;
BEGIN
	XNXLBase.world.stroke(XNXLBase.cursorPT,cursorsize,XNXLBase.vlist[vN]);	
	ms.stroke(XNXLBase.cursorPT,cursorsize,XNXLBase.vlist[vN]);
(*	XNXLUDPClient.stroke(XNXLBase.cursorPT,cursorsize,vN);	*)
END draw;

PROCEDURE push(v: Voxel);
BEGIN
	IF vlistN<25 THEN
		XNXLBase.vlist[vlistN]:=v;
		INC(vlistN);	
	END
END push;

PROCEDURE incVN*;
BEGIN
	vN:=vN+1;
	vN:= vN MOD vlistN;
END incVN;

PROCEDURE decVN*;
BEGIN
	vN:=vN-1;
	vN:= vN MOD vlistN;
END decVN;

PROCEDURE drawavatar*;
BEGIN
(*	XNXLUDPClient.stroke(XNXLBase.previouscursorPT,3000,0);	
	IF XNXLBase.world.passprobe(XNXLBase.cursorPT.x,XNXLBase.cursorPT.y,XNXLBase.cursorPT.z) THEN
		XNXLUDPClient.stroke(XNXLBase.cursorPT,3000,1)
	END *)
END drawavatar;

PROCEDURE engrain*;
BEGIN
	XNXLBase.world.copyclear;
	XNXLEngrainer.engrain(XNXLBase.world,"cosmos.grn"); 
END engrain;

PROCEDURE sprout*;
BEGIN
	v:=XNXLEngrainer.sprout("cosmos.grn"); 
	Out.Char('*');
	IF v#NIL THEN
		Out.Char('*');
		IF v IS XNXLBase.Cell THEN 
			Out.Char('*');
			WITH v:XNXLBase.Cell DO 
				v.setcolor(0,2,4,3);
				XNXLBase.world:=v
			END 
		END
	END;
	XNXLBase.world.setcolor(0,2,4,3);
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
      rand:=XNXLBase.rand;	
      dotz:=XNXLBase.VoxelFromName("Nahf6T7P6CYGfcImQTejDpg");	
	btx:=XNXLBase.VoxelFromName("NVY1hEGnyr7z8DtULRMOZIQ");	
	GREEN:=XNXLBase.VoxelFromName("N9zFl2HaX56CegrHdknAkvw");	
	ash:=XNXLBase.VoxelFromName("NDQ0mOQYqpYYaLXJy4MS8BQ");	    
	PURPLE:=XNXLBase.VoxelFromName("NMdslbwjsXFOAzH64DQMliA");	
	MCUBE:=XNXLBase.VoxelFromName("Nr3kPtbyEYLFK3AN2UUVrqg");
	lobster:=XNXLBase.VoxelFromName("NznGx2ySiHIGrO5t9Pzcw5Q"); 
 	NEW(EMPTY);
	EMPTY.passable:=TRUE; 
	push(dotz);
	push(GREEN);
	push(EMPTY);
	push(ash);      
	push(PURPLE);
	push(MCUBE);
	push(lobster);
	sprout;
END dawn;

BEGIN
	cursorsize:=100;
END XNXLMarsh.

XNXL.ourfounder.png


