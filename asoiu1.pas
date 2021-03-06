Program FlightLIst;
uses App, Objects, Views, Drivers, Menus, Dialogs, MsgBox, TextView;
const
	cmListFlights = 199;
	cmAddDialog = 200;
	cmSearchDialog = 201;
type
	TMyAppl = object (TApplication)
	FlightCollection: PCollection;
	procedure InitStatusLine; virtual;
	procedure InitMenuBar; virtual;
	procedure ListFlights; virtual;
	procedure NewFlight; virtual;
	procedure FindFlight; virtual;
    procedure PrintFlights; virtual;
    procedure SearchFlights; virtual;
	procedure HandleEvent(var Event: TEvent); virtual;
	constructor Init;
        destructor Done; virtual;
end;
type
	PListWindow = ^TListWindow;
	TListWindow = object (TWindow)
          Term: PTerminal;
          Buff: Text;
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
	TFlight = object(TObject)
		Id, Price, FromPoint, ToPoint, Date, Time: PString;
		constructor Init(i, p, fp, tp, d, t: String);
                procedure Load(S: TDosStream);
                procedure Store(S: TDosStream);
		destructor Done; virtual;
	end;
constructor TFlight.Init(i, p, fp, tp, d, t: String);
begin
	Id := NewStr(i);
	Price := NewStr(p);
	FromPoint := NewStr(fp);
	ToPoint := NewStr(tp);
	Date := NewStr(d);
	Time := NewStr(t);
end;
procedure TFlight.Load(S: TDosStream);
begin
     Id := S.ReadStr;
     Price := S.ReadStr;
     FromPoint := S.ReadStr;
     ToPoint := S.ReadStr;
     Date := S.ReadStr;
     Time := S.ReadStr;
end;
procedure TFlight.Store(S: TDosStream);
begin
     S.WriteStr(Id);
     S.WriteStr(Price);
     S.WriteStr(FromPoint);
     S.WriteStr(ToPoint);
     S.WriteStr(Date);
     S.WriteStr(Time);
end;
destructor TFlight.Done;
begin
	dispose(Id);
	dispose(Price);
	dispose(FromPoint);
	dispose(ToPoint);
	dispose(Date);
	dispose(Time);
end;
Const
     RFlight: TStreamRec = (
              ObjType: 2000;
              VmtLink: Ofs(TypeOf(TFlight)^);
              Load: @TFlight.Load;
              Store: @TFlight.Store);
type
        FindData = record
                Field: integer;
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
        Find: FindData;
        Add: AddData;
        SaveFile: TDosStream;
procedure TMyAppl.InitStatusLine;
	var R: TRect;
	begin
		GetExtent(R);

		R.A.Y := R.B.Y - 1;

		StatusLine := New(PStatusLine, Init(R,

			NewStatusDef(0, $FFFF,

				NewStatusKey('~Alt-X~ Exit', kbAltX, cmQuit,

				NewStatusKey('~Alt-F3~ Close', kbAltF3, cmClose,
				nil)),
			nil)
		));
	end;
procedure TMyAppl.InitMenuBar;
	var R: TRect;
	begin
		GetExtent(R);
		R.B.Y := R.A.Y + 1;
		MenuBar := New(PMenuBar, Init(R, NewMenu(

			 NewSubMenu('~F~lights', hcNoContext, NewMenu(

				NewItem('List(refresh) flights', 'F3', kbF3, cmListFlights, hcNoContext,
				NewItem('New flight', 'F4', kbF4, cmAddDialog, hcNoContext,
				NewItem('Find flight', 'F5', kbF5, cmSearchDialog, hcNoContext,
				NewLine(
				NewItem('E~x~it', 'Alt-X', kbAltX, cmQuit, hcNoContext,

				nil)))))),
			nil)
		)));
	end;
