MODULE XLTLMarsh;
IMPORT  XLTLBase , XLTLVoxel, Random, M2:=XLTLM3Space, M3:=XLTLM3Space, M4:=XLTLM4Space,  XLTLlife,
XLTLFRep, XLTLgeomobj, XLTLCellAutoVox, Out:=KernelLog;

TYPE Voxel=XLTLBase.Voxel;
TYPE PT=XLTLBase.PT;
TYPE COLOR=XLTLBase.COLOR;  
TYPE VA=ARRAY 5 OF Voxel;

TYPE Marsh=OBJECT

PROCEDURE dawn*;
BEGIN{EXCLUSIVE}
	sunrise:=TRUE;
	Out.String("dawn streaks the east with roseate phalanges");
	Out.Ln	
END dawn;

PROCEDURE cameratrail*;
BEGIN
	world.stroke(XLTLBase.cursor,XLTLBase.avatarsize, D[nD]);	
END cameratrail;

PROCEDURE draw*;
BEGIN
	world.stroke(XLTLBase.cursor,XLTLBase.avatarsize, D[nD]);		
	Out.Char('*');
	Out.Ln
END draw;

PROCEDURE drawfuse*;
BEGIN
	NEW(fuse);
	fuse.set(XLTLBase.cursor,XLTLBase.avatarsize);
	world.stroke(XLTLBase.cursor,XLTLBase.avatarsize, fuse);
END drawfuse;

PROCEDURE drawgrofuse*;
BEGIN
	NEW(grofuse);
	grofuse.set(XLTLBase.cursor,XLTLBase.avatarsize);
	world.stroke(XLTLBase.cursor,XLTLBase.avatarsize, grofuse);
END drawgrofuse;

PROCEDURE erase*;
BEGIN
	world.stroke(XLTLBase.cursor,XLTLBase.avatarsize, EMPTY2);		
END erase;

PROCEDURE avatar*;
BEGIN
	av.draw(XLTLBase.cursor, 1000, 0);
END avatar;

PROCEDURE cycleD*;
BEGIN
	nD:=(nD+1) MOD 10;
	draw
END cycleD;

PROCEDURE loadmarsh;
BEGIN	
	rand:=XLTLBase.rand;	
	NEW(EMPTY2);
	EMPTY2.passable:=TRUE; 
	XLTLBase.EMPTY:=EMPTY2;
	NEW(EMPTY3);
	EMPTY3.passable:=TRUE; 
	NEW(bi);
	bi.load(sand,rock);
	XLTLBase.setPT(center,0.5, 0.5, 0.5);	
	XLTLBase.setPT(up,0,0,1);	


	NEW(ballfr,center,4/9,3/9);
	ballfr.vox:=sand;
	ballfr.imposter:=rock;
	NEW(ball);
	ball.FRasterSolid(ballfr,35);
	
	ballfr.vox:=rock;
	ballfr.imposter:=rock;
	NEW(ball2);
	ball2.FRaster(ballfr,10);
	ball2.lock:=TRUE;


	NEW(serp);
	serp.serp(rock,granite);	
	serp.imposter:=granite;	
	NEW(rserp);
	rserp.fill(serp);
	rserp.blox[1,1,0]:=rserp;
	rserp.blox[1,1,2]:=rserp;
	rserp.blox[1,0,1]:=rserp;
	rserp.blox[1,2,1]:=rserp;
	rserp.blox[0,1,1]:=rserp;
	rserp.blox[2,1,1]:=rserp;
	rserp.imposter:=pigdestroyer;		

	serp.imposter:=die[3];	
	NEW(xserp);
	xserp.serp(serp,NIL);
	xserp.imposter:=die[3];		
	NEW(zserp);
	zserp.serp(xserp,NIL);
	zserp.imposter:=sand;	


	world.strokep(1/2,1/2,1/2,3,NIL);
	
	FOR i:=1 TO 8 DO 
		FOR j:=1 TO 8 DO		
			world.strokep(i/10,j/10,1/10,10,skyroof);
			world.strokep(i/10,j/10,9/10,10,skyroof);		
			world.strokep(i/10,1/10,j/10,10,skyroof);		
			world.strokep(i/10,9/10,j/10,10,skyroof);					
			world.strokep(1/10,i/10,j/10,10,skyroof);	
			world.strokep(9/10,i/10,j/10,10,skyroof);								
		END
	END;	
	NEW(sixsixsix);
	NEW(six);
	NEW(land);	
	NEW(volvox,rock,sand,EMPTY2);
	land.seed:=314259666;
	land.octaves:=3;
	land.persistence:=8.3;
	land.a:=3; land.b:=3; land.c:=3;
	land.vox:=granite;
	land.imposter:=sand;
	world.FRaster(land,33); 	
	land.seed:=666;
	land.octaves:=3;
	land.persistence:=7;	
	world.FRaster(land,65); 	
	land.a:=7; land.b:=8; land.c:=9;	

	NEW(gorge,center,up,"XNPS.gorge.png","XNPS.gorgels.png");
	gorge.vox:=granite;
	
	gorge.imposter:=granite;
	world.FRaster(gorge,133); 	
	
		
	world.strokep(1/2,1/2,1/2,9,sixsixsix);		

	D[0]:=grass;
	D[1]:=ptcloud;
	die[1].passable:=TRUE;	
	D[2]:=die[2];
	D[3]:=die[3];
	D[4]:=die[4];
	D[5]:=die[5];
	D[6]:=rock;
	D[7]:=sand;
	D[8]:=EMPTY3;
	D[9]:=world;	
	XLTLBase.setPT(p,1/10,1/10,1/10);
	XLTLBase.cursorvox:=poster;
	XLTLBase.SOLID:=NIL;	
	avatrail:=ptcloud;
	Out.String("finally giving way to the hot blue zenith")	
