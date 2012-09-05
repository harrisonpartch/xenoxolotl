MODULE NSIsnYBTYL9BajD8fbPDSqg;IMPORT Math, XNXLBase, XNXLVoxel, XNXLLifeVox, XNXLTexVox, Random, 
M2:=XNXLM3Space, M3:=XNXLM3Space, XNXLFRep, XNXLRotaVox, XNXLSierp, XNXLHalfSpace;
  
VAR vox: XNXLTexVox.TexVox;
PROCEDURE thisvox*():XNXLBase.Voxel;
BEGIN
	NEW(vox,'sparx.png');
	vox.passable:=TRUE;
	vox.emptysplit:=TRUE;
	vox.txTF:=FALSE;
	RETURN vox
END thisvox;

END NSIsnYBTYL9BajD8fbPDSqg. 