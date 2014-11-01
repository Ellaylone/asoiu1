Program AirportHelp1;
uses App, Objects, Views, Drivers, Menus;
const
cmListFlights = 199;
cmNewFlight = 200;
cmFindFlight = 201;
cmNewWin = 202;
WinCounter: Integer = 0;
ListWindow: integer = 0;
AddWindow: integer = 0;
SearchWindow: integer = 0;
type
	TAirHelp = object (TApplication)
        procedure InitStatusLine; virtual;
        procedure InitMenuBar; virtual;
        procedure NewWindow; virtual;
        procedure ListFlightsWindow; virtual;
        procedure HandleEvent (var Event: TEvent) ; virtual;
//	constructor Init;
end;
        type
  PInterior = ^TInterior;
  TInterior = object(TView)
    constructor Init(var Bounds: TRect);
    procedure Draw; virtual;
  end;
  type
  PFlightWindow = ^TFlightWindow;
  TFlightWindow = object(TWindow)
  constructor Init(Bounds: TRect; WinTitle: String; WindowNo: Integer);
end;
  type
        PFlight = ^TFlight;
	TFlight = record
		Id, Price: integer;
		FromPoint, ToPoint, Date, Time: String;
		Next: PFlight;
	end;
        var AirHelp: TAirHelp;
  data: file of PFlight;
  flights, first: PFlight;
  LineCount: integer;
//  TDrawBuffer = array[0MaxViewWidth-1] of Word;
  procedure writeFlight();
begin
     // connect with other flights
     new(flights);
     flights^.Id := 1;
     flights^.Price := 10;
     flights^.Date := '01.01.1990';
     flights^.FromPoint := 'kurgan';
     flights^.ToPoint := 'tomsk';
     flights^.Time := '18:00';
     flights^.Next := nil;
     Assign(data, 'data');
     reset(data);
     write(data, flights);
     CloseFile(data);
end;
procedure readFlight();
begin
     Assign(data, 'data');
     reset(data);
     LineCount := 0;
     while not eof(data) do
           begin
             Read(data, flights);
             LineCount := LineCount + 1;
           end;
      writeln(flights^.Id, flights^.Price, flights^.Date);
     CloseFile(data);
end;
procedure findFlight();
begin
     // идти по порядку
     if flights^.Date = '01.01.1990' then begin
        writeln(flights^.Date);
     end;
end;
procedure TAirHelp.NewWindow;
var
  Window: PFlightWindow;
  R: TRect;
begin
  Inc(WinCounter);
  R.Assign(0, 0, 26, 7);       { установка начального размера и
                                 позиции }
  R.Move(Random(58), Random(16));  { случайное перемещение по
                                     экрану }
  Window := New(PFlightWindow, Init(R, 'Demo Window', WinCounter));
  // Window.Insert('asd')
  DeskTop^.Insert(Window);     { вывести окно на панель экрана }
end;
procedure TAirHelp.ListFlightsWindow;
var
  Window: PFlightWindow;
  R: TRect;
begin
  Inc(WinCounter);
  ListWindow := WinCounter;
  R.Assign(1, 1, 80, 25);       { установка начального размера и
                                 позиции }
  Window := New(PFlightWindow, Init(R, 'Flights', WinCounter));
  // Window.Insert('asd')
  DeskTop^.Insert(Window);     { вывести окно на панель экрана }
end;

procedure TAirHelp.HandleEvent(var Event: TEvent);
begin
  TApplication.HandleEvent(Event);    { действует как предок }
  if Event.What = evCommand then
  begin
    case Event.Command of     { но откликается на дополнительные
                                команды }
      cmNewWin: NewWindow;    { определяет действие для команды
                                cmNewWin }
    else
      Exit;
    end;
    ClearEvent(Event);        { очищает событие после обработки }
  end;
end;
procedure TAirHelp.InitStatusLine;
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
procedure TAirHelp.InitMenuBar;
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
constructor TInterior.Init(var Bounds: TRect);
begin
  TView.Init(Bounds);
  GrowMode := gfGrowHiX + gfGrowHiY;
end;
procedure TInterior.Draw;
var
  Color: Byte;
  Y: Integer;
  B: TDrawBuffer;
  ColWidth, LastColWidth: integer;
begin
  Color := GetColor(1);
  flights := first;
  Y := 0;
  ColWidth := Size.X div 6;
  LastColWidth := Size.X - (ColWidth * 5);
  MoveChar(B, ' ', Color, Size.X);
  MoveStr(B, Copy('Id', 1, ColWidth), Color);
    WriteLine(0, Y, ColWidth, 1, B);
    MoveStr(B, Copy('|From', 1, ColWidth), Color);
    WriteLine(ColWidth, Y, ColWidth, 1, B);
        MoveStr(B, Copy('|Dest', 1, ColWidth), Color);
    WriteLine(ColWidth * 2, Y, ColWidth, 1, B);
        MoveStr(B, Copy('|Date', 1, ColWidth), Color);
    WriteLine(ColWidth * 3, Y, ColWidth, 1, B);
        MoveStr(B, Copy('|Time', 1, ColWidth), Color);
    WriteLine(ColWidth * 4, Y, ColWidth, 1, B);
        MoveStr(B, Copy('|Price', 1, ColWidth), Color);
    WriteLine(ColWidth * 5, Y, LastColWidth, 1, B);
  for Y := 1 to Size.Y - 1 do
  begin
    MoveChar(B, ' ', Color, Size.X); { заполняет строку пробелами }
//    MoveStr(B, Copy('', 1, Size.X), Color);
    WriteLine(0, Y, Size.X, 1, B);
{    if (Y < LineCount) and (flights <> nil) then
      MoveStr(B, Copy(flights^.FromPoint, 1, Size.X), Color);
    WriteLine(0, Y, Size.X, 1, B);
    //flights := flights^.Next;
    }

  end;
end;
constructor TFlightWindow.Init(Bounds: TRect; WinTitle: String;
                             WindowNo: Integer);
var
  S: string[3];
  Interior: PInterior;
begin
  writeln(WindowNo);
  Str(WindowNo, S);        { устанавливает номер окна в заголовке }
  TWindow.Init(Bounds, WinTitle + ' ' + S, wnNoNumber);
  GetClipRect(Bounds);
  Bounds.Grow(-1,-1);     { интерьер помещается внутри рамки окна }
  Interior := New(PInterior, Init(Bounds));
  Insert(Interior);    { добавляет интерьер к окну }
end;

begin
        //readFlight();
	AirHelp.Init();
        AirHelp.NewWindow();
                AirHelp.ListFlightsWindow();
	AirHelp.Run;
	AirHelp.Done;
//       writeFlight();
//        readFlight();
        //writeln();
        //findFlight();
  //      readln();
end.