constructor TMyAppl.Init;
	begin
		inherited Init;
                RegisterType(RFlight);
		MessageBox ('Start', nil, mfOkButton);
                SaveFile.Init('Flight.res', stOpenRead);
                FlightCollection := PCollection(SaveFile.Get);
                MessageBox('1', nil, mfOkButton);
                if SaveFile.Status <> stOk then
                begin
                                MessageBox('2', nil, mfOkButton);
                    SaveFile.Done;
                    SaveFile.Init('Flight.res', stCreate);
                    if SaveFile.Status <> stOk then MessageBox('Creation Error', nil, mfOkButton);
                    FlightCollection := New(PCollection, Init(10, 5));
                    FlightCollection^.Insert(New(PFlight, Init('1','2','3','4','5','6')));
                end;
                SaveFile.Done;
		MessageBox ('Running', nil, mfOkButton);
                with Find do
  begin
    Field := 0;
    Value := 'Phone home';
  end;
                with Add do
  begin
    Date:= 'asd';
                Time:= '11';
                Price:= '22';
                Start:= '33';
                Dest:= '44';
  end;
	end;
procedure TMyAppl.PrintFlights;
var
	F: text;
        i: integer;
	procedure PrintFlight(P: PFlight); far;
	begin
                Inc(i);
		With P^ do
                write(F, Id^+' '+Price^+' '+FromPoint^+' '+ToPoint^+' '+Date^+' '+Time^);
                if FlightCollection^.Count <> i then begin
                  writeln(F,'');
                end;
	end;
begin
    Assign(F, 'DATA.TXT');
        Rewrite(F);
        i := 0;
    	FlightCollection^.ForEach(@PrintFlight);
    	Close(F);
end;
procedure TMyAppl.SearchFlights;
var
	FoundFlight: PFlight;
	temp: string;
	function SearchFlight(P: PFlight):Boolean; far;
	begin
		Case Find.Field of
			0: 	begin
					temp := P^.Id^;
				end;
			1: 	begin
					temp := P^.Price^;
				end;
			2: 	begin
					temp := P^.FromPoint^;
				end;
			3: 	begin
					temp := P^.ToPoint^;
				end;
			4: 	begin
					temp := P^.Date^;
				end;
			5: 	begin
					temp := P^.Time^;
				end;
		end;
		SearchFlight := Pos(Find.Value, Temp)<>0;
	end;
begin
    	FoundFlight := FlightCollection^.FirstThat(@SearchFlight);
    	if FoundFlight = NIL then begin
    		MessageBox('Not fount', nil, mfOkButton);
    	end else begin
                temp := FoundFlight^.Id^+' '+FoundFlight^.Price^+' '+FoundFlight^.FromPoint^+' ';
                temp := temp + FoundFlight^.ToPoint^+' '+FoundFlight^.Date^+' '+FoundFlight^.Time^;
    		MessageBox(temp, nil, mfOkButton);
    	end;
end;
constructor TListWindow.Init (Bounds: TRect; WinTitle: String; WinNo: Integer);
	var
	HSB, VSB: PScrollBar;
        F: text;
        temp: string;
	begin
		TWindow.Init (Bounds,WinTitle, WinNo);
		VSB := StandardScrollBar (sbVertical);
		HSB := StandardScrollBar(sbHorizontal);
		GetExtent(Bounds);
		Bounds.Grow(-1,-1);
                New(Term, Init(Bounds, HSB, VSB, 50000));
                {SaveFile.Init('Data.txt', stCreate);
                SaveFile.Done;}
                Assign(F, 'Data.txt');
                Reset(F);
                AssignDevice(Buff, Term);
                Rewrite(Buff);
                MessageBox('cycle', nil, mfOkButton);
                while not eof(F) do
                                begin
                                     Read(F, temp);
                                     if temp[0] <> '' then Writeln(Buff, temp);
                                end;
                                MessageBox('cycle done', nil, mfOkButton);
                Insert(Term);
                system.close(F);
	end;
constructor TAddDialog.Init (var Bounds: TRect; WinTitle: String);
var
        R: TRect; B: PView;
        FieldWidth: integer;
begin
inherited Init (Bounds,WinTitle);
FieldWidth := (Bounds.B.X - Bounds.A.X) div 2 - 3;

R.Assign(3,2,FieldWidth,3);
B:=New(PInputLine,Init(R,128));
Insert(B);
R.Assign(3,1,FieldWidth,2);
Insert(New(PLabel,Init(R,'Date',B)));

