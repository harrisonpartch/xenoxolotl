MODULE N9zFl2HaX56CegrHdknAkvw;IMPORT XNXLBase, XNXLVoxel, XNXLVoxel4, XNXLLifeVox, XNXLTexVox, Random, 
M2:=XNXLM3Space, M3:=XNXLM3Space, XNXLFRep, XNXLRotaVox, XNXLSierp, XNXLHalfSpace;
VAR
	vox: XNXLVoxel.DiffuseVox; 
PROCEDURE thisvox*():XNXLBase.Voxel;

BEGIN
	IF vox=NIL THEN NEW(vox); vox.setcolor(0.2,0.8,0.3);  END;
	RETURN vox
END thisvox;
END N9zFl2HaX56CegrHdknAkvw. 