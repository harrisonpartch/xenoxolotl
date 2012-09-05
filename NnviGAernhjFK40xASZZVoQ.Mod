MODULE NnviGAernhjFK40xASZZVoQ;(*anonymous module created by saboteur*)
  
IMPORT XNXLBase,  XNXLFRep,  M3:=XNXLM3Space, XNXLTexVox;

TYPE Ray = XNXLBase.Ray;
	Voxel = XNXLBase.Voxel;  
	PT =XNXLBase.PT;
	
VAR 
	ball: XNXLFRep.sphere;
	insect: XNXLTexVox.TexCubeVox;
	n3ball: M3.cell;
	center:  PT;
PROCEDURE thisvox*():XNXLBase.Voxel;
BEGIN
	RETURN n3ball
END thisvox;

BEGIN
	XNXLBase.setPT(center,1/2,1/2,1/2);
	NEW(ball,center,6.5/12);
	ball.setcolor(0,1,0.2);
	NEW(insect,'sand'); 
	insect.texscale(10000);
	ball.setvoxel(insect);
	NEW(n3ball);
	n3ball.FRaster(ball,9);
	n3ball.frozen:=TRUE 
END NnviGAernhjFK40xASZZVoQ. 