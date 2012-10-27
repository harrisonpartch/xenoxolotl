MODULE XNPSMarsh;
IMPORT  XNPSBase , XNPSVoxel, XNPSVoxel4, XNPSLifeVox, XNPSTexVox, Random, 
MSpace:=XNPSM3Space, XNPSM3Space, XNPSFRep, XNPSRotaVox, XNPSierp, XNPSHalfSpace;

TYPE Voxel=XNPSBase.Voxel;
TYPE PT=XNPSBase.PT;
TYPE  COLOR=XNPSBase.COLOR;  
TYPE VA=ARRAY 5 OF Voxel;

VAR
	i,j,k,ii,jj,kk,iii,jjj,kkk,t,s: LONGINT;
	cost: REAL;
	up,flat,down,right,away,slant,p,pp,q,qq,center,undercenter, normal,xaxis,yaxis,zaxis: PT;
	x3,sand, cell,corridor, pillar,cage,building,FLOWER, CRIMSONFLOWER : MSpace.cell;
	five: MSpace.cell;
	six,sixsix, sixsixsix: MSpace.cell;
	skybox,skysabot, b3, b33, b333: XNPSM3Space.cell;
	r,g,b: XNPSBase.COLOR;
	red,blue,green: REAL;
	EARTH: XNPSVoxel.DiffuseVox;
	rand: Random.Generator;
	EMPTY: MSpace.cell;
	E: ARRAY 4 OF MSpace.cell;
	x10,z10: MSpace.cell;
	w10: MSpace.cell;
	YELLOW: XNPSVoxel.DiffuseVox;
	BLACK,GREY, WHITE,GREEN: XNPSVoxel.DiffuseVox;
	 GREENO,PURPLE: XNPSVoxel.OutlineVox;
	MIRROR,MCUBE: XNPSVoxel.DiffuseMVox;
	PINK, BROWN: XNPSVoxel.OutlineVox;
	NIGHT, TGREEN, TDGREEN, TYELLOW, TBROWN, TORANGE: XNPSVoxel.TransparaVox;
	TWHITE, TBLACK: XNPSVoxel.TransparaVox;
	RED, BLUE: XNPSVoxel.DiffuseVox;	
	RDYELLOW: XNPSVoxel.TransparaVox;	
	LW, LG: XNPSVoxel.TransparaVox;
	TBLUE,TRED, TPURPLE,TCOLOR: XNPSVoxel.TransparaVox;
	SRP:  ARRAY 4 OF MSpace.cell;
	SERP:  ARRAY 5 OF XNPSierp.Sierp;	
	sphere, sphere2: XNPSVoxel. DiffuseSphVox;
	LIFE: XNPSLifeVox.RDVolVox;
	L: XNPSLifeVox.LifeVox;
	MPURPLE, MGREEN: XNPSVoxel.ColoredMVox;
	sky: XNPSVoxel.ColoredVox;
	sky1, sky2, sky3, sky4, TEX, weev, meeba,dotz,mutatis,qdog,sparx,galaxy,jwater,
	penrose,slats,lobster,arrow,founder,rwal,gwal,bwal,
	beholdthexenopus, googlepocalypse,firetile,rat,fruitstripe,stone, linolium,formica, checkerfloor: XNPSTexVox.TexVox;
	escherfiretile, serptile, stile: VA;
	SIX: MSpace.cell;
	azure,crimson,yellow: XNPSBase.COLOR;
	cp: PT;
	av: LONGINT;
	title: XNPSBase.Name;
	frame: ARRAY 8 OF CHAR;	
	diameter:REAL;
	blacktick:INTEGER;
	fr: XNPSBase.FRF;
	ball, whiteball: XNPSFRep.sphere;
	plane:XNPSFRep.halfspace;
	cyl: XNPSFRep.cyl;
	lobsterplane,gorgeplane:XNPSFRep.landscape;
	lobstercone: XNPSFRep.texturedcone;
	hexgrid: XNPSFRep.hexgrid;
	yel: XNPSFRep.ellipsoid;
	tnoise: XNPSFRep.tilednoise;	
	noise: XNPSFRep.noise;
	cube: XNPSFRep.cube;
	DAISY, D2,D3BLOOM: MSpace.cell;
	checker: XNPSM3Space.cell;
	QHOLDER:XNPSM3Space.cell;	
	SP,SP2:MSpace.cell;
	sperea,spereb: XNPSVoxel4.SphereInVox; 
	mspere:XNPSVoxel4.MirrorSphereInVox;
	Q,R,S,T,U,V:XNPSRotaVox.RVox;
	alfBoxWorld,boxsky: XNPSM3Space.cell;
	pa,pb: PT;
	hs: XNPSHalfSpace.halfvox;
	hsar: XNPSBase.va100;
	water: XNPSVoxel.WaterVox;
	vlist: ARRAY 20 OF Voxel;
	vlistN, vN*: INTEGER;
	cursorsize*: LONGINT;

