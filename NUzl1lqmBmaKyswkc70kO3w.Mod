MODULE NUzl1lqmBmaKyswkc70kO3w;(*anonymous module created by saboteur*)
 
IMPORT Math, XNXLBase, XNXLVoxel, XNXLLifeVox, XNXLTexVox, Random, 
M2:=XNXLM3Space, M3:=XNXLM3Space, XNXLFRep, XNXLRotaVox, XNXLSierp, XNXLHalfSpace;
  
VAR vox: XNXLTexVox.TexVox;
PROCEDURE thisvox*():XNXLBase.Voxel;
BEGIN
	IF vox=NIL THEN NEW(vox,'XNXL.sky2.jpg'); vox.lock() END;
	RETURN vox
END thisvox;

 END NUzl1lqmBmaKyswkc70kO3w. 