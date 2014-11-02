Program FlightLIst;
uses App, Objects, Views, Drivers, Menus, Dialogs;
const
	cmListFlights = 199;
	cmAddDialog = 200;
	cmSearchDialog = 201;
	cmAddFlight = 202;
	cmFindFlight = 203;
	cmNewWin = 204;
type
	TMyAppl = object (TApplication)
	procedure InitStatusLine; virtual;
	procedure InitMenuBar; virtual;
	procedure ListFlights; virtual;
	procedure NewFlight; virtual;
	procedure FindFlight; virtual;
	procedure AddFlightAction; virtual;
        procedure FindFlightAction; virtual;
	procedure HandleEvent(var Event: TEvent); virtual;
	constructor Init;
end;
type
	PListWindow = ^TListWindow;
	TListWindow = object (TWindow)
	constructor Init(Bounds: TRect; WinTitle: String; WinNo: Integer);
end;
type
	PAddDialog = ^TAddDialog;
	TAddDialog = object (TDialog)
	constructor Init (var Bounds: TRect; WinTitle: String);
end;
type
	PFindDialog = ^TFindDialog;
	TFindDialog = object (TDialog)
	constructor Init (var Bounds: TRect; WinTitle: String);
end;
type
        PFlight = ^TFlight;
	TFlight = record
		Id, Price: integer;
		FromPoint, ToPoint, Date, Time: String;
		Next:PFlight;
end;
type
        FindData = record
                Field: Word;
                Value: string[128];
        end;
type
        AddData = record
                Date: string[128];
                Time: string[128];
                Price: string[128];
                Start: string[128];
                Dest: string[128];
        end;
var
        FlightAppl: TMyAppl;
        data: file of PFlight;
        flights, first: PFlight;
        Find: FindData;
        Add: AddData;
procedure TMyAppl.InitStatusLine;
	var R: TRect;                 { хранит границы строки статуса }
	begin
		GetExtent(R);               { устанавливает R в координаты всего}
																{ экрана }
		R.A.Y := R.B.Y - 1;         { передвигает вершину на 1 строку }
																{ выше нижней }
		StatusLine := New(PStatusLine, Init(R,   { создает строку }
																						 { статуса }
			NewStatusDef(0, $FFFF,  { устанавливает диапазон контекстного }
															{ Help }
				NewStatusKey('~Alt-X~ Exit', kbAltX, cmQuit, { определяет элемент }
	//      NewStatusKey('~F4~ New', kbF4, cmAddDialog,
				NewStatusKey('~Alt-F3~ Close', kbAltF3, cmClose,  { другой }
				nil)),           { больше нет клавиш }
			nil)               { больше нет определений }
		));
	end;
procedure TMyAppl.InitMenuBar;
	var R: TRect;
	begin
		GetExtent(R);
		R.B.Y := R.A.Y + 1;
		MenuBar := New(PMenuBar, Init(R, NewMenu( { создать полосу с
																								 меню }
			 NewSubMenu('~F~lights', hcNoContext, NewMenu(    { определить
																											 меню }
				NewItem('List(refresh) flights', 'F3', kbF3, cmListFlights, hcNoContext,
				NewItem('New flight', 'F4', kbF4, cmAddDialog, hcNoContext,
				NewItem('Find flight', 'F5', kbF5, cmSearchDialog, hcNoContext,
				NewLine(
				NewItem('E~x~it', 'Alt-X', kbAltX, cmQuit, hcNoContext,
																									 { элемент }
				nil)))))),          { больше нет элементов }
			nil)              { больше нет подменю }
		)));                { конец полосы }
	end;
constructor TMyAppl.Init;
	begin
		inherited Init; {вызов конструктора предка для установки
		 стандартной прикладной программы}
	end;
constructor TListWindow.Init (Bounds: TRect; WinTitle: String; WinNo: Integer);
	var
	Scroll: PScroller; HSB, VSB: PScrollBar;
	begin
		TWindow.Init (Bounds,WinTitle, WinNo); {вызов конструктора предка}
		VSB := StandardScrollBar (sbVertical); {вертикаль. полоса скроллинга}
		HSB := StandardScrollBar(sbHorizontal); {горизонт. полоса скроллинга}
		GetExtent(Bounds); {Bonds - в границы окна}
		Bounds.Grow(-1,-1); {уменьшить на 1 со всех сторон}
		Scroll := New(PScroller, Init (Bounds, HSB, VSB)); {создание скроллера}
		Insert (Scroll); {вставка в окно}
	end;
constructor TAddDialog.Init (var Bounds: TRect; WinTitle: String);
var
        R: TRect; B: PView;
        FieldWidth: integer;
begin
inherited Init (Bounds,WinTitle); {вызов конструктора предка}
FieldWidth := (Bounds.B.X - Bounds.A.X) div 2 - 3;

R.Assign(3,2,FieldWidth,3); {координаты строки ввода}
B:=New(PInputLine,Init(R,128)); {создание строки ввода}
Insert(B); {вставка строки ввода}
R.Assign(3,1,FieldWidth,2); {координаты метки}
Insert(New(PLabel,Init(R,'Date',B))); {создание и вставка метки}

