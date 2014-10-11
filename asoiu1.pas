Program AirportHelp1;
uses App, Objects, Views, Drivers, Menus;
type
	TAirHelp = object (TApplication)
	constructor Init;
end;

constructor TAirHelp.Init;
var Window: PWindow; R:TRect;
begin
	inherited Init; {вызов конструктора предка для установки
	стандартной прикладной программы}
	R.Assign(5,3,25,10); {координаты окна}
	Window:=New(PWindow, Init (R, 'MyWindow', WnNoNumber)); {создание
	окна:}
	DeskTop^.Insert(Window); {вставка в панель экрана}
end;

var AirHelp: TAirHelp;
begin
	AirHelp.Init();
	AirHelp.Run;
	AirHelp.Done;
end.
