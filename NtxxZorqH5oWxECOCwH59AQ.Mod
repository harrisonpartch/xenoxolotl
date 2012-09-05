MODULE NtxxZorqH5oWxECOCwH59AQ;(*anonymous module created by saboteur*)
  

IMPORT XNXLBase,  Noise:=XNXLNoise;

TYPE Ray = XNXLBase.Ray;
	Voxel = XNXLBase.Voxel;  
	
TYPE NoiseVox*=OBJECT(XNXLBase.Voxel);
PROCEDURE Shade (VAR ray: Ray);
VAR
	n,m,o,dot,fade:REAL;
BEGIN
	dot := ABS(ray.normal.x*ray.dxyz.x + ray.normal.y*ray.dxyz.y+ ray.normal.z*ray.dxyz.z);
	n:= ABS(Noise.noise3dperlin(ENTIER(ray.lxyz.x*100), ENTIER(ray.lxyz.y*100),ENTIER(ray.lxyz.z*100),666,4,4)/100);
	ray.r:= ray.r + ray.ra*dot*n;
	ray.g:= ray.g + ray.ga*dot*n;	
	ray.b:= ray.b +ray.ba*dot*n;
	ray.terminate:=TRUE
END Shade;
END NoiseVox;  
VAR 
	sky: NoiseVox;
PROCEDURE thisvox*():Voxel;
BEGIN
	IF sky=NIL THEN 
		NEW(sky)
	END;
	RETURN sky
END thisvox;
END NtxxZorqH5oWxECOCwH59AQ. 