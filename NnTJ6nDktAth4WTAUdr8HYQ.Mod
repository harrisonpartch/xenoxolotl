MODULE NnTJ6nDktAth4WTAUdr8HYQ;IMPORT Math, XNXLBase, XNXLVoxel, XNXLLifeVox, XNXLTexVox, Random, 
M2:=XNXLM2Space, M3:=XNXLM3Space, XNXLFRep, XNXLRotaVox, XNXLSierp, XNXLHalfSpace;
  
VAR vox: XNXLTexVox.TexCubeVox;
PROCEDURE thisvox*():XNXLBase.Voxel;
BEGIN
	IF vox=NIL THEN NEW(vox,'sand') END;
	RETURN vox
END thisvox;

 END NnTJ6nDktAth4WTAUdr8HYQ. 