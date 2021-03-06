MODULE XNXLSaboteur;
IMPORT XNXLBase, Files, Strings, CryptoMD5, CompilerInterface, Texts, TextUtilities, Diagnostics, Base64, Streams, Out:=KernelLog;  

CONST import="(*anonymous module created by saboteur*)
"

TYPE Name=XNXLBase.Name;

VAR
	hasher:CryptoMD5.Hash;
	
PROCEDURE charmd5(VAR hash: ARRAY 16 OF CHAR; VAR charmdhash:Name);
VAR 
	W:Streams.StringWriter; 
	R: Streams.StringReader; 
	i: INTEGER;
	hashox: ARRAY 17 OF CHAR; 
	plain, base64: ARRAY 80 OF CHAR;
BEGIN
	NEW(W,80); NEW(R,80);	
	FOR i:=0 TO 15 DO
		hashox[i]:=hash[i]
	END;
	R.Set(hashox);
	W.Char('N');
	Base64.Encode(R,W);
	W.Get(charmdhash); 
END charmd5;	

PROCEDURE Sabotage(CONST t: ARRAY OF CHAR):Name; 
VAR
	md5: Name;
	hash: ARRAY 16 OF CHAR;
	md5string, anonymod: Strings.String;
	hashtext,anonymodtext: Strings.String;
	len,format,res: LONGINT;
	error:BOOLEAN;
	f: Files.File; w: Files.Writer;
	compiler: CompilerInterface.Compiler;
	text: Texts.Text;
	diagnostics: Diagnostics.Diagnostics
BEGIN
	hasher.Initialize;
	hashtext:=Strings.ConcatToNew(import,t);
(*	Out.String(hashtext^);
	Out.Ln;
*)	len:=Strings.Length(hashtext^);
	hasher.Update(hashtext^,0,len);
	hasher.GetHash(hash,0);	   
	charmd5(hash,md5);
	Out.String(md5);
	Out.Ln;	
	NEW(md5string,28);
	Strings.Concat(md5,".Mod",md5string^);
	Out.String(md5string^);
	Out.Ln;		
	f:=Files.New(md5string^); 
	IF (f # NIL) THEN
		Files.OpenWriter(w, f, 0);
		anonymodtext:=Strings.ConcatToNew("MODULE ", md5);
		anonymodtext:=Strings.ConcatToNew(anonymodtext^,";");		
		anonymodtext:=Strings.ConcatToNew(anonymodtext^,hashtext^);
		anonymodtext:=Strings.ConcatToNew(anonymodtext^," END ");
		anonymodtext:=Strings.ConcatToNew(anonymodtext^,md5);	
		anonymodtext:=Strings.ConcatToNew(anonymodtext^,". ");
		Out.String("marker");
		Out.Ln;
		w.String(anonymodtext^);
		w.Update;
		Files.Register(f); 
		compiler:=CompilerInterface.GetCompilerByName("Fox");
		IF compiler#NIL THEN
			(* call compiler on anonymod to create md5".Obj"*)
			(* TextUtilities.LoadAuto(text,md5string^,format,res); *)
			NEW(text);
			TextUtilities.StrToText(text,10000,anonymodtext^);
			compiler.CompileText(text,"",0,"","",w,diagnostics,error);
			IF error THEN Out.String("compile error ") END;
			
	 	END;	
 	ELSE
 		Out.String("could not create file ");
 	END;
	RETURN md5  (* if md5.Obj exists, it "worked"*)
END Sabotage;

PROCEDURE test*;
VAR
	compiler: CompilerInterface.Compiler;
	anony:Name;
BEGIN
	compiler:=CompilerInterface.GetCompilerByName("Fox");
	anony:=Sabotage(" 
IMPORT Math, XNXLBase, XNXLVoxel, XNXLLifeVox, XNXLTexVox, Random, 
M2:=XNXLM3Space, M3:=XNXLM3Space, XNXLFRep, XNXLRotaVox, XNXLSierp, XNXLHalfSpace;
  
VAR vox: XNXLTexVox.TexVox;
PROCEDURE thisvox*():XNXLBase.Voxel;
BEGIN
	IF vox=NIL THEN NEW(vox,'XNXL.sky2.jpg')  END;
	RETURN vox
END thisvox;

");
END test;

BEGIN
	NEW(hasher)
END XNXLSaboteur.test

SystemTools.Free XNXLSaboteur ~