R.Assign(3,5,FieldWidth,6);
B:=New(PInputLine,Init(R,128));
Insert(B);
R.Assign(3,4,FieldWidth,5);
Insert(New(PLabel,Init(R,'Time',B)));

R.Assign(3,8,FieldWidth,9);
B:=New(PInputLine,Init(R,128));
Insert(B);
R.Assign(3,7,FieldWidth,8);
Insert(New(PLabel,Init(R,'Price',B)));

R.Assign(FieldWidth + 5,2,FieldWidth * 2 + 2,3);
B:=New(PInputLine,Init(R,128));
Insert(B);
R.Assign(FieldWidth + 5,1,FieldWidth * 2 + 2,2);
Insert(New(PLabel,Init(R,'Start',B)));

R.Assign(FieldWidth + 5,5,FieldWidth * 2 + 2,6);
B:=New(PInputLine,Init(R,128));
Insert(B);
R.Assign(FieldWidth + 5,4,FieldWidth * 2 + 2,5);
Insert(New(PLabel,Init(R,'Destination',B)));

R.Assign(15,10,25,12);

Insert(New (PButton, Init (R, '~A~dd Flight', cmOk, bfDefault)));

end;
constructor TFindDialog.Init (var Bounds: TRect; WinTitle: String);
var R: TRect; B: PView;
begin
inherited Init (Bounds,WinTitle);
R.Assign(3,3,30,9);
B:= New (PRadioButtons, Init (R,
 NewSItem ('Id',
 NewSItem ('Price',
 NewSItem ('Starting location',
 NewSItem ('Destination',
 NewSItem ('Date',
 NewSItem ('Time',
 Nil))))))));
Insert(B);
R.Assign(3,1,10,2);
Insert(New(PLabel,Init(R,'Field',B)));
R.Assign(3,10,30,11);
B:=New(PInputLine,Init(R,128));
Insert(B);
R.Assign(8,12,26,14);

Insert(New (PButton, Init (R, '~F~ind', cmOk, bfDefault)));

end;

procedure TMyAppl.ListFlights;
var
		FlightList: PListWindow;
		R:TRect;
		f: text;
	begin
		R.Assign(1, 1, 80, 24);
		TMyAppl.PrintFlights;
		FlightList:=New(PListWindow, Init (R, 'Flight List', WnNoNumber));
		DeskTop^.Insert(FlightList);
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
                if Control = cmOk then begin
                        Dialog^.GetData(Add);
                        FlightCollection^.Insert(New(PFlight, Init(
                        '1', Add.Price, Add.Start, Add.Dest, Add.Date, Add.Time)));
                end;
	end;
procedure TMyAppl.FindFlight;
	var
		Dialog: PFindDialog;
		R: TRect;
                Control: Word;
                Data : PDosStream;
	begin
		R.Assign(0, 0, 33, 15);
		R.Move(Random(39), Random(10));
		Dialog := New(PFindDialog, Init(R, 'Find Flight'));
                Dialog^.SetData(Find);
                Control := DeskTop^.ExecView(Dialog);
                if Control <> cmCancel then begin
                        Dialog^.GetData(Find);
                        TMyAppl.SearchFlights;
                end;
	end;
destructor TMyAppl.Done;
var
   i:integer;
   procedure SaveFlight(P: PFlight); far;
   begin
        With P^ do
        MessageBox('writing '+Id^+' '+Price^, nil, mfOkButton);
        SaveFile.Put(P);
        if SaveFile.Status <> stOk then MessageBox('Failed to write', nil, mfOkButton);
   end;
begin
     SaveFile.Init('Flight.res', stOpenWrite);
     if SaveFile.Status <> stOk then MessageBox('Open Flight.res for write failed', nil, mfOkButton);
{     SaveFile.Put(FlightCollection);}
     FlightCollection^.ForEach(@SaveFlight);
     if SaveFile.Status = stPutError then MessageBox('Flight.res put collection failed', nil, mfOkButton);
     SaveFile.Done;
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
			else
				Exit;
			end;
			ClearEvent(Event);
		end;
	end;
	begin
		FlightAppl.Init;
		FlightAppl.Run;
		FlightAppl.Done;
	end.
