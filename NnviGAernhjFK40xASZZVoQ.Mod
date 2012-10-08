MODULE NnviGAernhjFK40xASZZVoQ;(*anonymous module created by saboteur*)
  
IMPORT XNXLBase,  XNXLFRep,  M3:=XNXLM3Space;

TYPE Ray = XNXLBase.Ray;
	Voxel = XNXLBase.Voxel;  
	PT =XNXLBase.PT;
	
VAR 
	ball: XNXLFRep.sphere;
	n3ball: M3.cell;
	v:Voxel;
	center:  PT;
PROCEDURE thisvox*():XNXLBase.Voxel;
BEGIN
	RETURN n3ball
END thisvox;

BEGIN
	v:=XNXLBase.VoxelFromName("N6illtDKEH5g6dsUifexH1Q"); 
	XNXLBase.setPT(center,1/2,1/2,1/2);
	NEW(ball,center,6.5/12);
	ball.setcolor(0,1,0.2);
	ball.setvoxel(v);
	NEW(n3ball);
	n3ball.FRaster(ball,9);
	n3ball.DTL:=10000;
	n3ball.frozen:=TRUE 
END NnviGAernhjFK40xASZZVoQ. 