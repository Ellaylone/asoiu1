unit flightWindows;
interface
uses App, Objects, Drivers, Menus, Views;
const
cmNewFlight = 199;
cmFindFlight = 200;
cmNewWin = 201;
WinCounter: Integer = 0;
type
	TAirHelp = object (TApplication)
        procedure InitStatusLine; virtual;
        procedure InitMenuBar; virtual;
        procedure NewWindow; virtual;
        procedure HandleEvent (var Event: TEvent) ; virtual;
//	constructor Init;
end;
type
  PDemoWindow = ^TDemoWindow;
  TDemoWindow = object(TWindow)
  //constructor Init(Bounds: TRect; WinTitle: String;
    //                         WindowNo: Integer);
end;
implementation
procedure TAirHelp.NewWindow;
var
  Window: PDemoWindow;
  R: TRect;
begin
  Inc(WinCounter);
  R.Assign(0, 0, 26, 7);       { установка начального размера и
                                 позиции }
  R.Move(Random(58), Random(16));  { случайное перемещение по
                                     экрану }
  Window := New(PDemoWindow, Init(R, 'Demo Window', WinCounter));
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
           NewItem('~N~ew flight', 'F3', kbF3, cmNewFlight, hcNoContext,
           NewItem('F~i~nd flight', 'F4', kbF3, cmFindFlight, hcNoContext,
           NewLine(
           NewItem('E~x~it', 'Alt-X', kbAltX, cmQuit, hcNoContext,
                                                     { элемент }
           nil))))),          { больше нет элементов }
         nil)              { больше нет подменю }
       )));                { конец полосы }
     end;
end.
