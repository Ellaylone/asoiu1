Program FlightLIst;
uses App, Objects, Views, Drivers, Menus, Dialogs;
const
	cmListFlights = 199;
	cmNewFlight = 200;
	cmFindFlight = 201;
	cmNewWin = 202;
type
	TMyAppl = object (TApplication)
	procedure InitStatusLine; virtual;
	procedure InitMenuBar; virtual;
	procedure ListFlights; virtual;
	procedure NewFlight; virtual;
	procedure FindFlight; virtual;
	procedure HandleEvent(var Event: TEvent); virtual;
	constructor Init;
end;
type
	PListWindow = ^TListWindow;
	TListWindow = object (TWindow)
	constructor Init(Bounds: TRect; WinTitle: String; WinNo: Integer);
end;
var FlightAppl: TMyAppl;
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
	//      NewStatusKey('~F4~ New', kbF4, cmNewFlight,
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
				NewItem('New flight', 'F4', kbF4, cmNewFlight, hcNoContext,
				NewItem('Find flight', 'F5', kbF5, cmFindFlight, hcNoContext,
				NewLine(
				NewItem('E~x~it', 'Alt-X', kbAltX, cmQuit, hcNoContext,
																									 { элемент }
				nil)))))),          { больше нет элементов }
			nil)              { больше нет подменю }
		)));                { конец полосы }
	end;
constructor TMyAppl.Init;
	var
		FlightList: PListWindow;
		R:TRect;
	begin
		inherited Init; {вызов конструктора предка для установки
		 стандартной прикладной программы}
		R.Assign(5,3,25,10); {координаты окна}
		FlightList:=New(PListWindow, Init (R, 'Flight List', WnNoNumber)); {создание
		окна:}
		DeskTop^.Insert(FlightList); {вставка в панель экрана}
		// DeskTop^.Insert(Window); {вставка в панель экрана}
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
procedure TMyAppl.ListFlights;
	var
		Dialog: PDialog;
		R: TRect;
	begin
		R.Assign(0, 0, 40, 13);
		R.Move(Random(39), Random(10));
		Dialog := New(PDialog, Init(R, 'Add Flight'));
		DeskTop^.Insert(Dialog);
	end;
procedure TMyAppl.NewFlight;
	var
		Dialog: PDialog;
		R: TRect;
	begin
		R.Assign(0, 0, 40, 13);
		R.Move(Random(39), Random(10));
		Dialog := New(PDialog, Init(R, 'Add Flight'));
		DeskTop^.Insert(Dialog);
	end;
procedure TMyAppl.FindFlight;
	var
		Dialog: PDialog;
		R: TRect;
	begin
		R.Assign(0, 0, 40, 13);
		R.Move(Random(39), Random(10));
		Dialog := New(PDialog, Init(R, 'Find Flight'));
		DeskTop^.Insert(Dialog);
	end;

procedure TMyAppl.HandleEvent(var Event: TEvent);
	begin
		TApplication.HandleEvent(Event);
		if Event.What = evCommand then
		begin
			case Event.Command of
				cmListFlights: ListFlights;
				cmNewFlight: NewFlight;
				cmFindFlight: FindFlight;
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
