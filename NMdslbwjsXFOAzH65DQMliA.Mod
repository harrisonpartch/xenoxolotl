MODULE NMdslbwjsXFOAzH65DQMliA;IMPORT XNXLBase, XNXLVoxel, XNXLVoxel4, XNXLLifeVox, XNXLTexVox, Random, 
M2:=XNXLM2Space, M3:=XNXLM3Space, XNXLFRep, XNXLRotaVox, XNXLSierp, XNXLHalfSpace;
  
PROCEDURE  thisvox*():XNXLBase.Voxel;
VAR
	vox:  M2.cell;
BEGIN
	NEW(vox); 
	RETURN vox
END thisvox;
 END NMdslbwjsXFOAzH65DQMliA. 