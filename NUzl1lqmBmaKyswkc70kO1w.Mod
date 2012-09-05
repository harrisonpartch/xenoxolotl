MODULE NUzl1lqmBmaKyswkc70kO1w;(*anonymous module created by saboteur*)
 
IMPORT Math, XNXLBase, XNXLVoxel, XNXLLifeVox, XNXLTexVox, Random, 
M2:=XNXLM3Space, M3:=XNXLM3Space, XNXLFRep, XNXLRotaVox, XNXLSierp, XNXLHalfSpace;
  
VAR vox: XNXLTexVox.TexVox;
PROCEDURE thisvox*():XNXLBase.Voxel;
BEGIN
	IF vox=NIL THEN NEW(vox,'insect.png'); vox.texscale(1) END;
	RETURN vox
END thisvox;

 END NUzl1lqmBmaKyswkc70kO1w. 