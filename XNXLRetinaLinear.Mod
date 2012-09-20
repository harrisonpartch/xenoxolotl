MODULE XNXLRetina;
IMPORT  XNXL, Base:=XNXLBase, Objects, Out:=KernelLog;

TYPE 
	Ray=Base.Ray;
	PT=Base.PT;
CONST
	TW=Base.W25;
	TH=Base.H25;
	ST=5;

TYPE Subtile*=OBJECT		(* 5x5 ray tile. Traces with edge detection/interpolation *)
VAR
	i,j: LONGINT;		(*position of tile in Base.rays*)
	tracetype: LONGINT;
	TILEDEDGE: REAL; 
	rays: Base.RAYS;
	fovea: BOOLEAN;
	dtl: LONGINT;
		
PROCEDURE & init(a,b: LONGINT; rys:Base.RAYS);
VAR
	fi,fj: BOOLEAN;
BEGIN
	i:=a; j:=b;
	IF (i>(XNXL.W/2-30))&(i<(XNXL.W/2+30)) THEN fi:=TRUE END;
	IF (j>(XNXL.H/2-30))&(j<(XNXL.H/2+30))THEN fj:=TRUE END;	
	tracetype:=0;	
	IF fi&fj THEN 
		tracetype:=2
	ELSIF fi OR fj THEN	
		tracetype:=1
	END;
	rays:=rys
END init;

PROCEDURE interpPT(VAR a,b,c: PT);
BEGIN
	c.x:=(a.x+b.x)/2;
	c.y:=(a.y+b.y)/2;
	c.z:=(a.z+b.z)/2;
END interpPT;

PROCEDURE trace;
VAR
	ii,jj:INTEGER;
BEGIN
	FOR ii := 0 TO ST-1 DO
		FOR jj:= 0 TO ST-1 DO
			rays[i+ii,j+jj].dtl:= Base.DTL;
			Base.world.Shade(rays[i+ii,j+jj])
		END
	END
END trace;
	
END Subtile;

TYPE Tile=OBJECT
VAR
	subtile: ARRAY ST,ST OF Subtile;
	GO: BOOLEAN;
	
PROCEDURE & init(a,b: INTEGER; rys: Base.RAYS);
VAR
	i,j: INTEGER;
BEGIN
	FOR i := 0 TO ST-1 DO
		FOR j :=  0 TO ST-1 DO	
			NEW(subtile[i,j],a+ST*i,b+ST*j,rys)
		END
	END;
END init;

PROCEDURE go;
BEGIN{EXCLUSIVE}
     GO:=TRUE;
END go;

PROCEDURE trace;
VAR
	i,j: INTEGER;
BEGIN
	FOR i := 0 TO ST-1 DO
		FOR j :=  0 TO ST-1 DO	
			subtile[i,j].trace
		END
	END 
END trace;

BEGIN{ACTIVE, PRIORITY(Objects.Normal)}
	REPEAT
		BEGIN{EXCLUSIVE}
			AWAIT(GO);
		END;
		trace;		
		BEGIN{EXCLUSIVE}
			GO:=FALSE;
			incTD;
		END;		
		UNTIL ~Base.worldalive;
END Tile;

VAR
	tile,ftile: ARRAY TW,TH OF Tile;
	a,b: INTEGER;
	tilesdone:INTEGER;
	EDGE*: REAL;
	AFTER*: INTEGER;
	FAST*:INTEGER;
	lsense,ls2:REAL;
	SACCADE*,SACCADE1*:BOOLEAN;

PROCEDURE incTD;
BEGIN{EXCLUSIVE}
	INC(tilesdone);
END incTD;

PROCEDURE zeroTD;
BEGIN{EXCLUSIVE}
	tilesdone:=0;
END zeroTD;
		
PROCEDURE gotilesgo;
VAR
	i,j: INTEGER;
BEGIN
	IF TRUE OR SACCADE OR SACCADE1 THEN
		FOR i:= 0 TO TW-1  DO
			FOR j:= 0 TO TH-1 DO
				tile[i,j].go;
			END
		END
	ELSE
		FOR i:= 0 TO TW-1  DO
			FOR j:= 0 TO TH-1 DO
				tile[i,j].go;
				ftile[i,j].go;
			END
		END
	END
END gotilesgo;

PROCEDURE go*;
VAR
	i,j,t: INTEGER;
BEGIN
	zeroTD;
	gotilesgo; 
	BEGIN{EXCLUSIVE} 
		IF TRUE OR SACCADE OR SACCADE1 THEN
			AWAIT(tilesdone=TW*TH) 
		ELSE
			AWAIT(tilesdone=2*TW*TH) 
		END
	END
END go;

PROCEDURE gosinglecore*;
VAR
	i,j: INTEGER;
BEGIN
	FOR i:= 0 TO TW-1  DO
		FOR j:= 0 TO TH-1 DO
			tile[i,j].trace
		END
	END
END gosinglecore;

PROCEDURE lsu*;
BEGIN
	EDGE:=0
END lsu;

PROCEDURE lsd*;
BEGIN
	EDGE:=0.01
END lsd;

BEGIN 
	FOR a:= 0 TO TW-1  DO
		FOR b:= 0 TO TH-1 DO
			NEW(tile[a,b],a*ST*ST,b*ST*ST,Base.rays);
			NEW(ftile[a,b],a*ST*ST,b*ST*ST,Base.frays)		
		END
	END;
	EDGE:=0.001;
	AFTER:=2;
 	FAST:=3;
 	lsense:=0.2;
END XNXLRetina.