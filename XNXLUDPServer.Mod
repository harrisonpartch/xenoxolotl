MODULE XNXLUDPServer; (** AUTHOR "SAGE"; PURPOSE "UDP Chat Server" *)

IMPORT
	Base := XNXLUDPBase, UDP, IP, XNXL,
	Dates, Strings, Modules, Kernel, Events, Out:=KernelLog;

CONST
	branchInit				= 0;
	branchPacketReceive	= 1;
	branchVersionCheck	= 2;
	branchAuthentication	= 3;
	branchPacketHandle	= 4;
	branchEnd				= 5;
	branchTerminated		= 6;

	moduleName = "UDPChatServer";

	(* Event classification as in Events.XML *)
	EventClass = 3; (* UDP Chat *)
	EventSubclass = 3; (* UDP Chat Server *)

TYPE

	String = Strings.String;

	Instance = OBJECT
	VAR
		s: UDP.Socket;
		dt: Dates.DateTime;
		running, terminated: BOOLEAN;
		ip: IP.Adr;
		branch, command, seqNum, messageType: INTEGER;
		uin, receiverUin, port, len, res, receiveBufOffset: LONGINT;
		user: Base.User;
		users: Base.Users;
		clients: Base.List;
		client, receiver: Base.Client;
		sendBuf: Base.Buffer;
		receiveBuf, password, shortName, fullName, eMail, message, textCode: String;
		str1, str2: ARRAY 256 OF CHAR;
		ACKReq: Base.ACKRec;
		xtimer: Kernel.Timer;
		
	PROCEDURE &New *(udp: UDP.Socket);
	BEGIN
		s := udp
	END New;

	PROCEDURE Destroy;
	BEGIN
		running := FALSE;
		s.Close;
		BEGIN {EXCLUSIVE}
			AWAIT (terminated)
		END;
	END Destroy;

	PROCEDURE FindClient (clients: Base.List;
		uin: LONGINT;
		VAR client: Base.Client): BOOLEAN;
	VAR
		i: LONGINT;
		p: ANY;
	BEGIN
		i := 0;
		WHILE i < clients.GetCount () DO
			p := clients.GetItem (i);
			client := p (Base.Client);
			IF uin = client.uin THEN
				RETURN TRUE;
			END;
			INC (i);
		END;
		RETURN FALSE;
	END FindClient;

	PROCEDURE Server_ReceiveMessage (client, receiver: Base.Client; 
		 message: String; sendBuf: Base.Buffer; s: UDP.Socket);
	VAR
		string: String;
		res, len: LONGINT;
	BEGIN {EXCLUSIVE}
		Base.ServerPacketInit (Base.RECEIVE_MESSAGE, sendBuf);
		len := LEN (message^);
		sendBuf.Add (message^, 0, len, TRUE, res);
		string := sendBuf.GetString ();
		s.Send (receiver.ip, receiver.port, string^, 0, sendBuf.GetLength (), res);
	END Server_ReceiveMessage;

	PROCEDURE MulticastMessage (clients: Base.List;
		client: Base.Client; dt: Dates.DateTime; messageType: INTEGER; message: String;
		sendBuf: Base.Buffer; s: UDP.Socket);
	VAR
		i: LONGINT;
		p: ANY;
		receiver: Base.Client;
	BEGIN
		i := 0;
		WHILE i < clients.GetCount () DO
			p := clients.GetItem (i);
			receiver := p (Base.Client);
			(*IF client.uin # receiver.uin THEN*)

				Server_ReceiveMessage (client, receiver, message, sendBuf, s);

			(*END;*)
			INC (i);
		END;
	END MulticastMessage;

	BEGIN {ACTIVE}
		branch := branchInit;
		NEW(xtimer);	
		REPEAT
			CASE branch OF
			| branchInit:
				NEW (receiveBuf, Base.MaxUDPDataLen);
				NEW (sendBuf, 0);
				NEW (clients);
				NEW (client);
				NEW (users);
				running := TRUE;
				terminated := FALSE;
				branch := branchPacketReceive;
			| branchPacketReceive:
				s.Receive (receiveBuf^, 0, Base.MaxUDPDataLen, 1, ip, port, len, res); 
				IF (res = UDP.Ok) (*& (len > 0)*) THEN	
					receiveBufOffset := 0;
					Out.Char('*');
					branch := branchAuthentication;
				END;
			| branchAuthentication:
				command := Base.BufGetInt (receiveBuf, receiveBufOffset);
				uin := Base.BufGetLInt (receiveBuf, receiveBufOffset);		
				IF FindClient (clients, uin, client) THEN	
					branch := branchPacketHandle;
				ELSE
					NEW (client);
					client.ip := ip;
					client.port := port;
					client.uin := uin;
					Kernel.SetTimer (client.keepAliveTimer, Base.clientKeepAliveAwait);
					clients.Add (client);
					Out.String("client added");
					branch := branchPacketHandle;	
				END;			
			| branchPacketHandle:
				message := Base.BufGetString (receiveBuf, receiveBufOffset);
				MulticastMessage (clients, client, dt, messageType, message, sendBuf, s);	
				branch := branchPacketReceive;
			| branchEnd:
				Out.String("branchEnd:");			

				BEGIN {EXCLUSIVE}
					terminated := TRUE
				END;
				branch := branchTerminated;
			ELSE
			END;
		UNTIL branch = branchTerminated;
	END Instance;

VAR
	instance: Instance;

PROCEDURE Log (type, code : SHORTINT; msg: ARRAY OF CHAR; showOnKernelLog : BOOLEAN);
VAR message : Events.Message;
BEGIN
	COPY(msg, message);
	Events.AddEvent(moduleName, type, EventClass, EventSubclass, code, message, showOnKernelLog);
END Log;

PROCEDURE Start* ;
VAR
	s: UDP.Socket;
	res: LONGINT;
	str: ARRAY 256 OF CHAR;
BEGIN
	IF instance = NIL THEN
		NEW (s, Base.serverPort, res); 
		Out.Int(res,0);
		IF res = UDP.Ok THEN
			NEW (instance, s);
			Strings.IntToStr (Base.serverPort, str);
			Strings.Concat ("server started on port: ", str, str);
			Log (Events.Information, 0, str, TRUE);
		ELSE
			Log (Events.Error, 0, "server NOT started!", TRUE);
		END;
	END;
END Start;

PROCEDURE Stop*;
BEGIN
	Cleanup;
END Stop;

(** Termination handler. *)
PROCEDURE Cleanup;
BEGIN
	IF instance # NIL THEN

		instance.Destroy;

	END;
END Cleanup;

BEGIN
	Modules.InstallTermHandler (Cleanup);
END XNXLUDPServer.
