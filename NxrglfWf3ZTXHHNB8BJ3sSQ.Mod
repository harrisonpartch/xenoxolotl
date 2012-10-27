MODULE NxrglfWf3ZTXHHNB8BJ3sSQ;IMPORT Math, XNXLBase, XNXLVoxel, XNXLLifeVox, XNXLTexVox, Random, 
M2:=XNXLM3Space, M3:=XNXLM3Space, XNXLFRep, XNXLRotaVox, XNXLSierp, XNXLHalfSpace;
  
VAR vox: XNXLTexVox.TexVox;
PROCEDURE thisvox*():XNXLBase.Voxel;
BEGIN
	IF vox=NIL THEN NEW(vox,'caption.jpg')  END;
	RETURN vox
END thisvox;

 END NxrglfWf3ZTXHHNB8BJ3sSQ. 