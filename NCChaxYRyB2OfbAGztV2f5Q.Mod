MODULE NCChaxYRyB2OfbAGztV2f5Q;IMPORT Math, XNXLBase, XNXLVoxel, XNXLLifeVox, XNXLTexVox, Random, 
M2:=XNXLM3Space, M3:=XNXLM2Space, XNXLFRep, XNXLRotaVox, XNXLSierp, XNXLHalfSpace;
  
PROCEDURE  thisvox*():XNXLBase.Voxel;
VAR
	vox:  M2.torus;
BEGIN
	NEW(vox); 
	RETURN vox
END thisvox;
 END NCChaxYRyB2OfbAGztV2f5Q. 