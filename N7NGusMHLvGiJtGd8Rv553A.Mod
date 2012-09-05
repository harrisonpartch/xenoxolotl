MODULE N7NGusMHLvGiJtGd8Rv553A;IMPORT Math, XNXLBase, XNXLVoxel, XNXLLifeVox, XNXLTexVox, Random, 
M2:=XNXLM3Space, M5:=XNXLM5Space, XNXLFRep, XNXLRotaVox, XNXLSierp, XNXLHalfSpace;
  
PROCEDURE  thisvox*():XNXLBase.Voxel;
VAR
	vox:  M5.cell;
	
BEGIN
	NEW(vox); 
	vox.setcolor(0,0,0,3);
	RETURN vox
END thisvox;

 END N7NGusMHLvGiJtGd8Rv553A. 