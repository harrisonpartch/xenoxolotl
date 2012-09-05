MODULE XNXLEngrainer;
IMPORT  XNXLBase, Files, Streams, GZip, Strings, Out:=KernelLog;

CONST NL=XNXLBase.NL;

TYPE Voxel=XNXLBase.Voxel;
	Cell=XNXLBase.Cell;
	Name=XNXLBase.Name;

PROCEDURE engrain*(voxel: Voxel);
VAR 
	f,fgz: Files.File; 
	fnamegz: Strings.String;
	w: Files.Writer;
BEGIN
	WITH voxel: XNXLBase.Cell DO
		voxel.copyclear
	END;
	f := Files.New("grain");
	fgz := Files.New("sprout");
	IF (f # NIL) THEN
		Files.OpenWriter(w, f, 0);
		voxel.copyclear;
		voxel.engrain(w);
		IF (w.res = Streams.Ok) THEN
			w.Update;
			GZip.Deflate(f,fgz,GZip.BestSpeed,GZip.DefaultStrategy,GZip.NoFlush);
			Files.Register(fgz);
			Out.String("sprout saved");
			Out.Ln
		END
	END;
END engrain;

PROCEDURE sprout*():Voxel;
VAR 
	f,fgz: Files.File; 
	r: Files.Reader; 
	name: Name;
	voxel: Voxel;
	len: LONGINT;
BEGIN
	fgz:= Files.Old("sprout");
	f:=Files.New("cotyledon");
	IF (fgz # NIL) THEN
		GZip.Inflate(fgz,f); 
		NEW(r,f,0);
		Files.OpenReader(r, f, 0);
		r.Bytes(name,0,NL,len);
		Out.String(name); 
		voxel:=XNXLBase.VoxelFromName(name);
		IF voxel#NIL THEN 
			voxel.sprout(r);
			Out.String("germination succeeded")
		ELSE
			Out.String("germination failed")
		END
	ELSE
		Out.String("nonesuch file ");
	END;
	RETURN voxel
END sprout;

END XNXLEngrainer.