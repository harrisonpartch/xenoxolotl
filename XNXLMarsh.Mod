MODULE XNXLMarsh;
IMPORT  Base:=XNXLBase , XNXLEngrainer, XNXLVoxel, XNXLVoxel4, XNXLLifeVox, XNXLTexVox, Random, 
M2:=XNXLM2Space, M3:=XNXLM3Space, M5:=XNXLM5Space,  XNXLFRep, XNXLRotaVox, XNXLSierp, XNXLHalfSpace,
(* XNXLVoxConsole, *) Files, Streams, Out:=KernelLog;

CONST sfile="marshstrokes.text"
TYPE Voxel=Base.Voxel;
	Cell=Base.Cell;
	PT=Base.PT;
	Color=Base.Color;  
	VA=ARRAY 5 OF Voxel;

TYPE vloop=OBJECT
VAR
	vox: Voxel;
	prev,next: vloop;

PROCEDURE &init;
BEGIN
	prev:=SELF; 
	next:=SELF; 
	NEW(vox);
	vox.passable:=TRUE;
END init;

PROCEDURE push(v: Voxel):vloop;
VAR
	vl:vloop;
BEGIN
	vox:=v;
	NEW(vl);
	vl.prev:=SELF;
	vl.next:=next;
	next:=vl;
	RETURN(next);
END push;

