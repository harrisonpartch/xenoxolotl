MODULE anony;(*anonymous module created by saboteur*)
  
IMPORT Base:=XNXLBase,  XNXLFRep, M3:=XNXLM3Space;

TYPE Ray = Base.Ray;
	Voxel = Base.Voxel;  
	PT =Base.PT;
VAR 
	ball: Voxel;
	conglomerate: M3.cell;
	center:  PT;
	i:INTEGER;
	
PROCEDURE thisvox*():Base.Voxel;
BEGIN
	RETURN conglomerate
END thisvox;

BEGIN
	ball:=Base.VoxelFromName("NIqy3HQ4ZK8iRwAXelYYnsQ");	
	NEW(conglomerate);
	conglomerate.setcolor(1,1,1,0,0);
	FOR i :=0 TO 200 DO
		Base.setPT(center,0.4+Base.rand.Uniform()/5,0.4+Base.rand.Uniform()/5,Base.rand.Uniform());	
		conglomerate.stroke(center,27,ball)
	END;
	conglomerate.DTL:=10000;
	conglomerate.frozen:=TRUE;
	conglomerate.passable:=FALSE;
	conglomerate.register
 END anony. 