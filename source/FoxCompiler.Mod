MODULE Compiler;   (**  AUTHOR "fof & fn"; PURPOSE "Oberon Compiler Command Interface";  **)
(* (c) fof ETH Zürich, 2008 *)

IMPORT
	Basic := FoxBasic, Scanner := FoxScanner, Parser := FoxParser,
	SemanticChecker := FoxSemanticChecker, SyntaxTree := FoxSyntaxTree, Formats := FoxFormats,  D := Debugging,
	Streams, Commands,Diagnostics, Options, Kernel, Printout := FoxPrintout, Backend := FoxBackend,Strings, Global := FoxGlobal,
	ActiveCells := FoxActiveCells, IntermediateCode := FoxIntermediateCode,  IntermediateCodeAssembler := FoxIntermediateCodeAssembler,
	Files, StaticLinker, GenericLinker;

CONST
	(* flags *)
	Print* = 0;
	Silent* = 1;
	Check* = 2;
	TraceError* = 3;
	Info* = 4;
	FindPC* = 5;
	DataFlow*=6;
	Warnings*=7;
	ForceModuleBodies*=8;
	UseDarwinCCalls*=9;	(* use Darwin stack alignment for ext. C procedures *)	(*fld*)
	SingleModule*=10;
	Oberon07*=11;

	DefaultBackend = "AMD";

	TraceAssembling = FALSE;

