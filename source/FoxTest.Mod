MODULE FoxTest;	(** AUTHOR "fof"; PURPOSE "Fox tester"; *)
(* (c) fof ETH Zürich, 2008 *)

IMPORT Basic := FoxBasic, TestSuite, Diagnostics, Streams, Compiler, Commands, Shell, Options, Backend := FoxBackend, SyntaxTree := FoxSyntaxTree, Formats := FoxFormats, ActiveCells := FoxActiveCells;

TYPE
	Command = ARRAY 256 OF CHAR;
	SectionName = ARRAY 256 OF CHAR;

	Tester = OBJECT (TestSuite.Tester)
	VAR
		log: Streams.Writer;
		verbose, execute: BOOLEAN;
		flags: SET;
		backend: Backend.Backend;
		symbolFile: Formats.SymbolFileFormat;
		objectFile: Formats.ObjectFileFormat;
		command: Command;

		PROCEDURE &InitTester (log: Streams.Writer; diagnostics: Diagnostics.Diagnostics; verbose, execute: BOOLEAN; CONST command: Command; flags: SET;
			backend: Backend. Backend; symbolFile: Formats.SymbolFileFormat; objectFile: Formats.ObjectFileFormat);
		BEGIN Init (diagnostics); SELF.log := log; SELF.verbose := verbose; SELF.execute := execute; SELF.command := command;
			SELF.flags := flags; SELF.backend := backend; SELF.symbolFile := symbolFile; SELF.objectFile := objectFile;
		END InitTester;

		PROCEDURE Handle (r: Streams.Reader; position: LONGINT; CONST name: ARRAY OF CHAR): INTEGER;
		VAR result: INTEGER; msg: ARRAY 128 OF CHAR; res: LONGINT; importCache: SyntaxTree.ModuleScope; diagnostics: Diagnostics.Diagnostics;
		BEGIN
			result := TestSuite.Failure;
			IF verbose THEN log.String ("testing: "); log.String (name); log.Ln; log.Update; diagnostics := SELF.diagnostics ELSE diagnostics := NIL END;
			importCache := NIL;
			IF Compiler.Modules (name, r, position, diagnostics, flags,backend, symbolFile,objectFile,NIL,NIL, importCache,"") THEN
				IF command # "" THEN
					Commands.Call (command, {Commands.Wait}, res, msg);
					IF res = Commands.Ok THEN
						result := TestSuite.Positive;
					ELSE
						IF (res < 3500) & (res >= 3400) (* Loader error *) THEN
							result := TestSuite.Failure;
						ELSE
							result := TestSuite.Negative;
						END;
						IF verbose THEN
							log.String (msg); log.Ln;
						END;
					END
				ELSE
					result := TestSuite.Positive;
				END;
			ELSIF ~execute THEN
				result := TestSuite.Negative;
			END;
		FINALLY
			RETURN result;
		END Handle;

	END Tester;

	PROCEDURE DriveTest (context: Commands.Context);
	VAR
		diagnostics: Diagnostics.StreamDiagnostics; tester: Tester; writer: Streams.Writer; command: Command;
		report: TestSuite.StreamReport; options: Options.Options;
		optionsString: ARRAY 256 OF CHAR; arg: Streams.StringReader; flags: SET; verbose, execute: BOOLEAN; backend: Backend.Backend;
		symbolFile: Formats.SymbolFileFormat;
		objectFile: Formats.ObjectFileFormat;
		activeCellsSpecification: ActiveCells.Specification;
		findPC: SectionName;
	BEGIN
		IF (context.caller # NIL) & (context.caller IS Shell.Shell) THEN
			writer := context.out
		ELSE
			writer := Basic.GetDebugWriter("Oberon Compiler Test Results")
		END;
		NEW(options);
		options.Add("o","options",Options.String);
		options.Add("v","verbose",Options.Flag);
		options.Add("e","execute",Options.Flag);
		options.Add("c","command",Options.String);
		NEW (diagnostics, writer);
		command := "";
		IF options.Parse(context.arg,context.error) THEN
			IF options.GetString("o",optionsString) THEN
				NEW(arg,256);
				arg.Set(optionsString);
				ASSERT (Compiler.GetOptions(arg, context.error, diagnostics, flags, backend,symbolFile,objectFile,activeCellsSpecification, findPC));
			END;
			IF options.GetString ("c", command) THEN END;
		END;
		verbose := options.GetFlag("verbose");
		execute := options.GetFlag("execute");
		NEW (tester, writer, diagnostics, verbose, execute, command, flags, backend,symbolFile,objectFile);
		NEW (report, writer);
		TestSuite.Drive (context, tester);
		tester.Print (report);
		writer.Update;
	END DriveTest;

	PROCEDURE Compile* (context: Commands.Context);
	BEGIN DriveTest (context);
	END Compile;

END FoxTest.

SystemTools.Free FoxTest TestSuite~

FoxTest.Compile --options="-PC" Oberon.Compilation.Test  ~  Verbose testing mode
FoxTest.Compile --options="-PC" Oberon.Compilation.Test Oberon.Compilation.tmp ~ Regression testing mode

FoxTest.Execute --options="-PC -G=AMD64" Oberon.Execution.Test  ~  Verbose testing mode
FoxTest.Execute --options="-PC -G=AMD64" Oberon.Execution.Test Oberon.Execution.tmp ~ Regression testing mode 