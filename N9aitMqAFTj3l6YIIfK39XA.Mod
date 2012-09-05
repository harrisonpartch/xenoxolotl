MODULE N9aitMqAFTj3l6YIIfK39XA;IMPORT XNXLBase, XNXLVoxel, XNXLVoxel4, XNXLLifeVox, XNXLTexVox, Random, 
M2:=XNXLM3Space, M3:=XNXLM3Space, XNXLFRep, XNXLRotaVox, XNXLSierp, XNXLHalfSpace;
  

VAR
	w2: M2.cell;
	ball: XNXLFRep.sphere;
	center: XNXLBase.PT;
	
PROCEDURE thisvox*():XNXLBase.Voxel;
BEGIN	
	IF w2=NIL THEN
		NEW(w2);
		XNXLBase.setPT(center,1/2,1/2,1/2);
		NEW(ball,center,1/2);
		ball.setcolor(0,1,0);
		w2.FRaster(ball,17); 
		w2.lock;
		w2.frozen:= TRUE; (*engrain and sprout must not recurse inside w2*)
	END;
	w2.copyclear;
	w2.colored:=FALSE;
	RETURN w2
END thisvox;

 END N9aitMqAFTj3l6YIIfK39XA. 