TYPE
	SectionName = ARRAY 256 OF CHAR; (*! move *)
	MessageString= ARRAY 256 OF CHAR;

	TracingDiagnostics=OBJECT (Diagnostics.Diagnostics)
	VAR diagnostics: Diagnostics.Diagnostics;

		PROCEDURE &InitDiagnostics(diagnostics: Diagnostics.Diagnostics);
		BEGIN
			SELF.diagnostics := diagnostics
		END InitDiagnostics;

		PROCEDURE Error(CONST source: ARRAY OF CHAR; position, errorCode : LONGINT; CONST message : ARRAY OF CHAR);
		BEGIN
			IF diagnostics # NIL THEN
				diagnostics.Error(source,position,errorCode,message);
			END;
			D.Ln;
			D.String(" ---------------------- TRACE for COMPILER ERROR  < ");
			D.String(source);
			IF position # Diagnostics.Invalid THEN D.String("@"); D.Int(position,1) END;
			IF errorCode # Diagnostics.Invalid THEN D.String(" "); D.Int(errorCode,1); END;
			D.String(" "); D.String(message);
			D.String(" > ---------------------- ");
			D.TraceBack
		END Error;

		PROCEDURE Warning*(CONST source : ARRAY OF CHAR; position, errorCode : LONGINT; CONST message : ARRAY OF CHAR);
		BEGIN
			IF diagnostics # NIL THEN
				diagnostics.Warning(source,position,errorCode,message);
			END;
		END Warning;

		PROCEDURE Information*(CONST source : ARRAY OF CHAR; position, errorCode : LONGINT; CONST message : ARRAY OF CHAR);
		BEGIN
			IF diagnostics # NIL THEN
				diagnostics.Information(source,position,errorCode,message);
			END;
		END Information;

	END TracingDiagnostics;

	PROCEDURE GetSymbolFileFormat*(CONST name: ARRAY OF CHAR): Formats.SymbolFileFormat;
	VAR
		procname: ARRAY 256 OF CHAR;
		factory: PROCEDURE (): Formats.SymbolFileFormat;
		symbolFileFormat: Formats.SymbolFileFormat;
	BEGIN
		symbolFileFormat := NIL;
		IF Strings.Length(name) > 0 THEN
			GETPROCEDURE(name,"Get", factory); (* try long name for example -G=OCBinarySymbolFile *)
			IF factory = NIL THEN (* try short name for example -G=Binary *)
				procname := "Fox";
				Strings.Append(procname, name);
				Strings.Append(procname, "SymbolFile");
				GETPROCEDURE(procname,"Get", factory);
			END;
			IF factory # NIL THEN
				symbolFileFormat := factory();
				Assert(symbolFileFormat # NIL,"symbol file factory returned NIL symbol file format");
			END;
		END;
		RETURN symbolFileFormat
	END GetSymbolFileFormat;

	PROCEDURE GetObjectFileFormat*(CONST name: ARRAY OF CHAR): Formats.ObjectFileFormat;
	VAR
		procname: ARRAY 256 OF CHAR;
		factory: PROCEDURE (): Formats.ObjectFileFormat;
		objectFileFormat: Formats.ObjectFileFormat;
	BEGIN
		objectFileFormat := NIL;
		IF Strings.Length(name) > 0 THEN
			GETPROCEDURE(name,"Get", factory); (* try long name for example -G=OCBinaryObjectFile *)
			IF factory = NIL THEN (* try short name for example -G=Binary*)
				procname := "Fox";
				Strings.Append(procname, name);
				Strings.Append(procname, "ObjectFile");
				GETPROCEDURE(procname,"Get", factory);
			END;
			IF factory # NIL THEN
				objectFileFormat := factory();
				Assert(objectFileFormat # NIL,"symbol file factory returned NIL symbol file format");
			END;
		END;
		RETURN objectFileFormat
	END GetObjectFileFormat;



	PROCEDURE GetActiveCellsSpecification(CONST name: ARRAY OF CHAR): ActiveCells.Specification;
	VAR
		procname: ARRAY 256 OF CHAR;
		factory: PROCEDURE (): ActiveCells.Specification;
		specification: ActiveCells.Specification;
	BEGIN
		specification := NIL;
		IF Strings.Length(name) > 0 THEN
			GETPROCEDURE(name,"Get", factory); (* try long name for example -G=OCBinaryObjectFile *)
			IF factory = NIL THEN (* try short name for example -G=Binary*)
				procname := "Fox";
				Strings.Append(procname, name);
				GETPROCEDURE(procname,"Get", factory);
			END;
			IF factory # NIL THEN
				specification := factory();
				ASSERT(specification # NIL);
			END;
		END;
		RETURN specification
	END GetActiveCellsSpecification;

	PROCEDURE Modules*(CONST source: ARRAY OF CHAR; (* source file name, for debugging and better error reports *)
			reader: Streams.Reader; (* reader to read from *)
			position: LONGINT; (* starting position in reader *)
			diagnostics: Diagnostics.Diagnostics; (* error output and status report *)
			flags: SET; (* general flags, special options are handled by components *)
			backend: Backend.Backend; (* backend: code generator *)
			symbolFileFormat: Formats.SymbolFileFormat;
			objectFileFormat: Formats.ObjectFileFormat;
			activeCellsSpecification: ActiveCells.Specification;
			log: Streams.Writer;
			VAR importCache: SyntaxTree.ModuleScope;
			CONST findPC: ARRAY OF CHAR (* locate a source code position providing a binary module offset *)
			): BOOLEAN;
	VAR
		module: SyntaxTree.Module;
		scanner: Scanner.Scanner;
		parser: Parser.Parser;
		checker: SemanticChecker.Checker;
		warnings: SemanticChecker.Warnings;
		printer: Printout.Printer;
		system: Global.System;
		generatedModule: Formats.GeneratedModule;
		name: SyntaxTree.IdentifierString;
		activeCellsBackend: Backend.Backend;
		split: Strings.StringArray;
		sectionOffset: LONGINT;
		traceDiagnostics : TracingDiagnostics;

		PROCEDURE FinalMessage(error: BOOLEAN; CONST msg: ARRAY OF CHAR);
		VAR message,name: ARRAY 256 OF CHAR;
		BEGIN
			message := "";
			IF (module # NIL) & (module.context # SyntaxTree.invalidIdentifier) THEN
				Basic.GetString(module.context,message);
				Strings.Append (message, ".");
			ELSE
				message := "";
			END;
			IF (module # NIL) & (module.name # SyntaxTree.invalidIdentifier) THEN
				Basic.GetString(module.name,name);
				Strings.Append (message, name);
			END;
			Strings.Append (message, msg);
			IF error THEN
				IF diagnostics # NIL THEN
					diagnostics.Error (source, Diagnostics.Invalid, Diagnostics.Invalid, message);
				END;
			ELSE
				IF (log # NIL) & ~(Silent IN flags) & ~(FindPC IN flags) THEN
					log.String("compiling ");
					IF source # "" THEN 	log.String(source); log.String(" => ");	END;
					log.String(message); log.Ln;
				END;
			END;
		END FinalMessage;

		PROCEDURE PrintModule;
		VAR print: Streams.Writer;
		BEGIN
			print := Basic.GetWriter(Basic.GetDebugWriter("Compiler Debug Output"));
			IF Info IN flags THEN
				printer := Printout.NewPrinter(print,Printout.All,Info IN flags);
			ELSE
				printer := Printout.NewPrinter(print,Printout.SourceCode,Info IN flags);
			END;
			print.Ln; printer.Module(module); print.Ln;
			print.Update;
		END PrintModule;


	BEGIN
		IF findPC # "" THEN EXCL(flags, Warnings) END;
		IF TraceError IN flags THEN
			NEW(traceDiagnostics,diagnostics); diagnostics := traceDiagnostics
		END;

		IF backend = NIL THEN
			system := Global.DefaultSystem()
		ELSE
			IF Oberon07 IN flags THEN backend.SetOberon07 END; (* inform the backend about that the Oberon07 mode, it will return the corresponding Sytem object *)
			system := backend.GetSystem();
		END;

		IF (system # NIL) & (activeCellsSpecification # NIL) THEN
			activeCellsSpecification.DefineDevices(system)
		END;
		IF (objectFileFormat # NIL) & (objectFileFormat.ForceModuleBodies()) THEN INCL(flags, ForceModuleBodies) END;

		scanner := Scanner.NewScanner(source,reader,position,diagnostics);
		IF DataFlow IN flags THEN
			Global.NewBuiltin(Global.Connect,"CONNECT",system.globalScope,FALSE);
			Global.NewBuiltin(Global.Receive,"RECEIVE",system.globalScope,FALSE);
			Global.NewBuiltin(Global.Send,"SEND",system.globalScope,FALSE);
			Global.NewBuiltin(Global.Delegate,"DELEGATE",system.globalScope,FALSE);
			Global.NewBuiltin(Global.systemHardwareAddress,"HWADR",system.systemScope,FALSE);
			activeCellsBackend := Backend.GetBackendByName("FoxActiveCellsBackend");
			IF activeCellsBackend = NIL THEN FinalMessage(TRUE,"could not install activeCells backend"); RETURN FALSE END;
		END;
		parser := Parser.NewParser( scanner, diagnostics );
		IF DataFlow IN flags THEN parser.ActiveCellsSupport END;
		REPEAT
			(** first phase: scan and parse **)
			module := parser.Module();
			IF parser.error THEN
				FinalMessage(TRUE," could not be compiled (parser errors).");
				RETURN FALSE;
			END;
			ASSERT(module # NIL);

			IF Check IN flags THEN
				(** second phase: check and resolve symbols **)
				IF (symbolFileFormat # NIL) THEN
					symbolFileFormat.Initialize(diagnostics,system);
				END;
				checker := SemanticChecker.NewChecker(diagnostics,Info IN flags,UseDarwinCCalls IN flags,system,symbolFileFormat,activeCellsSpecification,importCache);
				checker.Module(module);
				IF checker.error THEN
					FinalMessage(TRUE," could not be compiled (checker errors).");
					RETURN FALSE
				ELSIF Warnings IN flags THEN
					warnings := SemanticChecker.NewWarnings(diagnostics);
					warnings.Module(module);
				END;

				IF Print IN flags THEN PrintModule END;

				IF activeCellsSpecification # NIL THEN
					Global.GetSymbolName(module,name);
					activeCellsSpecification.Init(name,diagnostics,log)
				END;

				(** third phase: generate code, can consist of sub-phases (such as intermediate backend / hardware backend) **)
				IF backend # NIL THEN
					backend.Initialize(diagnostics, log, flags, checker, system, activeCellsSpecification);
					IF findPC # "" THEN
						split := Strings.Split(findPC,":");
						IF LEN(split)>1 THEN
							Strings.StrToInt(split[1]^,sectionOffset);
						ELSE
							sectionOffset := 0;
						END;
						backend.FindPC(module, split[0]^,sectionOffset);
						IF backend.error THEN
							FinalMessage(TRUE," could not be compiled (backend errors).");
							RETURN FALSE
						ELSE
							RETURN TRUE
						END;
					END;
					generatedModule := backend.ProcessSyntaxTreeModule(module);
					IF backend.error THEN
						FinalMessage(TRUE, " could not be compiled (backend errors).");
						RETURN FALSE
					END;
				END;


				(** generate symbol file **)
				IF (symbolFileFormat # NIL) & ~symbolFileFormat.Export(module, importCache) THEN
					FinalMessage(TRUE, " could not be compiled (symbol File errors).");
					RETURN FALSE
				END;

				(** generate object file **)
				IF objectFileFormat # NIL THEN
					objectFileFormat.Initialize(diagnostics);
					IF generatedModule = NIL THEN
						FinalMessage(TRUE, " could not write object file (nothing generated).");
						RETURN FALSE
					ELSIF ~objectFileFormat.Export(generatedModule,symbolFileFormat) THEN
						FinalMessage(TRUE, " could not be compiled (object file errors).");
						RETURN FALSE
					END;
				END;

				IF activeCellsSpecification # NIL THEN
					activeCellsBackend.Initialize(diagnostics,log, flags,checker,system,activeCellsSpecification);
					generatedModule := activeCellsBackend.ProcessSyntaxTreeModule(module);
					IF activeCellsBackend.error THEN
						FinalMessage(TRUE, " could not be compiled (activeCells backend errors)");
						RETURN FALSE
					END;
				END;
				FinalMessage(FALSE, " done.");

				IF activeCellsSpecification = NIL THEN (* no activeCells *)
				ELSIF (activeCellsSpecification.types.Length() = 0) & (activeCellsSpecification.instances.Length()=0) THEN (* nothing defined *)
				ELSE
					IF ~AssembleActiveCells(activeCellsSpecification,backend) THEN
						(*activeCellsSpecification.Link(diagnostics,system.codeUnit, system.dataUnit) *)
						FinalMessage(TRUE, " could not assemble"); RETURN FALSE
					ELSIF ~activeCellsSpecification.Emit() THEN
						FinalMessage(TRUE, " could not emit backend specification"); RETURN FALSE;
					END;
				END;
			ELSIF Print IN flags THEN
				PrintModule;
				FinalMessage(FALSE, " done.")
			ELSE
				FinalMessage(FALSE, " done.");
			END;
		UNTIL (SingleModule IN flags) OR ~parser.NextModule();

		RETURN TRUE;
	END Modules;

	PROCEDURE AssembleActiveCells(activeCellsSpecification: ActiveCells.Specification; backend: Backend.Backend): BOOLEAN;
	TYPE
		AssemblerObject= OBJECT
		VAR
			specification: ActiveCells.Specification;
			backend: Backend.Backend;
			diagnostics: Diagnostics.Diagnostics;
			assembler: IntermediateCodeAssembler.Assemblinker;
			objectFileFormat: Formats.ObjectFileFormat;
			flags: SET;
			error: BOOLEAN;
			system: Global.System;

			PROCEDURE &Init(activeCellsSpecification: ActiveCells.Specification; b: Backend.Backend; objectFileFormat: Formats.ObjectFileFormat);
			BEGIN
				error := FALSE;
				SELF.specification := activeCellsSpecification;
				SELF.backend := b;
				SELF.diagnostics := specification.diagnostics;
				SELF.objectFileFormat := objectFileFormat;
				NEW(assembler, specification.diagnostics, backend, ""); (* TODO: pass an optional path as third parameter *)
				IF ~assembler.LoadModule(backend(IntermediateCode.IntermediateBackend).runtimeModuleName, TRUE) THEN
					error := TRUE;
					diagnostics.Error(backend(IntermediateCode.IntermediateBackend).runtimeModuleName,Diagnostics.Invalid, Diagnostics.Invalid, "could not load ir file");
				END;
				IF ~assembler.LoadModule(specification.name,TRUE) THEN
					error := TRUE;
					diagnostics.Error(specification.name,Diagnostics.Invalid, Diagnostics.Invalid, "could not load ir file");
				END;
				backend := assembler.backend;
				system := backend.system;
			END Init;

			PROCEDURE LinkInstance(instance: ActiveCells.Instance): BOOLEAN;
			VAR
				fileName, codeFileName, dataFileName: Files.FileName;
				code, data: StaticLinker.Arrangement; linker: GenericLinker.Linker;
				module: ActiveCells.Module;
				i: LONGINT;
				logFile: Files.File; linkerLog: Files.Writer;
				type: ActiveCells.Type;
				msg: MessageString;
				typeName, instanceName, linkRoot, name: SectionName;
				objectFileExtension: ARRAY 32 OF CHAR;
				instructionMemorySize, dataMemorySize: LONGINT;
				parameter: ActiveCells.Parameter;
				value: SyntaxTree.Value;
				pooledName: Basic.PooledName;
				device: ActiveCells.Device;
				error : BOOLEAN;
			CONST MinimalStackSize=64;
			BEGIN
				error := FALSE;
				type := instance.type;
				type.GetFullName(typeName,NIL);
				instance.GetFullName(instanceName,NIL);
				IF TraceAssembling THEN
					D.String("assembling instance "); D.String(instanceName); D.String(" of type "); D.String(typeName); D.Ln;
				END;

				backend.SetCapabilities(instance.capabilities);
				assembler.MarkReachabilityOfAll(FALSE);
				COPY(typeName, linkRoot);
				Strings.Append(linkRoot,".@BodyStub");
				assembler.MarkAsReachableByName(linkRoot);

				FOR i := 0 TO instance.parameters.Length()-1 DO
					parameter := instance.parameters.GetParameter(i);
					IF parameter.type = 0 THEN (* Boolean *)
						value := SyntaxTree.NewBooleanValue(-1, parameter.boolean); value.SetType(system.booleanType);
					ELSE
						value := SyntaxTree.NewIntegerValue(-1, parameter.integer); value.SetType(system.integerType);
					END;
					Basic.ToPooledName(parameter.name, pooledName);
					assembler.PatchValueInSection(pooledName,value);
				END;

				FOR i := 0 TO type.specification.supportedDevices.Length()-1 DO
					device := type.specification.supportedDevices.GetDevice(i);
					IF instance.type.devices.ByName(device.name) = NIL THEN
						IF assembler.ModuleIsReachable(Basic.MakeString(device.name)) THEN
							msg := "Missing device capability ";
							Strings.Append(msg, device.name);
							Strings.Append(msg," in cell ");
							instance.AppendToMsg(msg);
							diagnostics.Error(specification.name,Diagnostics.Invalid, Diagnostics.Invalid, msg);
							error := TRUE;
						END;
					ELSE
						IF ~assembler.ModuleIsReachable(Basic.MakeString(device.name)) THEN
							msg := "Unused device ";
							Strings.Append(msg, device.name);
							Strings.Append(msg," in cell ");
							instance.AppendToMsg(msg);
							diagnostics.Warning(specification.name,Diagnostics.Invalid,Diagnostics.Invalid,msg);
						END;
					END;
				END;

				IF error THEN RETURN FALSE END;

				objectFileFormat.GetExtension(objectFileExtension);
				assembler.PrearrangeReachableDataSections;
				IF ~assembler.GenerateObjectFileWithName(objectFileFormat, specification.log, {}, NIL, NIL, instanceName) THEN
					diagnostics.Error(specification.name,Diagnostics.Invalid, Diagnostics.Invalid, "could not generate object file");
					RETURN FALSE
				END;

				IF TraceAssembling THEN
					D.String("assembling instance done. "); D.Ln;
				END;


				NEW (code, 0); NEW (data, 0);
				COPY(instanceName, msg); Strings.Append(msg,".log");	logFile := Files.New(msg);
				IF logFile # NIL THEN NEW(linkerLog,logFile,0) ELSE logFile := NIL END;
				NEW (linker, specification.diagnostics, linkerLog, GenericLinker.UseInitCode, code, data);

				linker.SetLinkRoot("" (* linkRoot *)); (* take all initcode sections *)
				StaticLinker.ReadObjectFile(instanceName, "",objectFileExtension,linker);

				(* do linking after having read in all blocks to account for potential constraints *)
				IF ~linker.error THEN linker.Link; END;

				system := backend.GetSystem();

				instructionMemorySize := type.instructionMemorySize;
				dataMemorySize := type.dataMemorySize;

				IF (instructionMemorySize > 0) & (instructionMemorySize < code.SizeInBits() DIV system.codeUnit) THEN
					diagnostics.Error(specification.name,Diagnostics.Invalid, Diagnostics.Invalid, "specified instruction memory size too small");
					error := TRUE;
				END;

				instructionMemorySize := MAX(code.SizeInBits() DIV system.codeUnit, instructionMemorySize);
				dataMemorySize := MAX(data.SizeInBits() DIV system.dataUnit, dataMemorySize);
				instance.SetInstructionMemorySize(instructionMemorySize);
				instance.SetDataMemorySize(dataMemorySize);

				IF (dataMemorySize - data.SizeInBits() DIV system.dataUnit) < MinimalStackSize THEN
					diagnostics.Error(specification.name,Diagnostics.Invalid, Diagnostics.Invalid, "specified data memory size too small");
					error := TRUE;
				END;

				Files.JoinExtension(instanceName,ActiveCells.CodeFileExtension,codeFileName);
				Files.JoinExtension(instanceName,ActiveCells.DataFileExtension,dataFileName);

				IF ~linker.error THEN
					StaticLinker.WriteOutputFile (code, codeFileName, linker, StaticLinker.WriteTRMCodeFile);
					StaticLinker.WriteOutputFile (data, dataFileName, linker, StaticLinker.WriteTRMDataFile);
					IF linkerLog # NIL THEN linkerLog.Update; Files.Register(logFile) END;
					IF specification.log # NIL THEN
						specification.log.String(instanceName);
						specification.log.String(" linked. IM = ");specification.log.Int(instructionMemorySize,1);
						specification.log.String(" (used: "); specification.log.Int(code.SizeInBits() DIV system.codeUnit,1);
						specification.log.String("), DM = "); specification.log.Int(dataMemorySize,1);
						specification.log.String(" (used: "); specification.log.Int(data.SizeInBits() DIV system.dataUnit,1);
						specification.log.String(")");
						specification.log.Ln; specification.log.Update;
					END;
				ELSE
					msg := "could not link ";
					Strings.Append(msg,linkRoot);
					diagnostics.Error("",Diagnostics.Invalid, Diagnostics.Invalid, msg);
				END;
				RETURN ~linker.error & ~error
			END LinkInstance;

		END AssemblerObject;

	VAR obj: AssemblerObject;
	BEGIN
		ActiveCells.FlattenNetwork(activeCellsSpecification);
		NEW(obj,activeCellsSpecification,backend,GetObjectFileFormat("Generic"));
		IF obj.error THEN RETURN FALSE END;
		RETURN activeCellsSpecification.ForEachInstanceDo(obj.LinkInstance);
	END AssembleActiveCells;

	PROCEDURE GetOptions*(input: Streams.Reader; error:Streams.Writer; diagnostics: Diagnostics.Diagnostics; VAR flags: SET;
		VAR backend: Backend.Backend;
		VAR symbolFile: Formats.SymbolFileFormat;
		VAR objectFile: Formats.ObjectFileFormat;
		VAR activeCellsSpecification: ActiveCells.Specification;
		VAR findPC: ARRAY OF CHAR
		): BOOLEAN;
	VAR options: Options.Options;  name: ARRAY 256 OF CHAR; result: BOOLEAN; position: LONGINT;
		parsed: BOOLEAN;

		PROCEDURE Error(CONST error: ARRAY OF CHAR);
		BEGIN
			IF diagnostics # NIL THEN
				diagnostics.Error("",Diagnostics.Invalid,Diagnostics.Invalid,error);
			END;
		END Error;

	BEGIN
		result := TRUE;
		NEW(options);
		options.Add("p","print",Options.Flag);
		options.Add(0X,"silent",Options.Flag);
		options.Add("c","check",Options.Flag);
		options.Add("e","traceError",Options.Flag);
		options.Add("I","interface",Options.Flag);
		options.Add("i","info",Options.Flag);
		options.Add(0X,"oberon07",Options.Flag);
		options.Add("b","backend",Options.String);
		options.Add("f","findPC",Options.String);
		options.Add(0X,"singleModule",Options.Flag);
		options.Add(0X, "symbolFile", Options.String);
		options.Add(0X, "objectFile", Options.String);
		options.Add("d","activeCells", Options.Flag);
		options.Add("w","warnings", Options.Flag);
		options.Add(0X,"darwinHost", Options.Flag);
		options.Add(0X,"activeCellsSpecification", Options.String);

		position := input.Pos();
		parsed := options.Parse(input,NIL);

		IF options.GetString("b", name) THEN
			IF name = "" THEN backend := NIL
			ELSE
				backend := Backend.GetBackendByName(name);
				IF (backend = NIL)  THEN
					Error("backend could not be installed"); result := FALSE;
				END;
			END;
		ELSE backend := Backend.GetBackendByName(DefaultBackend);
			IF backend = NIL THEN Error("default backend could not be installed"); result := FALSE END;
		END;

		IF options.GetString("objectFile",name) THEN
			IF name = "" THEN objectFile := NIL
			ELSE
				objectFile := GetObjectFileFormat(name);
				IF objectFile = NIL THEN Error("object file format could not be installed"); result := FALSE END;
			END;
		ELSIF backend # NIL THEN
			objectFile := backend.DefaultObjectFileFormat();
		END;

		IF options.GetString("symbolFile",name) THEN
			IF name = "" THEN symbolFile := NIL
			ELSE
				symbolFile := GetSymbolFileFormat(name);
				IF symbolFile = NIL THEN Error("symbol file format could not be installed"); result := FALSE END;
			END;
		ELSIF backend # NIL THEN
			symbolFile := backend.DefaultSymbolFileFormat();
			IF (symbolFile = NIL) & (objectFile # NIL) THEN
				symbolFile := objectFile.DefaultSymbolFileFormat();
			END;
		ELSIF objectFile # NIL THEN
			symbolFile := objectFile.DefaultSymbolFileFormat();
		END;

		IF options.GetString("activeCellsSpecification",name) THEN
			activeCellsSpecification := GetActiveCellsSpecification(name);
		END;
		IF options.GetFlag("activeCells") & (activeCellsSpecification = NIL) THEN
			NEW(activeCellsSpecification,"",diagnostics,NIL);
		END;

		IF backend # NIL THEN backend.DefineOptions (options); INCL(flags,Check); END;
		IF symbolFile # NIL THEN symbolFile.DefineOptions(options); INCL(flags,Check) END;
		IF objectFile # NIL THEN objectFile.DefineOptions(options); INCL(flags,Check) END;

		IF result & ~parsed THEN
			options.Clear;
			input.SetPos(position);
			result := options.Parse(input,error)
		END;

		IF result THEN
			IF options.GetFlag("print") THEN INCL(flags, Print) END;
			IF options.GetFlag("silent") THEN INCL(flags, Silent) END;
			IF options.GetFlag("check") THEN INCL(flags, Check) END;
			IF options.GetFlag("traceError") THEN INCL(flags, TraceError) END;
			IF options.GetFlag("info") THEN INCL(flags,Info) END;
			IF options.GetString("findPC",findPC) THEN INCL(flags,FindPC) END;
			IF options.GetFlag("warnings") THEN INCL(flags, Warnings) END;
			IF options.GetFlag("darwinHost") THEN INCL(flags,UseDarwinCCalls) END;	(*fld*)
			IF options.GetFlag("singleModule") THEN INCL(flags,SingleModule) END;
			IF options.GetFlag("oberon07") THEN INCL(flags, Oberon07) END;
			IF backend # NIL THEN backend.GetOptions (options) END;
			IF symbolFile # NIL THEN symbolFile.GetOptions(options) END;
			IF objectFile # NIL THEN objectFile.GetOptions(options) END;
			IF activeCellsSpecification # NIL THEN INCL(flags, DataFlow) END;
		END;
		RETURN result
	END GetOptions;

	(*
		Get next available name from stream ignoring comments and end of comment brackets
		Returns TRUE on success, returns FALSE on end of stream, on error or if "~" or ";" encountered.
		Scanner based on Peek() feature of stream. Necessary to make it restartable.
	*)
	PROCEDURE GetString*(r: Streams.Reader; VAR string: ARRAY OF CHAR): BOOLEAN;
	VAR ch: CHAR; i: LONGINT; done,error: BOOLEAN;

		PROCEDURE Next;
		BEGIN r.Char(ch); ch := r.Peek();
		END Next;

		PROCEDURE Append(ch: CHAR);
		BEGIN string[i] := ch; INC(i)
		END Append;

		PROCEDURE SkipWhitespace;
		BEGIN WHILE (ch <= " ") & (ch # 0X) DO Next END;
		END SkipWhitespace;

		PROCEDURE Comment;
		VAR done: BOOLEAN;
		BEGIN
			done := FALSE;
			Next;
			REPEAT
				CASE ch OF
				|"(": Next; IF ch = "*" THEN Comment; SkipWhitespace END;
				|"*": Next; IF ch =")" THEN Next; done:= TRUE END;
				| 0X: done := TRUE;
				ELSE Next;
				END;
			UNTIL done;
		END Comment;

		PROCEDURE String(delimiter: CHAR);
		VAR done: BOOLEAN;
		BEGIN
			done := FALSE; Next;
			REPEAT
				IF ch = delimiter THEN done := TRUE; Next;
				ELSIF ch = 0X THEN done := TRUE; error := TRUE;
				ELSE Append(ch); Next;
				END;
			UNTIL done OR (i=LEN(string)-1);
		END String;

	BEGIN
		i := 0; done := FALSE;
		ch := r.Peek(); (* restart scanning *)
		SkipWhitespace;
		REPEAT
			CASE ch OF
				"(": Next; IF ch = "*" THEN Comment ; SkipWhitespace ELSE Append(ch) END;
				| "*": Next; IF ch = ")" THEN Next; SkipWhitespace ELSE Append(ch) END;
				| '"', "'": done := TRUE; IF i = 0 THEN String(ch) END;
				| 0X .. ' ', '~', ';': done := TRUE;
			ELSE
				Append(ch);
				Next;
			END;
		UNTIL done OR (i = LEN(string)-1);
		string[i] := 0X;
		RETURN (i > 0) & done & ~error;
	END GetString;

	PROCEDURE Compile*(context : Commands.Context);
	VAR
		filename: Files.FileName;
		error: BOOLEAN;
		diagnostics: Diagnostics.StreamDiagnostics;
		time: LONGINT; reader: Streams.Reader;
		flags: SET;
		backend: Backend.Backend;
		importCache: SyntaxTree.ModuleScope;
		symbolFileFormat: Formats.SymbolFileFormat;
		objectFile: Formats.ObjectFileFormat;
		activeCellsSpecification: ActiveCells.Specification;
		findPC: SectionName;
	BEGIN
		error := FALSE;

		NEW(diagnostics, context.error);
		IF GetOptions(context.arg,context.error,diagnostics,flags,backend,symbolFileFormat,objectFile,activeCellsSpecification,findPC) THEN

			time := Kernel.GetTicks();
			WHILE GetString(context.arg,filename) & ~error DO
				reader := Basic.GetFileReader(filename);
				IF reader = NIL THEN
					diagnostics.Error (filename, Diagnostics.Invalid, Diagnostics.Invalid, "failed to open"); error := TRUE;
				ELSE
					error := ~Modules(filename, reader, 0, diagnostics, flags, backend, symbolFileFormat,objectFile,activeCellsSpecification, context.out, importCache,findPC);
				END;
				context.out.Update;
				context.error.Update;
			END;
			IF Silent IN flags THEN
				time := Kernel.GetTicks()-time;
				context.out.Ln; context.out.String("compiler elapsed ms"); context.out.Int(time,10);
			END;
		END;
	END Compile;

	PROCEDURE Assemble*(context: Commands.Context);
	VAR
		input: Streams.Reader;
		diagnostics: Diagnostics.StreamDiagnostics;
		flags: SET;
		defaultBackend: Backend.Backend;
		objectFileFormat: Formats.ObjectFileFormat;
		filename, dummyString, name, targetFile: Files.FileName;
		assemblinker: IntermediateCodeAssembler.Assemblinker;
		error, result, parsed: BOOLEAN;
		options:Options.Options;
		position: LONGINT;

		PROCEDURE Error(CONST error: ARRAY OF CHAR);
		BEGIN
			IF diagnostics # NIL THEN
				diagnostics.Error("",Diagnostics.Invalid,Diagnostics.Invalid,error);
			END;
		END Error;

	BEGIN
		input := context.arg;
		NEW(diagnostics, context.out);
		result := TRUE;
		NEW(options);
		options.Add("b","backend",Options.String);
		options.Add(0X, "objectFile", Options.String);
		options.Add(0X, "targetFile", Options.String);

		position := input.Pos();
		parsed := options.Parse(input,NIL);

		IF options.GetString("b", name) THEN
			IF name = "" THEN defaultBackend := NIL
			ELSE
				defaultBackend := Backend.GetBackendByName(name);
				IF (defaultBackend = NIL)  THEN
					Error("backend could not be installed"); result := FALSE;
				END;
			END;
		ELSE defaultBackend := Backend.GetBackendByName(DefaultBackend);
			IF defaultBackend = NIL THEN Error("default backend could not be installed"); result := FALSE END;
		END;

		IF options.GetString("objectFile",name) THEN
			IF name = "" THEN objectFileFormat := NIL
			ELSE
				objectFileFormat := GetObjectFileFormat(name);
				IF objectFileFormat = NIL THEN Error("object file format could not be installed"); result := FALSE END;
			END;
		ELSIF defaultBackend # NIL THEN
			objectFileFormat := defaultBackend.DefaultObjectFileFormat();
		END;
		IF defaultBackend # NIL THEN defaultBackend.DefineOptions (options); INCL(flags,Check); END;
		IF objectFileFormat # NIL THEN objectFileFormat.DefineOptions(options); INCL(flags,Check) END;

		IF result & ~parsed THEN
			options.Clear;
			input.SetPos(position);
			result := options.Parse(input,context.error)
		END;

		IF result THEN
			IF defaultBackend # NIL THEN defaultBackend.GetOptions (options) END;
			IF objectFileFormat # NIL THEN objectFileFormat.GetOptions(options) END;
			IF ~options.GetString("targetFile",targetFile) THEN targetFile := "" END;
		END;

		error := ~result;
		IF targetFile # "" THEN
			NEW(assemblinker, diagnostics, defaultBackend, "");
		END;
		WHILE GetString(input,filename) & ~error DO
			IF targetFile = "" THEN NEW(assemblinker, diagnostics, defaultBackend, "") 	END;
			IF assemblinker.LoadModule(filename, FALSE) THEN
				assemblinker.MarkReachabilityOfAll(TRUE);
				IF (targetFile = "") & assemblinker.GenerateObjectFile(objectFileFormat, context.out, flags, NIL, NIL) THEN
					diagnostics.Information(filename, Diagnostics.Invalid, Diagnostics.Invalid, "done.")
				ELSIF targetFile # "" THEN
					diagnostics.Information(filename,  Diagnostics.Invalid, Diagnostics.Invalid, "loaded.")
				ELSE
					error := TRUE
				END
			ELSE
				error := TRUE
			END
		END;
		IF ~error & (targetFile # "") THEN
			assemblinker.PrearrangeReachableDataSections;
			IF 	assemblinker.GenerateObjectFileWithName(objectFileFormat, context.out, flags, NIL, NIL,targetFile)
			THEN
				diagnostics.Information(targetFile, Diagnostics.Invalid, Diagnostics.Invalid, "generated.")
			ELSE error := FALSE
			END;
		END;
	END Assemble;

	PROCEDURE CompileReader*(context: Commands.Context; reader: Streams.Reader);
	VAR
		filename: ARRAY 256 OF CHAR;
		error: BOOLEAN;
		diagnostics: Diagnostics.StreamDiagnostics;
		time: LONGINT;
		flags: SET;
		backend: Backend.Backend;
		importCache: SyntaxTree.ModuleScope;
		symbolFileFormat: Formats.SymbolFileFormat;
		objectFile: Formats.ObjectFileFormat;
		activeCellsSpecification: ActiveCells.Specification;
		findPC: SectionName;
	BEGIN
		error := FALSE;
		NEW(diagnostics, context.error);
		IF GetOptions(context.arg,context.error,diagnostics,flags,backend,symbolFileFormat,objectFile,activeCellsSpecification,findPC) THEN

			time := Kernel.GetTicks();
			IF reader = NIL THEN
				diagnostics.Error (filename, Diagnostics.Invalid, Diagnostics.Invalid, "failed to open"); error := TRUE;
			ELSE
				error := ~Modules(filename, reader, 0, diagnostics, flags, backend, symbolFileFormat,objectFile,activeCellsSpecification, context.out, importCache,findPC);
			END;
			context.out.Update;
		END;
	END CompileReader;

	PROCEDURE Assert(b: BOOLEAN; CONST reason: ARRAY OF CHAR);
	BEGIN
		ASSERT(b);
	END Assert;

END Compiler.
