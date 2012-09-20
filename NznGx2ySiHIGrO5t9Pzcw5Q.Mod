MODULE NznGx2ySiHIGrO5t9Pzcw5Q;IMPORT XNXLBase, XNXLVoxel, XNXLVoxel4, XNXLLifeVox, XNXLTexVox, Random, 
M2:=XNXLM3Space, M3:=XNXLM3Space, XNXLFRep, XNXLRotaVox, XNXLSierp, XNXLHalfSpace;
  
VAR
	vox: XNXLTexVox.TexVox; 
PROCEDURE thisvox*():XNXLBase.Voxel;
BEGIN	
	IF vox=NIL THEN NEW(vox,'lobster.jpg'); 	
	vox.texscale(2157);
 END;
	RETURN vox
END thisvox;

 END NznGx2ySiHIGrO5t9Pzcw5Q. 