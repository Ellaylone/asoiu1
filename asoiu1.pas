Program AirportHelp1;
uses App, Objects, Views, Drivers, Menus, flightWindows;
type
  PInterior = ^TInterior;
  TInterior = object(TView)
    constructor Init(var Bounds: TRect);
    procedure Draw; virtual;
  end;


//constructor TAirHelp.Init;
//var Window: PWindow; R:TRect;
//begin
//	inherited Init; {вызов конструктора предка для установки
//	стандартной прикладной программы}
  //      GetExtent(R);
    //    R.B.Y := R.B.Y - 2;
//	R.Assign(1,1,80,25); {координаты окна}
//	Window:=New(PWindow, Init (R, 'Flight List', WnNoNumber)); {создание
//	окна:}
//	DeskTop^.Insert(Window); {вставка в панель экрана}
//end;

constructor TInterior.Init(var Bounds: TRect);
begin
  TView.Init(Bounds);
  GrowMode := gfGrowHiX + gfGrowHiY;
end;

procedure TInterior.Draw;
begin
  TView.Draw;
  // WriteStr(4, 2, 'Hello, World!');
  // TView.WriteStr('hello world!', 'asd');
  // write('asdasd');
end;
{constructor TDemoWindow.Init(Bounds: TRect; WinTitle: String;
                             WindowNo: Integer);
var
  S: string[3];
  Interior: PInterior;
begin
  Str(WindowNo, S);        { устанавливает номер окна в заголовке }
  TWindow.Init(Bounds, WinTitle + ' ' + S, wnNoNumber);
  GetClipRect(Bounds);
  Bounds.Grow(-1,-1);     { интерьер помещается внутри рамки окна }
  Interior := New(PInterior, Init(Bounds));
  Insert(Interior);    { добавляет интерьер к окну }
end;}
type
        PFlight = ^TFlight;
	TFlight = record
		Id, Price: integer;
		FromPoint, ToPoint, Date, Time: String;
		Next: PFlight;
	end;

var AirHelp: TAirHelp;
  data: file of PFlight;
  test: PFlight;
          procedure writeFlight();
begin
     new(test);
     test^.Id := 1;
     test^.Price := 10;
     test^.Date := '01.01.1990';
     test^.FromPoint := 'kurgan';
     test^.ToPoint := 'tomsk';
     test^.Time := '18:00';
     test^.Next := nil;
     Assign(data, 'data');
     reset(data);
     write(data, test);
     CloseFile(data);
end;
procedure readFlight();
begin
     Assign(data, 'data');
     reset(data);
     while not eof(data) do
           begin
             Read(data, test);
           end;
     writeln(test^.Id, test^.Price, test^.Date);
     CloseFile(data);
end;
procedure findFlight();
begin
     // идти по порядку
     if test^.Date = '01.01.1990' then begin
        writeln(test^.Date);
     end;
end;
begin
//	AirHelp.Init();
  //      AirHelp.NewWindow();
//	AirHelp.Run;
//	AirHelp.Done;
        writeFlight();
        readFlight();
        writeln();
        findFlight();
        readln();
end.
