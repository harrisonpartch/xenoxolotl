MODULE XNXLHalfSpace;
IMPORT  XNXLBase,XNXLMath;

TYPE PT=XNXLBase.PT;
TYPE Ray = XNXLBase.Ray;
TYPE Voxel = XNXLBase.Voxel;

TYPE halfvox*=OBJECT(Voxel);
VAR
	P*,N*:PT;
	inside,outside*:Voxel;

	
PROCEDURE&init*(v:Voxel; p,n:PT);
BEGIN
	P:=p;
	N:=n;
	XNXLBase.normalizePT(N);
	outside:=v;
END init;

PROCEDURE passprobe*(p:PT):BOOLEAN;
BEGIN
	IF test(p) THEN RETURN(TRUE) ELSE RETURN(FALSE) END
END passprobe;

PROCEDURE tick*;    
BEGIN   
 (*  P.z:=P.z+XNXLBase.rand.Uniform()/20-1/40;    *)
                                                                                                                                                                                                                                                                                                                                                
END tick;
	
PROCEDURE test(p:PT):BOOLEAN;
VAR
	a,b,c,dot:REAL;
BEGIN
	a:=p.x-P.x;
	b:=p.y-P.y;
	c:=p.z-P.z;
	dot:=a*N.x+b*N.y+c*N.z;
	IF dot<0  THEN RETURN(TRUE) ELSE RETURN(FALSE) END	
END test;

PROCEDURE Shade*(VAR ray: Ray);
VAR
	A,B,C: PT;
	a,b,c,depth: REAL;
	i:INTEGER;
BEGIN
	A:=ray.lxyz;
	IF test(A) THEN
		B:=XNXLBase.Exit(ray);
		IF ~test(B) THEN
			FOR i:=0 TO 12 DO
				C:=XNXLBase.midPT(A,B);
				IF test(C) THEN A:=C ELSE B:=C END
			END;
			ray.lxyz:=C;
			ray.xyz.x:=ray.xyz.x+C.x/ray.scale;
			ray.xyz.y:=ray.xyz.y+C.y/ray.scale;		
			ray.xyz.z:=ray.xyz.z+C.z/ray.scale;			
			ray.normal:=N;
			outside.Shade(ray)		
		ELSE 
			outside.Shade(ray)
		END
	ELSE
	outside.Shade(ray);	
	END
END Shade;

END halfvox;


END XNXLHalfSpace.