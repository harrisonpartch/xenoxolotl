MODULE NEmb7fXmcxu1apgyZ8VRovg ;IMPORT XNXLBase, XNXLVoxel, XNXLVoxel4, XNXLLifeVox, XNXLTexVox, Random, 
M2:=XNXLM3Space, M3:=XNXLM3Space, XNXLFRep, XNXLRotaVox, XNXLSierp, XNXLHalfSpace;

PROCEDURE  thisvox*():XNXLBase.Voxel;
VAR vox:  M3.cell;
BEGIN
	NEW(vox); 
	RETURN vox
END thisvox; END NEmb7fXmcxu1apgyZ8VRovg. 