R.Assign(3,5,FieldWidth,6); {координаты строки ввода}
B:=New(PInputLine,Init(R,128)); {создание строки ввода}
Insert(B); {вставка строки ввода}
R.Assign(3,4,FieldWidth,5); {координаты метки}
Insert(New(PLabel,Init(R,'Time',B))); {создание и вставка метки}

R.Assign(3,8,FieldWidth,9); {координаты строки ввода}
B:=New(PInputLine,Init(R,128)); {создание строки ввода}
Insert(B); {вставка строки ввода}
R.Assign(3,7,FieldWidth,8); {координаты метки}
Insert(New(PLabel,Init(R,'Price',B))); {создание и вставка метки}

R.Assign(FieldWidth + 5,2,FieldWidth * 2 + 2,3); {координаты строки ввода}
B:=New(PInputLine,Init(R,128)); {создание строки ввода}
Insert(B); {вставка строки ввода}
R.Assign(FieldWidth + 5,1,FieldWidth * 2 + 2,2); {координаты метки}
Insert(New(PLabel,Init(R,'Start',B))); {создание и вставка метки}

R.Assign(FieldWidth + 5,5,FieldWidth * 2 + 2,6); {координаты строки ввода}
B:=New(PInputLine,Init(R,128)); {создание строки ввода}
Insert(B); {вставка строки ввода}
R.Assign(FieldWidth + 5,4,FieldWidth * 2 + 2,5); {координаты метки}
Insert(New(PLabel,Init(R,'Destination',B))); {создание и вставка метки}

R.Assign(15,10,25,12); {координаты командной кнопки}
 {создание и вставка кнопки}
Insert(New (PButton, Init (R, '~A~dd Flight', cmAddFlight, bfDefault)));

end;
constructor TFindDialog.Init (var Bounds: TRect; WinTitle: String);
var R: TRect; B: PView;
begin
inherited Init (Bounds,WinTitle); {вызов конструктора предка}
R.Assign(3,3,30,9); {координаты кластера кнопок}
B:= New (PRadioButtons, Init (R, {создание кластера кнопок}
 NewSItem ('Id',
 NewSItem ('Starting location',
 NewSItem ('Destination',
 NewSItem ('Date',
 NewSItem ('Time',
 NewSItem ('Price',
 Nil))))))));
Insert(B); {вставка кластера кнопок}
R.Assign(3,1,10,2); {координаты метки}
Insert(New(PLabel,Init(R,'Field',B))); {создание и вставка метки}
R.Assign(3,10,30,11); {координаты строки ввода}
B:=New(PInputLine,Init(R,128)); {создание строки ввода}
Insert(B); {вставка строки ввода}
R.Assign(8,12,26,14); {координаты командной кнопки}
 {создание и вставка кнопки}
Insert(New (PButton, Init (R, '~F~ind', cmFindFlight, bfDefault)));

end;

procedure TMyAppl.ListFlights;
var
		FlightList: PListWindow;
		R:TRect;
	begin
  		R.Assign(1, 1, 80, 25);
		FlightList:=New(PListWindow, Init (R, 'Flight List', WnNoNumber)); {создание
		окна:}
		DeskTop^.Insert(FlightList); {вставка в панель экрана}
end;
procedure TMyAppl.NewFlight;
	var
		Dialog: PAddDialog;
		R: TRect;
                Control: Word;
	begin
		R.Assign(0, 0, 40, 13);
		R.Move(Random(39), Random(10));
		Dialog := New(PAddDialog, Init(R, 'Add Flight'));
		Dialog^.SetData(Add);
                Control := DeskTop^.ExecView(Dialog);
                if Control <> cmCancel then Dialog^.GetData(Add);
                AddFlightAction();
	end;
procedure TMyAppl.FindFlight;
	var
		Dialog: PFindDialog;
		R: TRect;
                Control: Word;
	begin
		R.Assign(0, 0, 33, 15);
		R.Move(Random(39), Random(10));
		Dialog := New(PFindDialog, Init(R, 'Find Flight'));
                Dialog^.SetData(Find);
                Control := DeskTop^.ExecView(Dialog);
                if Control <> cmCancel then Dialog^.GetData(Find);
                FindFlightAction();
	end;
procedure TMyAppl.AddFlightAction;
begin
     //new(flights);
     //flights^.Id := 1;
     //flights^.Price := 10;
     //flights^.Date := '01.01.1990';
     //flights^.FromPoint := 'kurgan';
     //flights^.ToPoint := 'tomsk';
     //flights^.Time := '18:00';
     //flights^.Next := nil;
     //Assign(data, 'data');
     //reset(data);
     //write(data, flights);
     //CloseFile(data);
end;
procedure TMyAppl.FindFlightAction;
begin

end;

procedure TMyAppl.HandleEvent(var Event: TEvent);
	begin
		TApplication.HandleEvent(Event);
		if Event.What = evCommand then
		begin
			case Event.Command of
				cmListFlights: ListFlights;
				cmAddDialog: NewFlight;
				cmSearchDialog: FindFlight;
                                cmAddFlight: AddFlightAction;
                                cmFindFlight: FindFlightAction;
			else
				Exit;
			end;
			ClearEvent(Event);
		end;
	end;
	begin
		FlightAppl.Init();
		FlightAppl.Run;
		FlightAppl.Done;
	end.
