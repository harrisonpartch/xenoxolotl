MODULE NGJBlQ95mTkoMhozr6XOJYg;(*anonymous module created by saboteur*)
  
IMPORT XNXLBase,  XNXLTexVox;

VAR vox: XNXLTexVox.TexVox;
PROCEDURE thisvox*():XNXLBase.Voxel;
BEGIN
	RETURN vox
END thisvox;
BEGIN
NEW(vox,'rat.png');
vox.texscale(100000)
 END NGJBlQ95mTkoMhozr6XOJYg. 