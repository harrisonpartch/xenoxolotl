MODULE CryptoDiffieHellman;

IMPORT B := CryptoBigNumbers, Out := KernelLog;

TYPE
	DH* =	OBJECT
			VAR
				p, g: B.BigNumber;
				priv: B.BigNumber;

				PROCEDURE & Init*( prkeybits: INTEGER;  CONST pname: ARRAY OF CHAR );
				BEGIN
					ASSERT( (prkeybits > 0) OR (pname # "") );
					IF pname # "" THEN
						GetDHPrime( pname, p, g );  priv := B.NewRandRange( p )
					END;
					IF prkeybits > 0 THEN  priv := B.NewRand( prkeybits, 1, 0 ) END;
				END Init;

				PROCEDURE ComputeKey*( pub: B.BigNumber ): B.BigNumber;
				BEGIN
					RETURN  B.ModExp( pub, priv, p );
				END ComputeKey;

				PROCEDURE GenPubKey*( ): B.BigNumber;
				BEGIN
					RETURN B.ModExp( g, priv, p );
				END GenPubKey;

				PROCEDURE SetPrime*( p, g: B.BigNumber );
				BEGIN
					B.Copy( p, SELF.p );  B.Copy( g, SELF.g );
				END SetPrime;

				PROCEDURE SetPrivKey*( key: B.BigNumber );
				BEGIN
					B.Copy( key, priv )
				END SetPrivKey;


			END DH;


	PROCEDURE GetDHPrime( CONST name: ARRAY OF CHAR;  VAR p, g: B.BigNumber );
	VAR buf: ARRAY 1048 OF CHAR;

		PROCEDURE assign( pos: LONGINT;  CONST val: ARRAY OF CHAR );
		VAR i: LONGINT;
		BEGIN
			FOR i := 0 TO LEN( val ) - 1 DO  buf[pos + i] := val[i]  END
		END assign;

	BEGIN
		IF name = "dh.ssl.192" THEN
			assign( 0,	"D4A0BA0250B6FD2EC626E7EFD637DF76C716E22D0944B88B" );
			B.AssignHex( p, buf, 48 );
			B.AssignInt( g, 3 )
		ELSIF name = "dh.ssl.512" THEN
			assign( 0,	"CBC8E186D01F9417A699F0C61F0DACB6253E0639CA7204B0" );
			assign( 48,	"6EDAC061E67A7725E83BB95F9AB6B5FE990BA1934E3533B8" );
			assign( 96,	"E1F1134F591AD257C026213302C5AE23" );
			B.AssignHex( p, buf, 128 );
			B.AssignInt( g, 2 );
		ELSIF name = "dh.ssl.1024" THEN
			assign( 0,	"F881897D1424C5D1E6F7BF3AE490F4FC73FB34B5FA4C56A2" );
 			assign( 48,	"EAA7E9C0C0CE89E1FA633FB06B3266F1D17BB0008FCA87C2" );
 			assign( 96,	"AE98892617C205D2EC08D08CFF17528CC5079303B1F62FB8" );
			assign( 144,	"1C5247271BDBD18D9D691D524B3281AA7F00C8DCE6D9CCC1" );
			assign( 192,	"112D37346CEA02974B0EBBB171330915FDDD2387075E89AB" );
			assign( 240,	"6B7C5FECA624DC53" );
			B.AssignHex( p, buf, 256 );
			B.AssignInt( g, 2 )
		ELSIF name = "dh.ssh.group1" THEN
			assign( 0,	"FFFFFFFFFFFFFFFFC90FDAA22168C234C4C6628B80DC1CD1" );
			assign( 48,	"29024E088A67CC74020BBEA63B139B22514A08798E3404DD" );
			assign( 96,	"EF9519B3CD3A431B302B0A6DF25F14374FE1356D6D51C245" );
			assign( 144,	"E485B576625E7EC6F44C42E9A637ED6B0BFF5CB6F406B7ED" );
			assign( 192,	"EE386BFB5A899FA5AE9F24117C4B1FE649286651ECE65381" );
			assign( 240,	"FFFFFFFFFFFFFFFF" );
			B.AssignHex( p, buf, 256 );
			B.AssignInt( g, 2 )
		ELSE
			Out.String( "### unknown Diffie Hellman prime '" );  Out.String( name );  Out.String( "' " );
			Out.Ln;
			HALT( 99 )
		END ;
	END GetDHPrime;



BEGIN
END CryptoDiffieHellman.