PROCEDURE draw*;
BEGIN
	XNPSBase.world.strokevoxel(XNPSBase.cursorPT,cursorsize,vlist[vN]);	
END draw;

PROCEDURE push(v: Voxel);
BEGIN
	vlist[vlistN]:=v;
	INC(vlistN);
	vlistN:= vlistN MOD 20;	
END push;

PROCEDURE incVN*;
BEGIN
	vN:=vN+1;
	vN:= vN MOD 20;
END incVN;

PROCEDURE decVN*;
BEGIN
	vN:=vN-1;
	vN:= vN MOD 20;
END decVN;

PROCEDURE drawavatar*;
BEGIN
	XNPSBase.world.strokevoxel(XNPSBase.previouscursorPT,3000,EMPTY);	
	IF XNPSBase.world.passprobe(XNPSBase.cursorPT.x,XNPSBase.cursorPT.y,XNPSBase.cursorPT.z) THEN
		XNPSBase.world.strokevoxel(XNPSBase.cursorPT,3000,XNPSBase.avatar)
	END
END drawavatar;

PROCEDURE randPT*():PT;
VAR
	p:PT;
BEGIN
	p.x :=1/2+((1/2-rand.Uniform())*0.97);	
	p.y := 1/2+((1/2-rand.Uniform())*0.97);
	p.z := 1/2+((1/2-rand.Uniform())*0.97);	
	RETURN p
END randPT;

