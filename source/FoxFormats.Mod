MODULE FoxFormats;

IMPORT SyntaxTree := FoxSyntaxTree, Global := FoxGlobal, Streams, Diagnostics, Options;

CONST
	NoFindPC*=MAX(LONGINT);

TYPE
	SectionName= ARRAY 256 OF CHAR;

	(* container for generated code (intermediate code - binary code) *)
	GeneratedModule*=OBJECT
		VAR
			(* input for (intermediate) code generation *)
			module-: SyntaxTree.Module;
			system-: Global.System;
			findPC-: LONGINT;
			moduleName-: SectionName; (* genasm *)

		PROCEDURE SetFindPC*(findPC: LONGINT);
		BEGIN SELF.findPC := findPC
		END SetFindPC;

		PROCEDURE & Init*(module: SyntaxTree.Module; system: Global.System);
		BEGIN SELF.module := module; SELF.system := system; findPC := NoFindPC
		END Init;

		PROCEDURE SetModuleName*(CONST moduleName: ARRAY OF CHAR);
		BEGIN COPY(moduleName, SELF.moduleName)
		END SetModuleName;

		PROCEDURE SetSystem*(system: Global.System);
		BEGIN SELF.system := system
		END SetSystem;

		PROCEDURE Dump*(w: Streams.Writer);
		BEGIN
			w.String(".module "); w.String(moduleName); w.Ln;
			w.Ln;
		END Dump;

	END GeneratedModule;

	(* symbol file import / export for different implementations *)
	SymbolFileFormat*=OBJECT
		VAR diagnostics-:  Diagnostics.Diagnostics; system-: Global.System;

		PROCEDURE &Init*;
		BEGIN diagnostics := NIL; system := NIL;
		END Init;

		PROCEDURE Initialize*(diagnostics: Diagnostics.Diagnostics; system: Global.System);
		BEGIN SELF.diagnostics := diagnostics; SELF.system := system;
		END Initialize;

		PROCEDURE Export*(module: SyntaxTree.Module; importCache: SyntaxTree.ModuleScope): BOOLEAN;
		END Export;

		PROCEDURE Import*(CONST name: ARRAY OF CHAR; importCache: SyntaxTree.ModuleScope): SyntaxTree.Module;
		END Import;

		PROCEDURE DefineOptions*(options: Options.Options);
		BEGIN
		END DefineOptions;

		PROCEDURE GetOptions*(options: Options.Options);
		BEGIN
		END GetOptions;

		PROCEDURE GetExtension*(VAR ext: ARRAY OF CHAR);
		BEGIN HALT(100); (* abstract *)
		END GetExtension;

	END SymbolFileFormat;

	(* object file export for different implementations *)
	ObjectFileFormat*= OBJECT
		VAR diagnostics-: Diagnostics.Diagnostics;

		PROCEDURE &Init*;
		BEGIN diagnostics := NIL
		END Init;

		PROCEDURE Initialize*(diagnostics: Diagnostics.Diagnostics);
		BEGIN SELF.diagnostics := diagnostics
		END Initialize;

		PROCEDURE Export*(module: GeneratedModule; symbolFileFormat: SymbolFileFormat): BOOLEAN;
		BEGIN RETURN FALSE
		END Export;

		PROCEDURE DefineOptions*(options: Options.Options);
		BEGIN
		END DefineOptions;

		PROCEDURE GetOptions*(options: Options.Options);
		BEGIN
		END GetOptions;

		PROCEDURE DefaultSymbolFileFormat*(): SymbolFileFormat;
		BEGIN RETURN NIL
		END DefaultSymbolFileFormat;

		PROCEDURE ForceModuleBodies*(): BOOLEAN;
		BEGIN RETURN FALSE
		END ForceModuleBodies;

		PROCEDURE GetExtension*(VAR ext: ARRAY OF CHAR);
		BEGIN HALT(100); (* abstract *)
		END GetExtension;

	END ObjectFileFormat;

END FoxFormats.