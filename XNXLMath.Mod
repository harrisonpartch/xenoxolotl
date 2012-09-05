MODULE XNXLMath;
IMPORT Math, XNXLBase;

CONST
	R = 100000;
	N = 1000;
	twopi = 2*Math.pi;
	dx = twopi/R;
	dtp = twopi/N;
	
TYPE Quaternion*=RECORD
   x,y,z,w: REAL
 END;
	
VAR
	Sin,Cos: ARRAY R OF REAL;
	Norm: ARRAY N,N OF XNXLBase.PT;
	i, j: LONGINT;
	x,d, theta, phi: REAL;
	
PROCEDURE qlength(q: Quaternion):REAL;
BEGIN
	RETURN(Math.sqrt(q.x*q.x+q.y*q.y+q.z*q.z+q.w*q.w))
END qlength;

PROCEDURE qnorm(VAR q: Quaternion);
VAR
	l:REAL;
BEGIN
	l:=qlength(q);
	q.x:=q.x/l;
	q.y:=q.y/l;
	q.z:=q.z/l;
	q.w:=q.w/l
END qnorm;

PROCEDURE qconjugate(VAR q: Quaternion);
BEGIN
	q.x:= -q.x;
	q.y:=-q.y;
	q.z:=-q.z;
END qconjugate;

PROCEDURE qmul(VAR a,b,c: Quaternion);
BEGIN
     c.x := a.w*b.x	+a.x*b.w	+a.y*b.z		-a.z*b.y;
     c.y := a.w*b.y	-a.x*b.z	+a.y*b.w	+a.z*b.x;
     c.z:= 	a.w*b.z		+a.x*b.y	-a.y*b.x	+a.z*b.w;
     c.w:=a.w*b.w	-a.x*b.x	-a.y*b.y	-a.z-b.z;
END qmul;

PROCEDURE sin*(x: REAL): REAL;
VAR i: LONGINT;
BEGIN
	i := ENTIER(x/dx) MOD R;
	RETURN Sin[i];	
END sin;

PROCEDURE cos*(x: REAL): REAL;
VAR i: LONGINT;
BEGIN
	i := ENTIER(x/dx) MOD R;
	RETURN Cos[i];	
END cos;

PROCEDURE norm*(theta, phi: REAL):XNXLBase.PT;
BEGIN
	i := ENTIER(theta/dtp) MOD N;
	j := ENTIER(phi/dtp) MOD N;
	RETURN Norm[i,j];	
END norm;

PROCEDURE arccos*(x: REAL): REAL;
BEGIN
	RETURN(Math.arctan(Math.sqrt(ABS((1-x*x))/x)));
END arccos;

PROCEDURE orrot*(VAR a: XNXLBase.PT; b: XNXLBase.PT; theta: REAL);

(* ROTATION OF VECTORS. A ABOUT B. A,B ARE POINTS ON THE UNIT SPHERE. *)
VAR
	costheta, sintheta: REAL;
	x,y,z: REAL;
	u,v,w: REAL;
	uvula: REAL;	
BEGIN
(*	XNXLBase.normalizePT(a);
	XNXLBase.normalizePT(b); 
*)	costheta := Math.cos(theta); sintheta := Math.sin(theta);
	x:=a.x; y:=a.y; z:=a.z; 
	u:=b.x; w:=b.y; v:=b.z;
	uvula:= u*x+v*y+w*z;
	a.x := u*uvula + costheta*(x*(v*v+w*w)-u*(v*y+w*z))+ sintheta*(-w*y+v*z);
	a.y := v*uvula + costheta*(y*(u*u+w*w)-v*(u*x+w*z))+ sintheta*(w*x-u*z);
	a.z := w*uvula + costheta*(z*(u*u+v*v)-w*(u*x+v*y))+ sintheta*(-v*x+u*y);
END orrot;	

BEGIN
	x := 0;  
	FOR i := 0 TO R-1 DO
		Sin[i] := Math.sin(x);
		IF Sin[i] = 0 THEN Sin[i] := 0.0000001 END;  (* Because we must avoid ever dividing by zero *)
		Cos[i] := Math.cos(x);
		IF Cos[i] = 0 THEN Cos[i] := 0.0000001 END;	(* in shaders                                                  *)
		x := x+dx;
	END;
	FOR i := 0 TO N-1 DO
		theta := twopi*i/N;
		FOR j := 0 TO N-1 DO
			phi := twopi*j/N;
			Norm[i,j].x := cos(theta)*sin(phi);
			Norm[i,j].y := sin(theta)*sin(phi);
			Norm[i,j].z := cos(theta);
		END
	END
END XNXLMath.