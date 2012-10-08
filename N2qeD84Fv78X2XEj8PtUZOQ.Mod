MODULE N2qeD84Fv78X2XEj8PtUZOQ;(*anonymous module created by saboteur*)
  
IMPORT Base:=XNXLBase,  XNXLFRep, M3:=XNXLM7Space;

TYPE Ray = Base.Ray;
	Voxel = Base.Voxel;  
	PT =Base.PT;
VAR 
	ball: XNXLFRep.sphere;
	v: Voxel;
	conglomerate: M3.cell;
	center:  PT;
	i:INTEGER;
	
PROCEDURE thisvox*():Base.Voxel;
BEGIN
	RETURN conglomerate
END thisvox;

BEGIN
	NEW(conglomerate);
	conglomerate.setcolor(0,0,0,300,300);
	v:=Base.VoxelFromName("NznGx2ySiHIGrO5t9Pzcw5Q"); 
	FOR i :=0 TO 200 DO
		Base.setPT(center,Base.rand.Uniform(),Base.rand.Uniform(),Base.rand.Uniform());
		NEW(ball,center,1/40);
		ball.setcolor(Base.rand.Uniform(),Base.rand.Uniform(),Base.rand.Uniform());		
		conglomerate.FRaster(ball,81)
	END;
	conglomerate.DTL:=10000;
	conglomerate.frozen:=TRUE;
	conglomerate.passable:=FALSE;
(*	conglomerate.register *)
 END N2qeD84Fv78X2XEj8PtUZOQ. 