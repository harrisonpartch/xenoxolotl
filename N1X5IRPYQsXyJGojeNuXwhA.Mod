MODULE N1X5IRPYQsXyJGojeNuXwhA;IMPORT XNXLBase, XNXLVoxel, XNXLVoxel4, XNXLLifeVox, XNXLTexVox, Random, 
M2:=XNXLM3Space, M3:=XNXLM3Space, XNXLFRep, XNXLRotaVox, XNXLSierp, XNXLHalfSpace;
VAR
	vox: XNXLBase.Voxel;  
PROCEDURE thisvox*():XNXLBase.Voxel;
BEGIN
	IF vox=NIL THEN NEW(vox) END;
	RETURN vox
END thisvox;
END N1X5IRPYQsXyJGojeNuXwhA. 