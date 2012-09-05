MODULE NCChaxYRyB2OfbAGztV2f4Q;IMPORT Math, XNXLBase, XNXLVoxel, XNXLLifeVox, XNXLTexVox, Random, 
M2:=XNXLM3Space, M3:=XNXLM3Space, XNXLFRep, XNXLRotaVox, XNXLSierp, XNXLHalfSpace;
  
PROCEDURE  thisvox*():XNXLBase.Voxel;
VAR
	vox:  M3.torus;
BEGIN
	NEW(vox); 
	RETURN vox
END thisvox;
 END NCChaxYRyB2OfbAGztV2f4Q. 