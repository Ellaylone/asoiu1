uses app,Objects,Views,Drivers,Menus,MsgBox,TextView,Dialogs;
 
type TMyApp = object(TApplication)
     BookList: PCollection;
     constructor Init;
     destructor done; virtual;
     procedure InitStatusLine; virtual;
     procedure InitMenuBar; virtual;
     procedure PrintBookList;
     procedure InsertBook;
     procedure SearchItem;
     procedure HandleEvent(var Event:TEvent); virtual;
end;
 
type
 PBook = ^TBook;
 TBook = object(TObject)
  Name, Avtor, Ganr, God, Izd: PString;
  Constructor Init(N, A, G, GD, I: String);
  destructor Done; virtual;
  constructor Load(S:TDosStream);
  procedure Store(S:TDosStream);
 end;
 
type
 
 PMyWindow = ^TMyWindow;
 TMyWindow = object(TWindow)
 Term: PTerminal;
  Buff: text;
  constructor Init (Bounds: TRect; WinTitle: String; WindowNo: integer);
 end;
 
 PDialVvod = ^TDialVvod;
 TDialVvod = object(TDialog)
  constructor Init(var Bounds: TRect; WinTitle: string);
 end;
 
 PDialSearch = ^TDialSearch;
 TDialSearch = object(TDialog)
  constructor Init(var Bounds: TRect; WinTitle: string);
 end;
 
 TDataVvod = record
  Name,Avtor, Ganr,God,Izd: string[128];
 end;
 
TDataSearch = record
 VvItem: string[128];
 end;
 
const
      cmPrCl = 101;
      cmInsCl = 102;
      cmSrch = 103;
      RBook: TStreamRec =(
      ObjType: 151;
      VmtLink: Ofs(TypeOf(TBook)^);
      Load: @TBook.Load;
      Store: @TBook.Store);
 
var
MyApp: TMyApp;
DataVvod: TDataVvod;
DataSearch: TDataSearch;
SaveFile: TDosStream;
 
constructor TMyApp.Init;
var f:text;
begin
 Inherited Init;
 RegisterType(RCollection);
 RegisterType(RBook);
 assign(f,'BOOK.txt');
 rewrite(f);
 system.close(f);
 MessageBox('System BIBLIOTEKA',nil,mfOkButton);
 BookList := new(PCollection,Init(10,5));
 BookList^.Insert(New(PBook,Init('Lada','Priora','RF','Sedan','200')));
 SaveFile.Init('BOOK.RES',stOpenRead);
 BookList := PCollection(SaveFile.Get);
 SaveFile.Done;
 if SaveFile.Status <> 0 then
  begin
  MessageBox('Error!',nil,mfOkButton);
  SaveFile.Init('BOOK.RES',stCreate);
  SaveFile.Done;
  end;
end;
 
procedure TMyApp.InitStatusLine;
var R:TRect;
begin
     R.Assign(0,24,80,25);
     StatusLine := new(PStatusLine,Init(R,NewStatusDef(0,$FFFF,
                NewStatusKey('~F1~Help',kbF1,cmHelp,
                NewStatusKey('~F10~Menu',kbF10,cmMenu,
                NewStatusKey('~Alt-X~Exit',kbAltX,cmQuit,
                nil))),
     nil)));
end;
 
procedure TMyApp.InitMenuBar;
var R: TRect;
begin
 R.Assign(0,0,80,1);
 MenuBar := New(PMenuBar,Init(R,NewMenu(
  NewSubMenu('File',hcNoContext,NewMenu(
   NewItem('Close','Alt-F3',kbAltF3,cmClose,hcNoContext,
   NewItem('Print List','Alt-P',KbAltP,cmPrCl,hcNoContext,
   NewItem('Insert Client','Alt-I',kbAltI,cmInsCl,hcNoContext,
   NewItem('Search Item','Alt-S',kbAltS,cmSrch,hcNoContext,
   NewItem('E~x~it','Alt-X',KbAltX,cmQuit,hcNoContext,
   nil)))))),
  NewSubMenu('Windows',hcNoCOntext,NewMenu(
   NewItem('Next','F6',KbF6,cmNext,hcNoContext,
   NewItem('Previous','Shift-F6',KbShiftF6,cmPrev,hcNoContext,
   nil))),
  nil))
 )));
end;
 
procedure TMyApp.HandleEvent;
begin
 inherited HandleEvent(Event);
 if Event.What=evCommand then
  begin
   case Event.Command of
    cmPrCl: PrintBookList;
    cmInsCl: InsertBook;
    cmSrch: SearchItem;
   end;
  end;
end;
 
procedure TMyApp.InsertBook;
var R: TRect;
    DialWindow: PDialVvod;
    control: word;
begin
 R.Assign(0,1,40,17);
 DialWindow := New(PDialVvod,Init(R,'Insert rec'));
 DialWindow^.SetData(DataVvod);
 control := DeskTop^.ExecView(DialWindow);
 if Control <> cmCancel then
  DialWindow^.GetData(DataVvod);
 if control = cmOK then
 BookList^.Insert(new(PBook,Init(DataVvod.Name,DataVvod.Avtor,DataVvod.Ganr,DataVvod.God,DataVvod.Izd)));
end;
 
procedure TMyApp.PrintBookList;
var R: TRect;
    Window: PMyWindow;
    f: text;
    procedure PrintBook(P: PBook); far;
    begin
     with P^ do
      writeln(f,Name^+' '+Avtor^+' '+Ganr^+' '+God^+' '+Izd^);
    end;
