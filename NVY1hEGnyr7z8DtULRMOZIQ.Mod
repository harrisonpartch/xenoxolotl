MODULE NVY1hEGnyr7z8DtULRMOZIQ;IMPORT XNXLBase, XNXLVoxel, XNXLVoxel4, XNXLLifeVox, XNXLTexVox, Random, 
M2:=XNXLM3Space, M3:=XNXLM3Space, XNXLFRep, XNXLRotaVox, XNXLSierp, XNXLHalfSpace;
 VAR
	vox: XNXLTexVox.TexVox; 
PROCEDURE thisvox*():XNXLBase.Voxel;
BEGIN	
	IF vox=NIL THEN NEW(vox,'beholdthexenopus.png') END;
	RETURN vox
END thisvox;
 END NVY1hEGnyr7z8DtULRMOZIQ. 