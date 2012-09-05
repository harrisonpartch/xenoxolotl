MODULE NmOgKSH5ZXYP3DODELOkO7g;IMPORT XNXLBase, XNXLVoxel, XNXLVoxel4, XNXLLifeVox, XNXLTexVox, Random, 
M2:=XNXLM3Space, M3:=XNXLM3Space, XNXLFRep, XNXLRotaVox, XNXLSierp, XNXLHalfSpace;
  
VAR vox: XNXLTexVox.TexVox;
PROCEDURE thisvox*():XNXLBase.Voxel;
BEGIN
	IF vox=NIL THEN NEW(vox,'galaxy.jpg'); vox.lock()  END;
	RETURN vox
END thisvox;

 END NmOgKSH5ZXYP3DODELOkO7g. 