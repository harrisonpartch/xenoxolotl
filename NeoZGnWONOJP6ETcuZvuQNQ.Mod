MODULE NeoZGnWONOJP6ETcuZvuQNQ;IMPORT XNXLBase, XNXLVoxel, XNXLVoxel4, XNXLLifeVox, XNXLTexVox, Random, 
M2:=XNXLM3Space, M3:=XNXLM3Space, XNXLFRep, XNXLRotaVox, XNXLSierp, XNXLHalfSpace,Out:=KernelLog;
  
VAR
	w2: M3.cell;
	ball: XNXLFRep.sphere;
	center: XNXLBase.PT;
	GREEN: XNXLVoxel.DiffuseVox;
	
PROCEDURE thisvox*():XNXLBase.Voxel;
BEGIN	
	IF w2=NIL THEN
		NEW(w2);
		XNXLBase.setPT(center,1/2,1/2,1/2);
		NEW(ball,center,1/2);
		NEW(GREEN);
		GREEN.setcolor(1/2,1,1/2);
		ball.setvoxel(GREEN);
		w2.FRaster(ball,17); 
		w2.lock;
		w2.frozen:= TRUE; (*engrain and sprout must not recurse inside w2*)
	END;
	w2.copyclear; (*if not, the voxel will not sprout *)
	Out.String("w2 fackery");
	RETURN w2
END thisvox;

 END NeoZGnWONOJP6ETcuZvuQNQ. 