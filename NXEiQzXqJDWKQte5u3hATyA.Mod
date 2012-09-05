MODULE NXEiQzXqJDWKQte5u3hATyA;(*anonymous module created by saboteur*)
  
IMPORT XNXLBase,  XNXLFRep,  M3:=XNXLM3Space;

TYPE Ray = XNXLBase.Ray;
	Voxel = XNXLBase.Voxel;  
	PT =XNXLBase.PT;
	
VAR 
	ball: XNXLFRep.sphere;
	n3ball: M3.cell;
	center:  PT;
PROCEDURE thisvox*():XNXLBase.Voxel;
BEGIN
	RETURN n3ball
END thisvox;

BEGIN
	XNXLBase.setPT(center,1/2,1/2,1/2);
	NEW(ball,center,7/12);
	ball.setcolor(0,1,0.2);
	NEW(n3ball);
	n3ball.FRaster(ball,10);
	n3ball.DTL:=10000;
	n3ball.frozen:=TRUE
END NXEiQzXqJDWKQte5u3hATyA. 