END loadmarsh;

BEGIN{ACTIVE}
	NEW(world);
	world.passable:=TRUE;
	XLTLBase.world:=world;
	AWAIT(sunrise);
	loadmarsh
END Marsh;

VAR
	i,j,k,ii,jj,kk,iii,jjj,kkk,t,s: LONGINT;
	cost: REAL;
	center, up, p: PT;
	x3,cell,corridor, pillar,sky,cage,building,FLOWER, CRIMSONFLOWER : M2.cell;
	five: M2.cell;
	e,six,sixsixsix: M3.cell;
	serp,rserp,xserp,zserp:M3.cell;
	world*: M3.cell;

	r,g,b: XLTLBase.COLOR;
	red,blue,green: REAL;

	rand: Random.Generator;
	EMPTY2: M2.cell;
	EMPTY3: M3.cell;
	E: ARRAY 4 OF M2.cell;
	ball,ball2: M2.cell;
	ballfr: XLTLFRep.sphere;
	land:XLTLFRep.noise;
	gorge: XLTLFRep.landscape;
	poster*, pigdestroyer*, kuma*, pinkhairedgirl*, galaxy,
	lobster*, axolotl*, sand*, rock*, harrison*,grass*, leaves*, granite*, blackmass*,
	sea*,skyroof*,north*,east*,south*,west*: XLTLVoxel.TVox;
	die: ARRAY  10 OF XLTLVoxel.TVox;
	D: ARRAY 10 OF Voxel;
	ptcloud:XLTLVoxel.PtVox;
	sph: XLTLVoxel.SphVox;
	bi: XLTLVoxel.BiVox;
	avatrail: Voxel;
	nD:INTEGER;
	lastcursor: PT;
	sunrise:BOOLEAN;
	marsh*: Marsh;
	av: XLTLgeomobj.pcursor;
	fuse: XLTLCellAutoVox.FuseVox;
	grofuse: XLTLCellAutoVox.GroVox;
	volvox: XLTLlife.RDVolVox;
	
PROCEDURE loadtextures*;
BEGIN
	(* since these objects make opengl calls in their intializers, they must NOT be created from an active object!*)

	NEW(galaxy);	
	galaxy.load("galaxy.jpg");
	NEW(harrison);	
	harrison.load("fruitstripe.png");	
	
	NEW(sand);	
	sand.load("flameblock.png");		
	NEW(rock);
	rock.load("whiteblock.png");
	NEW(grass);
	grass.load("blur.png");
	NEW(leaves);
	leaves.load("greenfuse.png");
	
	NEW(sea);
	sea.load("seafloor.png");
	NEW(skyroof);
	skyroof.load("skyroof.png");
	skyroof.lock:=TRUE;
	NEW(north);
	north.load("northwall.png");
	north.lock:=TRUE;
	NEW(east);
	east.load("eastwall.png");
	east.lock:=TRUE;
	NEW(south);
	south.load("southwall.png");
	south.lock:=TRUE;
	NEW(west);
	west.load("westwall.png");
	west.lock:=TRUE;
	
	NEW(granite);
	granite.load("granite.png");	
	NEW(blackmass);
	blackmass.load("blackmass.png");	
	NEW(kuma);
	kuma.load("pigdestroyer.jpg");	
	NEW(pinkhairedgirl);
	pinkhairedgirl.load("pinkhairedgirl.jpg");		
	NEW(poster);
	poster.load("XLTLavatarscyall.png");		
	NEW(pigdestroyer);
	pigdestroyer.load("beatabeatrix.jpg");		
	NEW(ptcloud);
	NEW(sph);
	NEW(XLTLCellAutoVox.green); 
	NEW(XLTLCellAutoVox.red);
	NEW(XLTLCellAutoVox.blue);	
	XLTLCellAutoVox.green.load("greenfuse.png");	
	XLTLCellAutoVox.red.load("flamefuse.png");	
	XLTLCellAutoVox.blue.load("ashfuse.png");
	NEW(die[0]);
	NEW(die[1]);
	NEW(die[2]);	
	NEW(die[3]);
	NEW(die[4]);
	NEW(die[5]);
	die[0].load("diezero.png");
	die[1].load("dieone.png");
	die[2].load("dietwo.png");
	die[3].load("diethree.png");
	die[4].load("diefour.png");
	die[5].load("diefive.png");	
	NEW(marsh);
	NEW(av);
END loadtextures;

END XLTLMarsh.

XLTL.ourfounder.png



