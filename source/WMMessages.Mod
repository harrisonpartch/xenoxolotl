MODULE WMMessages; (** AUTHOR "TF"; PURPOSE "Support for messages and events"; *)

IMPORT
	Strings, KernelLog, Objects, Kernel, Locks;

CONST
	MsgQSize = 128;
	(** Predefined Messages *)
	MsgPointer* = 0; MsgKey* = 2; MsgClose* = 3; MsgStyleChanged* = 4;
	MsgFocus* = 5; MsgExt* = 6; MsgDrag* = 7;
	MsgInvokeEvent* = 8;
	MsgResized* = 9;
	MsgSetLanguage* = 10;

	MsgSubPointerMove* = 0; MsgSubPointerDown* = 1; MsgSubPointerUp* = 2; MsgSubPointerLeave* = 3;
	MsgSubFocusGot* = 0; MsgSubFocusLost* = 1; MsgSubMasterFocusGot* = 2; MsgSubMasterFocusLost* = 3;
	MsgDragOver* = 0; MsgDragDropped* = 1;

	(** Gather statistics about added/discarded messages? *)
	Statistics* = TRUE;
	MsgTypeMax* = 10;

TYPE
	(** Generic Component Command *)
	CompCommand* = PROCEDURE  { DELEGATE } (sender, par : ANY);
	String* = Strings.String;

	(** Generic message structure *)
	Message* = RECORD
		originator*, (** the originator if # NIL passes information about the view that directly or indirectely lead to the msg *)
		sender* : ANY; (** is the sender component. If the message is originated form a component *)
		token* : AsyncToken;
		event* : CompCommand;
		msgType*, msgSubType* : LONGINT; (** generic message type *)
		x*, y*, z*, dx*, dy*, dz* : LONGINT; (** in keyboard messages : ucs value in x, keysym in y *)
		flags* : SET; (** in pointer messages : keys in flags *)
		ext* : ANY; (** extended message *)
	END;

	MessageExtension* = POINTER TO RECORD END;

	(** AsyncToken can be used to synchronize asynchronous method invocation *)
	AsyncToken* = OBJECT
	VAR
		ready : BOOLEAN;
		result* : ANY;

		(** Reset is called in case the token was recycled *)
		PROCEDURE Reset*;
		BEGIN {EXCLUSIVE}
			ready := FALSE;
		END Reset;

		(** wait until the result is completed *)
		PROCEDURE AwaitCompletion*;
		BEGIN {EXCLUSIVE}
			AWAIT(ready)
		END AwaitCompletion;

		(** Return if the result is completed *)
		PROCEDURE IsCompleted*():BOOLEAN;
		BEGIN {EXCLUSIVE}
			RETURN ready
		END IsCompleted;

		(** Called by the asynchronous process to indicate the result is available *)
		PROCEDURE Completed*;
		BEGIN {EXCLUSIVE}
			ready := TRUE
		END Completed;
	END AsyncToken;


	(** Message handler that can be called from the sequencer *)
	MessageHandler* = PROCEDURE {DELEGATE} (VAR msg : Message);

	(** The TrapHandler must return TRUE if the process should restart. Otherwise the process is stopped *)
	TrapHandler* = PROCEDURE {DELEGATE} () : BOOLEAN;

	(** Message sequencer *)
	MsgSequencer* = OBJECT
	VAR
		head, num : LONGINT;
		msgQ : ARRAY MsgQSize OF Message;
		alive, continue, hadOverflow , waiting: BOOLEAN;
		msg : Message;
		handler : MessageHandler;
		originator : ANY;
		me : ANY; (* Thread for caller identification *)
		lock- : Locks.RWLock;
		th, traphandler : TrapHandler;
		name* : String;
		trapOnOverflow* : BOOLEAN;

		PROCEDURE &New*(handler : MessageHandler);
		BEGIN
			SELF.handler := handler;
			NEW(lock);
			head := 0; num := 0;
			originator := NIL; me := NIL; th := NIL; traphandler := NIL;
			name := NIL;
			alive := FALSE; continue := TRUE; hadOverflow := FALSE; trapOnOverflow := FALSE;
		END New;

		(** Add a trap handler for this process. This handler only decides whether to continue or to abort the process.
			If continued, the lock will be reset *)
		PROCEDURE SetTrapHandler*(th : TrapHandler);
		BEGIN {EXCLUSIVE}
			traphandler := th
		END SetTrapHandler;

		(** Return true if called from (this) sequencer *)
		PROCEDURE IsCallFromSequencer*() : BOOLEAN;
		BEGIN
			RETURN Objects.ActiveObject() = me
		END IsCallFromSequencer;

		(** RETURN the originator (view) of the message that lead directly or indirectly to this request.
			Returns NIL if the call is not from the sequencer  *)
		PROCEDURE GetOriginator*() : ANY;
		BEGIN
			IF Objects.ActiveObject() = me THEN RETURN originator
			ELSE RETURN NIL
			END
		END GetOriginator;

		(** Add a message to a queue. Discards the message if the queue is full *)
		PROCEDURE Add*(VAR msg : Message) : BOOLEAN;
		VAR i : LONGINT;
		BEGIN {EXCLUSIVE}
			IF (msg.msgType = MsgPointer) & (num > 0) THEN  (* reduce pointer moves in buffer *)
				i := num - 1;
				WHILE i >= 0 DO
					IF (msgQ[(head + i) MOD MsgQSize].msgType = MsgPointer) & (msg.msgSubType = MsgSubPointerMove) & (msgQ[(head + i) MOD MsgQSize].flags = msg.flags) THEN
						msgQ[(head + i) MOD MsgQSize].x := msg.x;
						msgQ[(head + i) MOD MsgQSize].y := msg.y;
						msgQ[(head + i) MOD MsgQSize].z := msg.z;
						RETURN TRUE
					END;
					DEC(i)
				END
			END;
			IF num < MsgQSize THEN
				IF Statistics THEN
					INC(messagesAdded);
					IF (msg.msgType >= 0) & (msg.msgType < MsgTypeMax) THEN
						INC(messagesAddedByType[msg.msgType]);
					END;
				END;
				msgQ[(head + num) MOD MsgQSize] := msg; INC(num);
				RETURN TRUE
			ELSE
				IF Statistics THEN INC(messagesDiscarded); END;
				IF ~hadOverflow THEN
					IF name # NIL THEN KernelLog.String(name^); KernelLog.String(" : ") END;
					IF trapOnOverflow THEN HALT(123456) END;
					(*KernelLog.String("Message queue overflow "); KernelLog.Ln; *)
					hadOverflow := TRUE;
				END;
				RETURN FALSE
			END
		END Add;

		PROCEDURE Handle(VAR msg : Message) : BOOLEAN;
		BEGIN
			(* if asynchronous call --> synchronize *)
			IF ~IsCallFromSequencer() THEN RETURN Add(msg)
			ELSE
				IF msg.msgType = MsgInvokeEvent THEN (* MsgInvokeEvent *)
					IF msg.event # NIL THEN
						msg.event(msg.sender, msg.ext);
						IF msg.token # NIL THEN msg.token.Completed END
					END
				ELSE handler(msg) (* Generic message *)
				END;
				(* clear references *)
				msg.originator := NIL;
				msg.sender := NIL;
				msg.ext := NIL;
				originator := NIL;
				RETURN TRUE
			END
		END Handle;

		(* put event into message queue *)
		PROCEDURE ScheduleEvent*(event : CompCommand; sender, par : ANY);
		VAR invokeMsg : Message;
		BEGIN
			invokeMsg.msgType := MsgInvokeEvent;
			invokeMsg.sender := sender; invokeMsg.ext := par;
			invokeMsg.event := event;
			IF ~Handle(invokeMsg) THEN END
		END ScheduleEvent;

		(** Stop the message sequencer. Must be called if the queue is no longer needed *)
		PROCEDURE Stop*;
		BEGIN {EXCLUSIVE}
			alive := FALSE
		END Stop;

		PROCEDURE WaitFree*;
		BEGIN {EXCLUSIVE}
			AWAIT (waiting & (num=0) OR ~alive)
		END WaitFree;

		(* Remove a message from the queue. Block if no message is available but awake if queue is terminated by call to Stop *)
		(* return if alive *)
		PROCEDURE Get(VAR msg : Message) : BOOLEAN;
		BEGIN {EXCLUSIVE}
			IF hadOverflow THEN KernelLog.String(" - Recovered"); hadOverflow := FALSE END;
			waiting := TRUE;
			AWAIT((num # 0) OR ~alive);
			waiting := FALSE;
			IF ~alive THEN RETURN FALSE END;
			msg := msgQ[head];
			(* clear references from the queue *)
			msgQ[head].originator := NIL;
			msgQ[head].sender := NIL;
			msgQ[head].ext := NIL;

			head := (head + 1)  MOD MsgQSize;
			DEC(num);
			originator := msg.originator;
			RETURN TRUE
		END Get;

	BEGIN {ACTIVE, SAFE}
		(* trap occured *)
		IF alive THEN
			th := traphandler; KernelLog.String("WMMessages: [TRAP]"); KernelLog.Ln;
			IF th # NIL THEN continue := th() ELSE continue := FALSE END;
			IF continue THEN lock.Reset ELSE RETURN END;
		END;
		alive := TRUE; me := Objects.ActiveObject();
		(* Message processing loop *)
		WHILE Get(msg) DO
			lock.AcquireWrite;
			(* Check alive again for the case that the sequencer has been stopped just after Get(msg) returned
			but before the lock could be acquired (WMComponents.FormWindow holds that lock when calling Sequencer.Stop) *)
			IF alive THEN
				IF ~Handle(msg) THEN KernelLog.String("WMMessages: A msg was not handled... "); KernelLog.Ln; END;
			END;
			lock.ReleaseWrite
		END
	END MsgSequencer;

VAR
	 tokenCache : Kernel.FinalizedCollection;
	 ttoken : AsyncToken;

	 (* Statistics *)
	 messagesAddedByType- : ARRAY MsgTypeMax OF LONGINT;
	 messagesAdded- : LONGINT;
	 messagesDiscarded- : LONGINT;

PROCEDURE TokenEnumerator(obj: ANY; VAR cont: BOOLEAN);
BEGIN
	cont := FALSE; ttoken := obj(AsyncToken)
END TokenEnumerator;

(** Get an AsyncToken from the pool. Create a new one if the pool is empty *)
PROCEDURE GetAsyncToken*() : AsyncToken;
BEGIN {EXCLUSIVE}
	ttoken := NIL;
	tokenCache.Enumerate(TokenEnumerator);
	IF ttoken = NIL THEN NEW(ttoken)
	ELSE tokenCache.Remove(ttoken)
	END;
	ttoken.Reset;
	RETURN ttoken
END GetAsyncToken;

(** Recycle an AsyncToken. Must be unused. (is only used to disburden the garbage collector) *)
PROCEDURE RecycleAsyncToken*(t : AsyncToken);
BEGIN
	(* only recycle the token if the result is complete *)
	IF t.IsCompleted() THEN tokenCache.Add(t, NIL) END;
END RecycleAsyncToken;

BEGIN
	NEW(tokenCache)
END WMMessages.
