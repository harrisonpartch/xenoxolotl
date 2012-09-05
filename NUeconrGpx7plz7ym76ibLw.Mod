MODULE NUeconrGpx7plz7ym76ibLw;IMPORT Math, XNXLBase, XNXLVoxel, XNXLLifeVox, XNXLTexVox, Random, 
M2:=XNXLM3Space, M3:=XNXLM3Space, XNXLFRep, XNXLRotaVox, XNXLSierp, XNXLHalfSpace;

VAR
	vox:  M3.cell; 
PROCEDURE  thisvox*():XNXLBase.Voxel;
BEGIN
	IF vox=NIL THEN
		NEW(vox); 
		vox.setcolor(0,100000,0,100000,0)
	END;
	RETURN vox
END thisvox;

 END NUeconrGpx7plz7ym76ibLw. 