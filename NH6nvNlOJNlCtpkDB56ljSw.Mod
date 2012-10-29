MODULE NH6nvNlOJNlCtpkDB56ljSw;
IMPORT XNXLBase, XNXLAudio,XNXLTexVox,  XNXLVoxel, XNXLVoxel4, XNXLMath, Raster, Graphics := WMGraphics, Random, Math,Out := KernelLog; 

TYPE PT=XNXLBase.PT;
TYPE Ray = XNXLBase.Ray;
TYPE Voxel = XNXLBase.Voxel;


VAR 
	insect: XNXLTexVox.TexVox;
	bivox: XNXLVoxel.BiVox;
	RED,YELLOW: XNXLVoxel.DiffuseVox;
	grid: XNXLVoxel.GridVox;
PROCEDURE thisvox*():XNXLBase.Voxel;
BEGIN
	IF bivox=NIL THEN 
		NEW(insect,"memecat1.jpeg"); 
		insect.texscale(10);
		NEW(grid);	
		NEW(bivox);
		bivox.set(grid,insect); 
	END;
	RETURN bivox
END thisvox;

 END NH6nvNlOJNlCtpkDB56ljSw. 