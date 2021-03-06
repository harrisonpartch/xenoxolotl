MODULE WMShapes; (** AUTHOR "staubesv"; PURPOSE "Basic geormetric shapes as visual components"; *)

IMPORT
	Strings, XML, WMRectangles, WMGraphics, WMGraphicUtilities, WMProperties, WMComponents;

TYPE

	Line* = OBJECT(WMComponents.VisualComponent)
	VAR
		color- : WMProperties.ColorProperty;
		colorI : LONGINT;

		isVertical- : WMProperties.BooleanProperty;
		isVerticalI : BOOLEAN;

		PROCEDURE &Init;
		BEGIN
			Init^;
			SetNameAsString(StrLine);
			NEW(color, NIL, StrColor, StrLineColorDescription); properties.Add(color);
			color.Set(WMGraphics.Black); colorI := color.Get();
			NEW(isVertical, NIL, StrIsVertical, StrIsVerticalDescription); properties.Add(isVertical);
			isVertical.Set(FALSE); isVerticalI := isVertical.Get();
		END Init;

		PROCEDURE PropertyChanged(sender, property : ANY);
		BEGIN
			IF (property = color) THEN
				colorI := color.Get();
				Invalidate;
			ELSIF (property = isVertical) THEN
				isVerticalI := isVertical.Get();
				Invalidate;
			ELSE
				PropertyChanged^(sender, property);
			END;
		END PropertyChanged;

		PROCEDURE DrawBackground(canvas : WMGraphics.Canvas);
		VAR rect : WMRectangles.Rectangle; x0, y0, x1, y1 : LONGINT;
		BEGIN
			DrawBackground^(canvas);
			IF (colorI # 0) THEN
				rect := bounds.Get();
				IF isVerticalI THEN
					x0 := (rect.r - rect.l) DIV 2;
					y0 := 0;
					x1 := x0;
					y1 := rect.b - rect.t;
				ELSE
					x0 := 0;
					y0 := (rect.b - rect.t) DIV 2;
					x1 := rect.r - rect.l;
					y1 := y0;
				END;
				canvas.Line(x0, y0, x1, y1, colorI, WMGraphics.ModeSrcOverDst);
			END;
		END DrawBackground;

	END Line;

TYPE

	Rectangle* = OBJECT(WMComponents.VisualComponent)
	VAR
		clBorder- : WMProperties.ColorProperty;
		clBorderI : LONGINT;

		PROCEDURE &Init;
		BEGIN
			Init^;
			SetNameAsString(StrRectangle);
			NEW(clBorder, NIL, StrClBorder, StrClBorderDescription); properties.Add(clBorder);
			clBorder.Set(WMGraphics.Black); clBorderI := clBorder.Get();
		END Init;

		PROCEDURE PropertyChanged(sender, property : ANY);
		BEGIN
			IF (property = clBorder) THEN
				clBorderI := clBorder.Get();
				Invalidate;
			ELSE
				PropertyChanged^(sender, property);
			END;
		END PropertyChanged;

		PROCEDURE DrawBackground(canvas : WMGraphics.Canvas);
		VAR rect : WMRectangles.Rectangle;
		BEGIN
			DrawBackground^(canvas);
			IF (clBorderI # 0) THEN
				rect := GetClientRect();
				WMGraphicUtilities.DrawRect(canvas, rect, clBorderI, WMGraphics.ModeSrcOverDst);
			END;
		END DrawBackground;

	END Rectangle;

TYPE

	Circle* = OBJECT(WMComponents.VisualComponent)
	VAR
		color : WMProperties.ColorProperty;
		colorI : LONGINT;

		PROCEDURE &Init;
		BEGIN
			Init^;
			SetNameAsString(StrCircle);
			NEW(color, NIL, Strings.NewString("Color"), Strings.NewString("Color")); properties.Add(color);
			color.Set(WMGraphics.Black); colorI := color.Get();
		END Init;

		PROCEDURE PropertyChanged(sender, property : ANY);
		BEGIN
			IF (property = color) THEN
				colorI := color.Get();
				Invalidate;
			ELSE
				PropertyChanged^(sender, property);
			END;
		END PropertyChanged;

		PROCEDURE DrawBackground(canvas : WMGraphics.Canvas);
		VAR rect : WMRectangles.Rectangle; radius : LONGINT;
		BEGIN
			DrawBackground^(canvas);
			IF (colorI # 0) THEN
				rect := bounds.Get();
				canvas.SetColor(colorI);
				radius := Strings.Min((rect.r - rect.l) DIV 2, (rect.b - rect.t) DIV 2) - 1;
				WMGraphicUtilities.Circle(canvas, (rect.r - rect.l) DIV 2, (rect.b - rect.t) DIV 2, radius);
			END;
		END DrawBackground;

	END Circle;

TYPE

	Ellipse* = OBJECT(WMComponents.VisualComponent)
	VAR
		color : WMProperties.ColorProperty;
		colorI : LONGINT;

		PROCEDURE &Init;
		BEGIN
			Init^;
			SetNameAsString(StrEllipse);
			NEW(color, NIL, StrColor, StrColorDescription);
			color.Set(WMGraphics.Black); colorI := color.Get();
		END Init;

		PROCEDURE PropertyChanged(sender, property : ANY);
		BEGIN
			IF (property = color) THEN
				colorI := color.Get();
				Invalidate;
			ELSE
				PropertyChanged^(sender, property);
			END;
		END PropertyChanged;

		PROCEDURE DrawBackground(canvas : WMGraphics.Canvas);
		VAR rect : WMRectangles.Rectangle;
		BEGIN
			DrawBackground^(canvas);
			IF (colorI # 0) THEN
				rect := bounds.Get();
				canvas.SetColor(colorI);
				WMGraphicUtilities.Ellipse(canvas, (rect.r - rect.l) DIV 2, (rect.b - rect.t) DIV 2, (rect.r - rect.l) DIV 2 - 1, (rect.b - rect.t) DIV 2 - 1);
			END;
		END DrawBackground;

	END Ellipse;

VAR
	StrLine, StrRectangle, StrCircle, StrEllipse : Strings.String;
	StrClBorder, StrClBorderDescription, StrColor, StrColorDescription, StrLineColorDescription,
	StrIsVertical, StrIsVerticalDescription : Strings.String;

PROCEDURE GenLine*() : XML.Element;
VAR line : Line;
BEGIN
	NEW(line); RETURN line;
END GenLine;

PROCEDURE GenRectangle*() : XML.Element;
VAR rectangle : Rectangle;
BEGIN
	NEW(rectangle); RETURN rectangle;
END GenRectangle;

PROCEDURE GenCircle*() : XML.Element;
VAR circle : Circle;
BEGIN
	NEW(circle); RETURN circle;
END GenCircle;

PROCEDURE GenEllipse*() : XML.Element;
VAR ellipse : Ellipse;
BEGIN
	NEW(ellipse); RETURN ellipse;
END GenEllipse;

PROCEDURE InitStrings;
BEGIN
	StrLine := Strings.NewString("Line");
	StrRectangle := Strings.NewString("StrRectangle");
	StrCircle := Strings.NewString("StrCircle");
	StrEllipse := Strings.NewString("StrEllipse");
	StrClBorder := Strings.NewString("ClBorder");
	StrClBorderDescription := Strings.NewString("Border color");
	StrColor := Strings.NewString("Color");
	StrColorDescription := Strings.NewString("Color");
	StrLineColorDescription := Strings.NewString("Color of line");
	StrIsVertical := Strings.NewString("IsVertical");
	StrIsVerticalDescription := Strings.NewString("Horizontal or vertical line?");
END InitStrings;

BEGIN
	InitStrings;
END WMShapes.

SystemTools.Free WMShapes ~