begin
 assign(f,'book.txt');
 rewrite(f);
 BookList^.ForEach(@PrintBook);
 close(f);
 R.Assign(0,1,80,22);
 Window := New(PMyWindow,Init(R,'List',WnNoNumber));
 DeskTop^.Insert(Window);
end;
 
procedure TMyApp.SearchItem;
var R: TRect;
    DialWindow: PDialSearch;
    control: word;
    FoundBook: PBook;
    s: string;
    function NameMatch(Book: PBook):boolean; far;
     begin
      NameMatch := pos(DataSearch.VvItem,Book^.Name^)<>0;
     end;
begin
 R.Assign(0,1,40,8);
 DialWindow := New(PDialSearch,Init(R,'Search record'));
 DialWindow^.SetData(DataSearch);
 control := DeskTop^.ExecView(DialWindow);
 if control <> cmCancel then
  DialWindow^.GetData(DataSearch);
 FoundBook := BookList^.FirstThat(@NameMatch);
 if FoundBook = nil then
    MessageBox('No matches found',nil,mfOkButton)
 else
  begin
   with FoundBook^ do
    s := Name^+ ' ' +Avtor^+ ' ' +Ganr^+ ' ' +God^+ ' ' +Izd^;
   MessageBox('Found '+s,nil,mfOkButton);
  end;
end;
 
destructor TMyApp.Done;
begin
 SaveFile.Init('BOOK.RES',stOpenWrite);
 if SaveFile.Status <> 0 then
 MessageBox('Error opening BOOK.RES',nil,mfOkButton);
 SaveFile.Put(BookList);
 SaveFile.Done;
 inherited done;
end;
 
Constructor TBook.Init(N, A, G, GD, I: String);
begin
     Name:= NewStr(N);
     Avtor := NewStr(A);
     Ganr:=NewStr(G);
     God := NewStr(GD);
     Izd := NewStr(I);
end;
 
constructor TBook.Load(S:TDosStream);
begin
 Name := S.ReadStr;
 Avtor := S.ReadStr;
 Ganr := S.ReadStr;
 God := S.ReadStr;
 Izd := S.ReadStr;
end;
 
procedure TBook.Store(S:TDosStream);
begin
 S.Write(Name, sizeof(name));
 S.Write(Avtor, sizeof (avtor));
 S.Write(Ganr, sizeof(ganr));
 S.Write(God, sizeof(god));
 s.Write(Izd, sizeof(izd));
end;
 
 
destructor TBook.Done;
begin
 dispose(Name);
 dispose(Avtor);
 dispose(Ganr);
 dispose(God);
 dispose(Izd);
end;
 
 
 
 
constructor TDialSearch.Init(var Bounds: TRect; WinTitle: string);
var R: TRect;
    B: PView;
begin
 inherited init(Bounds,WinTitle);
 R.Assign(3,2,10,3);
 Insert(New(PLabel,Init(R,'Name',B)));
 R.Assign(13,2,37,3);
 B := New(PInputLine,Init(R,128));
 Insert(B);
 R.Assign(3,4,13,6);
 Insert(New(PButton,Init(R,'OK',cmOk,bfDefault)));
 SelectNext(False);
end;
 
constructor TDialVvod.Init(var Bounds: TRect; WinTitle: string);
var R: TRect;
    B: PView;
begin
 inherited Init(Bounds,WinTitle);
 R.Assign(3,2,10,3);
 Insert(new(Plabel,Init(R,'Name',B)));
 R.Assign(13,2,37,3);
 B := New(PInputLine,Init(R,128));
 Insert(B);
 R.Assign(3,4,18,5);
 Insert(new(PLabel,Init(R,'Avtor',B)));
 R.Assign(13,4,37,5);
 B := New(PInputLine,Init(R,128));
 Insert(B);
 R.Assign(3,6,10,7);
 Insert(new(PLabel,init(R,'Ganr',B)));
 R.Assign(13,6,37,7);
 B := New(PInputLine,Init(R,128));
 Insert(B);
 R.Assign(3,8,10,9);
 Insert(new(PLabel,Init(R,'God',B)));
 R.Assign(13,8,37,9);
 B := New(PInputLine,Init(R,128));
 Insert(B);
 R.Assign(3,10,10,11);
 Insert(new(PLabel,init(R,'Izd',B)));
 R.Assign(13,10,37,11);
 B:= new(PInputLine,Init(R,128));
 insert(B);
 R.Assign(3,13,18,15);
 insert(new(PButton, init(R,'OK',cmOk, bfDefault)));
 SelectNext(False);
end;
 
constructor TMyWindow.Init(Bounds: TRect; WinTitle: string; WindowNo: integer);
var
f: text;
s: string;
begin
 TWindow.Init(Bounds,WinTitle,WindowNo);
 GetExtent(Bounds);
 Bounds.Grow(-1,-1);
 New(Term,Init(Bounds,StandardScrollBar(sbVertical+sbHandleKeyboard),StandardScrollBar(sbHorizontal+sbHandleKeyboard),50000));
 assign(f,'book.txt');
 AssignDevice(Buff,Term);
 Insert(Term);
 reset(f);
 rewrite(buff);
 while not eof(f) do
  begin
   readln(f,s);
   writeln(buff,s);
  end;
 system.close(f);
end;
 
 
 
begin
     MyApp.Init;
     MyApp.Run;
     MyApp.Done;
end.