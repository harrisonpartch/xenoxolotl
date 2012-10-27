MODULE StandaloneDemo;  

IMPORT Unix, StdIO, Strings, Commands;  


	PROCEDURE Do*;  
	VAR buf: ARRAY 64 OF CHAR;  
		n, i: LONGINT;  
		unix: Commands.Context;
	BEGIN 
		unix := StdIO.env;
		
		Unix.GetArgval( "-lines", buf );  Strings.StrToInt( buf, n );
		unix.out.String( "number of lines: " );  unix.out.Int( n, 0 );  unix.out.Ln;
		
		IF n > 63 THEN
			unix.error.String( "too many lines. Program will abort" ); unix.error.Ln;
			unix.error.Update
		END;
	
		FOR i := 1 TO n DO  
			buf[i - 1] := CHR( ORD( ' ' ) + i );  buf[i] := 0X;  
			unix.out.String( buf );  unix.out.Ln 
		END;
		unix.out.Update  
	END Do;  

END StandaloneDemo.



Starting this module from the Unix shell:

		aos  -x StandaloneDemo.Do  -lines 32
		
		aos  -x StandaloneDemo.Do  -lines 120

The second call will abort with a stack backtrace in the logfile!
