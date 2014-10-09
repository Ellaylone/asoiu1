Program AirportHelp1;
uses App, Objects, Views, Drivers, Menus;
type
	TAirHelp = object (TApplication)
	end;
var AirHelp: TAirHelp; {экземпляр}
begin
	AirHelp.Init; {конструктор - делает начальные установки}
	AirHelp.Run; {выполнение - обработка событий}
	AirHelp.Done; {деструктор - уничтожение объектов}
end.
