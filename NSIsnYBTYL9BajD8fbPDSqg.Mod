MODULE NSIsnYBTYL9BajD8fbPDSqg;IMPORT Math, XNXLBase, XNXLVoxel, XNXLLifeVox, XNXLTexVox, Random, 
M2:=XNXLM3Space, M3:=XNXLM3Space, XNXLFRep, XNXLRotaVox, XNXLSierp, XNXLHalfSpace;
  
VAR vox: XNXLTexVox.TexVox;
PROCEDURE thisvox*():XNXLBase.Voxel;
BEGIN
	IF vox=NIL THEN NEW(vox,'sparx.png')  END;
	vox.passable:=TRUE;
	RETURN vox
END thisvox;

END NSIsnYBTYL9BajD8fbPDSqg. 