BEGIN
	rand:=XNPSBase.rand;	
	xaxis:=XNPSBase.mkPT(1,0,0);
	yaxis:=XNPSBase.mkPT(0,1,0);	
	zaxis:=XNPSBase.mkPT(0,0,1);	
	NEW(EMPTY);
	EMPTY.passable:=TRUE; 
	EMPTY.setcolor(0,0,0,0);
	EMPTY.lock;
	NEW(sky);
	sky.setcolor(0,0,1);
	sky.passable:=FALSE;
	NEW(arrow,"next.png");
	NEW(meeba,"XNPS.meeba.png");	
	NEW(sparx,"XNPS.sparx.png");
	NEW(lobster,"fiveray.png");
	NEW(founder,"XNPS.ourfounderavatar.png");	
	NEW(dotz,"XNPS.dotz.png");
	dotz.transparent:=TRUE;
	dotz.passable:=TRUE; 
	push(arrow); push(meeba); push(sparx); push(lobster); push(founder); push(dotz);
	NEW(mutatis,"XNPS.mutatis.png");
	NEW(weev,"XNPS.Freeweev.jpg");	
	NEW(qdog,"XNPS.qdog.png");	
	NEW(galaxy,"XNPS.axolotl.png");	
	NEW(gwal,"XNPS.meeba.png");
	NEW(rwal,"XNPS.sparx.png");		
	NEW(bwal,"XNPS.grass.png");	
	NEW(checkerfloor,"XNPS.checkerfloor.png");	
	NEW(stone,"XNPS.sand.png");	
	NEW(sky2,"XNPS.sky2.jpg");	
	NEW(sky3,"XNPS.sky3.jpg");	
	NEW(sky4,"XNPS.sky4.jpg");	
	NEW(TEX,"XNPS.tree.png");
	NEW(sky4,"yessongs.jpg");	
	NEW(formica,"XNPS.granite.png");
	NEW(linolium,"XNPS.linolium.png");
	NEW(rat,"XNPS.rat.png");
	rat.transparent:=FALSE;
	NEW(beholdthexenopus,"beholdthexenopus.png");
	push(beholdthexenopus);
	push(mutatis); push(qdog); push(weev); push(galaxy); push(EMPTY);
	push(bwal); push(stone); push(sky2); push(sky3); push(sky4); push(formica);
	NEW(fruitstripe,"XNPS.starfish.png");		
	NEW(MCUBE);	
	push(MCUBE);
	NEW(googlepocalypse, "XNPS.googlepocalypse.png");
	NEW(firetile, "XNPS.eschersquidtile.0.png");	
	escherfiretile[0]:= firetile;
	NEW(firetile, "XNPS.eschersquidtile.1.png");	
	escherfiretile[1]:= firetile;
	NEW(firetile, "XNPS.eschersquidtile.2.png");	
	escherfiretile[2]:= firetile;
	NEW(firetile, "XNPS.eschersquidtile.3.png");	
	escherfiretile[3]:= firetile;
	NEW(firetile, "XNPS.eschersquidtile.4.png");	
	escherfiretile[4]:= firetile;		
	NEW(slats,"XNPS.slats.png");	
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
	NEW(penrose,"XNPS.penrose.jpg");
	penrose.imposter:=WHITE;	
	NEW(GREEN); NEW(GREENO); NEW(PURPLE);
	GREEN.setcolor(0.2,0.8,0.3); 
	push(GREENO);		
	GREENO.setcolor(0.8,1,0.8); 			
	GREENO.setoutline(1,0.4,1);
	PURPLE.setcolor(1/2,1/2,1);	
	PURPLE.setoutline(1,1,0);		
	
	NEW(YELLOW); NEW(BROWN);  
		
	YELLOW.setcolor(1,1,0); 
	BROWN.setcolor(2/3,2/3,1); 


	NEW(GREY);
	GREY.setcolor(5/6, 5/6, 5/6);
	NEW(PINK); PINK.setcolor(1,1,8/9);
	PINK.setoutline(1,2/3,2/3);
	NEW(TWHITE); 	TWHITE.setcolor(10,10,10,0);
	TWHITE.passable:=TRUE;
	XNPSBase.OPAQUE:=TWHITE;
	NEW(TBLUE); TBLUE.setcolor(0,0,1,0.0); 	
	NEW(TORANGE); TORANGE.setcolor(1,2/3,0,3);
	NEW(GREEN); GREEN.setcolor(0,1,0);
	NEW(TDGREEN); TDGREEN.setcolor(0,0.6,0,1);
	NEW(TGREEN); TGREEN.setcolor(0,1,0,1);
	push(TGREEN);
	push(TDGREEN);	
	NEW(TRED); TRED.setcolor(0.9,0.00,0.1, 0.9); 
	NEW(TPURPLE); TPURPLE.setcolor(10,10,10,0);
	NEW(TYELLOW); TYELLOW.setcolor(1.7,1.7,0,0); 
	NEW(TBROWN); TBROWN.setcolor(2/3,2/3,0,10);
	NEW(TBLACK);
	TBLACK.setcolor(0,0,0,0.1);
	push(TWHITE); push(TGREEN); push(TYELLOW); push(TORANGE);
	NEW(NIGHT);
	NIGHT.setcolor(1/3,5,3,2);
	TRED.passable:=TRUE;
	XNPSBase.setCOLOR(g,1,1,0);
	XNPSBase.setCOLOR(r,1,1/3,0);
	XNPSBase.setCOLOR(azure,1/4,1/4,1);
	diameter:=1/3;
	
	XNPSBase.setPT(p,0.51,1/2,1/2);
	NEW(DAISY); NEW(D2);NEW(cube);

	XNPSBase.setPT(center,1/2,1/2,1/2);
	XNPSBase.setPT(undercenter,1/2,1/2,1/2);
	XNPSBase.setPT(up,0,0,1);	
	XNPSBase.setPT(down,0,0,-1);
	XNPSBase.setPT(right,1,0,0);
	XNPSBase.setPT(away,0,1,0);	

	NEW(mspere);
	push(mspere);
	NEW(sperea,RED,mspere);
	NEW(spereb,sparx,sky);			
	sperea.D2:=1/2;
	spereb.D2:=1/3;
	
	NEW(ball,center,0.4);
	NEW(SP2);
	ball.setcolor(0.3,1,0.3,0);
	SP2.lock;
	SP2.FRasterSolid(ball,9); 
	NEW(SP);	
	SP.lock;
	ball.setcolor(1,1,1,0);
	SP.FRasterSolid(ball,30); 
	push(SP); push(SP2);
	NEW(LIFE,TBLUE,bwal,TBLUE);
	rat.passable:=TRUE;
	LIFE.passable:=TRUE;
	FOR i:=0 TO 33 DO	
		p:=XNPSBase.randPT();
		normal:=XNPSBase.randPT();
		NEW(hs,WHITE,p,normal);
		hsar[i]:=hs;
		p:=XNPSBase.randPT();
		normal:=XNPSBase.randPT();
		NEW(hs,RED,p,normal);	
		hsar[i+33]:=hs;	
		p:=XNPSBase.randPT();
		normal:=XNPSBase.randPT();
		NEW(hs,BLUE,p,normal);	
		hsar[i+33]:=hs;	
	END;	
	NEW(z10);
	z10.passable:=TRUE;
	z10.lock;
	FOR i:=0 TO 1000 DO	
		p:=XNPSBase.randPT();
		z10.strokevoxel(p,5,hsar[rand.Dice(100)]);
	END;		

	NEW(SERP[0]);	
	NEW(SERP[1]);	
	NEW(SERP[2]);	
	NEW(SERP[3]);		
	NEW(SERP[4]);		
	SERP[0].passable:=TRUE;
	SERP[1].passable:=TRUE;	
	SERP[2].passable:=FALSE;	
	SERP[3].passable:=FALSE;	
	SERP[0].imposter:=SERP[0];	
	SERP[1].imposter:=GREEN;
	SERP[2].imposter:=jwater;
	SERP[3].imposter:=sparx;
	SERP[4].imposter:=SERP[1];
	TRED.passable:=FALSE;
	SERP[0].sierp(GREEN,TRED);
	SERP[1].sierp(SERP[1],TRED);	
	SERP[2].sierp(arrow,WHITE);		
	SERP[3].sierp(SERP[2],TBLACK);	
	SERP[4].sierp(arrow,GREEN);	
	FOR i:=0 TO 4 DO serptile[i]:=SERP[i] END;
	
	NEW(Q,SP2,up,1/100);
	NEW(QHOLDER);
	QHOLDER.blox[1,1,1]:=Q;
	QHOLDER.bloxtf[1,1,1]:=TRUE;
	NEW(gorgeplane,center,up,"XNPS.gorge.png","XNPS.gorge.png");
	gorgeplane.vox:= bwal;
	gorgeplane.imposter:=EMPTY;
	NEW(water);
	TBLUE.setcolor(0,0,1/7,1/6); 	
	water.murkydepths:=TBLUE;
	water.passable:=TRUE;
	gorgeplane.rarevox:= TBLUE;
	escherfiretile[4]:= water;	
	NEW(checker);
	checker.fillchequer(sperea,spereb);
	water.passable:=TRUE;	
	NEW(x10);		
	x10.passable:=TRUE; 
	x10.setcolor(0,0,0,1/3); 
	NEW(w10);		
	w10.passable:=TRUE; 
	w10.setcolor(4,0,0,4); 	
	NEW(noise);
	noise.seed:=ENTIER(rand.Uniform()*100000);	
	noise.octaves:=3;
	noise.persistence:=6;
	noise.a:=1;
	noise.b:=1;
	noise.c:=1;	
	noise.vox:=stone;
	NEW(tnoise);
	tnoise.seed:=ENTIER(rand.Uniform()*100000);	
	tnoise.octaves:=3;
	tnoise.persistence:=6;
	tnoise.a:=3;
	tnoise.b:=3;
	tnoise.c:=3;	
	tnoise.va:=hsar;
	tnoise.va[0]:=SERP[1];
	tnoise.va[2]:=SERP[2];
	tnoise.va[2]:=bwal;
	tnoise.va[3]:=stone;
	tnoise.va[4]:=z10;
	x10.FRaster(noise,33); 
	push(w10);
	noise.vox:=w10;	
	center.z:=0.06;
	x10.FRaster(gorgeplane,65); 		
	NEW(plane,center,up);
	plane.vox:=BLUE;
	x10.FRaster(plane,17); 

	noise.seed:=ENTIER(rand.Uniform()*100000);	
	noise.octaves:=3;
	noise.persistence:=6;
	noise.a:=1;
	noise.b:=1;
	noise.c:=1;	
	noise.vox:=bwal;
	w10.FRaster(noise, 35); 
	SERP[1].register;
	FOR i:=0 TO 43 DO
		p:=XNPSBase.randPT();
		p.z:=p.z-0.3;
		 x10.strokevoxel(p,30,SP2);
	 END;
	
	x10.setout(WHITE);
	XNPSBase.world:=x10;
	TRED.setcolor(1,0,0,0);
	TRED.passable:=TRUE;
	cursorsize:=1000;
	founder.passable:=TRUE;
	XNPSBase.avatar:=founder
END XNPSMarsh.

XNPS.ourfounder.png