PROCEDURE clockwise():vloop;
BEGIN
	ASSERT(next#NIL);
	RETURN next
END clockwise;

PROCEDURE anticlockwise():vloop;
BEGIN
	ASSERT(prev#NIL);
	RETURN prev
END anticlockwise;

END vloop;

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
	marshv: vloop;
	Cursor, cloud1,cloud2: XNXLVoxel.BiVox;
	cursormark: XNXLTexVox.TexCubeVox;
	cursorsave,drawvox: Voxel;
	cursorTF*,lines*:BOOLEAN;
	ms: mstroker;
	sfish,gxy,w10,w11,v,EMPTY,lobster, btx,ash, dotz, GREEN,PURPLE,MCUBE:Voxel;
	rd,blu, die,gren,granite,sand,whiteblock,pdestroyer,axolotl,xen,sky1,sky2,tigerlily,cloud: Voxel;
	die0,die1,die2,die3,die4,die5,etile0,etile1,etile2,etile3,etile4,grass,sparx:Voxel;
	sky,dieone, serp,cthulhu,greenball,rat,conglomerate,conglo2,caption,gorge: Voxel;
	i,j,k,ii,jj,kk,iii,jjj,kkk,t,s: LONGINT;
	cost: REAL;
	up,flat,down,right,away,slant,p,pp,q,qq,center,undercenter, normal,xaxis,yaxis,zaxis: PT;
	skybox,skysabot, b3, b33, b333: M3.cell;
	r,g,b: Base.Color;
	red,blue,green: REAL;
	EARTH: XNXLVoxel.DiffuseVox;
	rand: Random.Generator;
	z10: M3.torus;
	x10,q10,y10: M2.cell;
	YELLOW: XNXLVoxel.DiffuseVox;
	BLACK,GREY, WHITE: XNXLVoxel.DiffuseVox;
	 GREENO: XNXLVoxel.COutlineVox;
	MIRROR: XNXLVoxel.DiffuseMVox;
	MIRRORSPHERE: XNXLVoxel4.MirrorSphereInVox;
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
BEGIN
	stroke(Base.cursorPT,cursorsize,marshv.vox)
END draw;

PROCEDURE key*(CONST c:CHAR);
BEGIN
	Out.Char(c);
(*	stroke(Base.cursorPT,cursorsize,XNXLVoxConsole.charvox(c)); *)
END key;

PROCEDURE clear*;
BEGIN
	stroke(Base.cursorPT,cursorsize,EMPTY)
END clear;

PROCEDURE line*;
BEGIN
	Base.world.line(A,B,cursorsize,marshv.vox);	
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
	Base.world.Shade(Base.rays[Base.W DIV 2, Base.H DIV 2]);
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
	marshv:=marshv.push(v)
END push;

PROCEDURE incVN*;
BEGIN
	marshv:=marshv.clockwise();
END incVN;

PROCEDURE decVN*;
BEGIN
	marshv:=marshv.anticlockwise()
END decVN;

PROCEDURE drawavatar*;
BEGIN
(*	XNXLUDPClient.stroke(Base.previouscursorPT,3000,0);	
	IF Base.world.passprobe(Base.cursorPT.x,Base.cursorPT.y,Base.cursorPT.z) THEN
		XNXLUDPClient.stroke(Base.cursorPT,3000,1)
	END *)
	stroke(Base.cameraPT,cursorsize,EMPTY);
	stroke(Base.cameraPT,cursorsize,Base.avatar)
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
	GREEN:=Base.VoxelFromName("NIXARXB2vH6ieKZmsc6mODg");	
	ash:=Base.VoxelFromName("NDQ0mOQYqpYYaLXJy4MS8BQ");	(*leaves.png*)    
	PURPLE:=Base.VoxelFromName("NMdslbwjsXFOAzH64DQMliA");	
	MCUBE:=Base.VoxelFromName("Nr3kPtbyEYLFK3AN2UUVrqg");
	lobster:=Base.VoxelFromName("NznGx2ySiHIGrO5t9Pzcw5Q"); 
	gxy:=Base.VoxelFromName("NmOgKSH5ZXYP3DODELOkO7g"); 	
	sfish:=Base.VoxelFromName("NcufbYokzVEuEfN5MYiDlhA"); 	
	dieone:=Base.VoxelFromName("NCjgzkmiTyecI5x6eOgYqpQ"); 		
	rd:=Base.VoxelFromName("NIXARXB2vH6ieKZmsc6mODg"); 	
	cloud:=Base.VoxelFromName("NIXARXB2vH6ieKZmsc6mODh"); 	
	gren:=Base.VoxelFromName("NUeconrGpx7plz7ym76ibLw"); 		
	die:=Base.VoxelFromName("NCjgzkmiTyecI5x6eOgYqpQ"); 
	granite:=Base.VoxelFromName("NH6nvNlOJNlCtpkDB56ljSw"); 	
	sand:=Base.VoxelFromName("NnTJ6nDktAth4WTAUdr8HYQ"); 		
	whiteblock:=Base.VoxelFromName("NwPicBWw4NfcserX4ELaQ3A"); 	
	pdestroyer:=Base.VoxelFromName("N7Z9LarKWKBcwXrDkSXezPg"); 	
	axolotl:=Base.VoxelFromName("NnKyXYNiHwdxuM6wHrbxwuQ"); 	
	etile0:=Base.VoxelFromName("NMRR8eVl6DBZXeJLNZ0KC6g"); 	
	etile1:=Base.VoxelFromName("NhYOBdcESgNhNEXS2S3OXsw"); 	
	etile2:=Base.VoxelFromName("NiHWuC6tiaYe9Qxl3e1DNqw"); 	
	etile3:=Base.VoxelFromName("N6illtDKEH5g6dsUifexH1Q"); 	
	caption:=Base.VoxelFromName("NxrglfWf3ZTXHHNB8BJ3sSQ"); 	
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
	gorge:=Base.VoxelFromName("NxxxGAernhjFK40xASZZVoQ"); 
      Out.String("EEEEP!");	
	push(rat);
	push(tigerlily);
	push(rd);
	push(cloud);
	push(blu);
	push(gren);
	push(conglomerate);	
	NEW(MIRROR);
	push(MIRROR);
	NEW(MIRRORSPHERE);
	push(MIRRORSPHERE);
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
	push(etile1);
	push(etile2);
	push(etile3);
	push(grass);
	push(sparx);	
	push(cthulhu);
	push(greenball);

	push(conglo2);
	push(tigerlily);
	push(dieone);	
	push(die); 
	push(caption); 
	push(serp);
	push(whiteblock);
	xaxis:=Base.mkPT(1,0,0);
	yaxis:=Base.mkPT(0,1,0);	
	zaxis:=Base.mkPT(0,0,1);	


	NEW(arrow,"next.png");
	arrow.passable:=TRUE;
	push(arrow);
	NEW(meeba,"XNXL.meeba.png");	

	NEW(founder,"XNXL.ourfounder.png");	

	 
	NEW(mutatis,"XNXL.mutatis.png");
	NEW(weev,"XNXL.Freeweev.jpg");	
	NEW(qdog,"XNXL.qdog.png");	
	NEW(galaxy,"XNXL.axolotl.jpg");	
	NEW(gwal,"mule.png");
	
	push(gwal);

	NEW(bwal,"XNXL.grass.png");	
	NEW(checkerfloor,"XNXL.checkerfloor.png");	
	NEW(stone,"XNXL.sand.png");	

	NEW(sky3,"XNXL.sky3.jpg");	
	NEW(sky4,"XNXL.sky4.jpg");	
	NEW(TEX,"XNXL.tree.png");
	NEW(sky4,"yessongs.jpg");	
	NEW(formica,"XNXL.granite.png");
	NEW(linolium,"XNXL.linolium.png");

	NEW(beholdthexenopus,"beholdthexenopus.png");
(*	push(beholdthexenopus);
	push(mutatis); push(qdog); push(weev); push(galaxy); push(EMPTY);
	push(bwal); push(stone); push(sky2); push(sky3); push(sky4); push(formica);
	NEW(starfish,"fruitstripe.png");		
	NEW(MCUBE);	
	push(MCUBE); *)

	NEW(y10);
	y10.setcolor(100,0,0,1000,100);

	NEW(YELLOW); NEW(BROWN);  
	YELLOW.setcolor(1,1,0); 
	BROWN.setcolor(2/3,2/3,1); 	
	NEW(sperea,whiteblock,YELLOW);
	sperea.setSize(11/16);
	NEW(spereb,axolotl,tigerlily);
	spereb.setSize(10/16);	
	FOR i :=0 TO 100 DO
		Base.setPT(center,Base.rand.Uniform(),1/2,1/2);
		y10.stroke(center,28,sperea);
		Base.setPT(center,1/2,1/2,Base.rand.Uniform());
		y10.stroke(center,28,sperea);		
		Base.setPT(center,1/2,Base.rand.Uniform(),1/2);
		y10.stroke(center,28,sperea);	
		Base.setPT(center,Base.rand.Uniform(),1/2,1/2);
		y10.stroke(center,28,spereb);
		Base.setPT(center,1/2,1/2,Base.rand.Uniform());
		y10.stroke(center,28,spereb);		
		Base.setPT(center,1/2,Base.rand.Uniform(),1/2);
		y10.stroke(center,28,spereb);				
	END;	
	y10.lockTF:=TRUE;	
	push(y10);
	TEX.passable:=TRUE;
	NEW(MGREEN);
	MGREEN.setcolor(1/4,0,0,1/3); 

	NEW(BLUE); 
	BLUE.setcolor(3/6,4/6,1);
	NEW(RED); 
	RED.setcolor(1,0,0); 
	NEW(MIRROR);
	NEW(WHITE); 
	WHITE.setcolor(1,1,1);
	NEW(BLACK);
	BLACK.setcolor(0.1,0.1,0.1);

	WHITE.imposter:=BLUE;
	NEW(GREENO); NEW(PURPLE);
	push(GREENO);		
	GREENO.setcolor(0.8,1,0.8); 			
	GREENO.setoutline(0,0,0,1/50);
	GREENO.passable:=TRUE;

	NEW(GREY);
	GREY.setcolor(5/6, 5/6, 5/6);
	NEW(PINK); PINK.setcolor(1,1,8/9);
	PINK.setoutline(1,2/3,2/3);
	NEW(TWHITE); 	TWHITE.setcolor(0.8,0.9,0.9,0);
	TWHITE.passable:=TRUE;
	NEW(TBLUE); TBLUE.setcolor(0,0,1,3); 	
	NEW(TORANGE); TORANGE.setcolor(1,2/3,0,3,0);
	NEW(TDGREEN); TDGREEN.setcolor(0,0.6,0,1,0);
	NEW(TGREEN); TGREEN.setcolor(0,1,0,1,0);
(*	push(TGREEN);
	push(TDGREEN);	
*)	NEW(TRED); TRED.setcolor(0.9,0.00,0.1, 0.9); 
	NEW(TPURPLE); TPURPLE.setcolor(10,10,10,0);
	NEW(TYELLOW); TYELLOW.setcolor(1.7,1.7,0,0,0); 
	NEW(TBROWN); TBROWN.setcolor(2/3,2/3,0,10,0);
	NEW(TBLACK);
	TBLACK.setcolor(0,0,0,0.1);
(*	push(TWHITE); push(TGREEN); push(TYELLOW); push(TORANGE); *)
	TORANGE.passable:=FALSE;
	TBLUE.passable:=FALSE;
	NEW(NIGHT);
	NIGHT.setcolor(1/3,5,3,2,0);
	TRED.passable:=TRUE;
	diameter:=1/3;

	NEW(cloud1);
	cloud1.set(GREENO,cloud);
	cloud1.passable:=TRUE;
	push(cloud1);

	NEW(x10);	
	NEW(cloud2);
	cloud2.set(GREENO,whiteblock);	
	x10.blox[1,1,1]:=y10;
	Base.setPT(up,0,0,1);	
	Base.setPT(right,1,0,0);
	NEW(Q,x10,up, right, 1/30, 1/100);
	
	push(Q);

	NEW(cursormark, "harrisonavatar.0.png");
	push(cursormark);	
	Base.setPT(slant,1,1,1);
	Base.setPT(center,1/2,1/2,1/2);
	xaxis:=Base.mkPT(1,0,0);
	yaxis:=Base.mkPT(0,1,0);	
	zaxis:=Base.mkPT(0,0,1);	
	Base.setPT(up,0,0,1);
	Base.setPT(center,1/2,1/2,0);	
	NEW(plane,center,zaxis);
	plane.setvoxel(granite);		
	NEW(gorgeplane,center,up,"XNXL.gorge.png","XNXL.gorge.png");
	gorgeplane.vox:= granite;
	gorgeplane.rarevox:= MIRROR;
	NEW(z10);
	z10.setcolor(0,0,1,1,1);
	z10.FRaster(gorgeplane,248);
	z10.FRaster(plane,28); 	
	NEW(noise);
	noise.setvoxel(whiteblock);
	noise.seed:=54362;
	noise.octaves:=4;
	noise.persistence:=3;
	noise.a:=1;
	noise.b:=1;
	noise.c:=1;		
(*	z10.FRaster(noise,32); *)

	noise.seed:=54362;
	noise.octaves:=5;
	noise.persistence:=4;
	noise.a:=1;
	noise.b:=1;
	noise.c:=1;		
	noise.setvoxel(sand);	
(*	z10.FRaster(noise,82);	*)

	cursormark.passable:=TRUE;	
	Base.avatar:=cursormark;
	Base.world:=z10; 	
(*	engrain;  
	sprout;	
*)	push(z10);
	push(y10);
	push(Base.world);


END dawn;

BEGIN
	NEW(marshv);
	cursorsize:=243*9;
	cursorTF:=TRUE;
	SNIPEINTO:=TRUE;
END XNXLMarsh.

XNXL.ourfounder.png


