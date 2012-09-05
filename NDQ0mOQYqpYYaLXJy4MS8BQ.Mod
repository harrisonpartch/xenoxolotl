MODULE NDQ0mOQYqpYYaLXJy4MS8BQ;IMPORT XNXLBase, XNXLVoxel, XNXLVoxel4, XNXLLifeVox, XNXLTexVox, Random, 
M2:=XNXLM3Space, M3:=XNXLM3Space, XNXLFRep, XNXLRotaVox, XNXLSierp, XNXLHalfSpace;
VAR
	vox: XNXLTexVox.TexVox;
PROCEDURE thisvox*():XNXLBase.Voxel;
BEGIN
	IF vox=NIL THEN NEW(vox,'leaves.png') END;
	RETURN vox
END thisvox;
 END NDQ0mOQYqpYYaLXJy4MS8BQ. 