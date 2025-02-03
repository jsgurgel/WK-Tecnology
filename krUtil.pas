unit krUtil;

interface

Uses
  System.Classes, System.SysUtils,
  Winapi.Windows, FMX.Forms, FMX.Controls,
  FMX.Types, FMX.Dialogs, FMX.StdCtrls,
  IniFiles, System.UITypes,
  System.IOUtils;


Function Confirm(Msg:string; EnableBeep:Boolean=False; DefaultButton:TMsgDlgBtn=TMsgDlgBtn.mbNo):Boolean;
Function QuitApplication:Boolean;
procedure Warning(Msg:string);
procedure DisplayError(Msg:string; EnableBeep:Boolean=True);
//
function BackSlashed(const aFolder:string):string;
function HomeDir:String; // Informa o diretório da aplicação.
procedure FreeObject(var aObject); // libera um objeto da memória
procedure ProcessMessages;
Function DataExtenso:String;
function DeletarCharExpeciais(Value: String): String;


implementation

function DeletarCharExpeciais(Value: String): String;
Var
  fValue:String;
begin
  fValue:=Trim(Value);
  While Pos('.',fValue)<>0 do Delete(fValue,Pos('.',fValue), 1);
  While Pos('/',fValue)<>0 do Delete(fValue,Pos('/',fValue), 1);
  While Pos('-',fValue)<>0 do Delete(fValue,Pos('-',fValue), 1);
  Result:=fValue;
end;

function DataExtenso: String;
begin
  Result:=FormatDateTime('dd " de " mmmm " de " yyyy', Now);
end;

function DataExtensa(Data: TDateTime) : String;
Begin
  Result:=FormatDateTime('dd "de" mmmm "de" yyyy',Data);
end;

procedure ProcessMessages;
Begin
  Application.ProcessMessages;
end;

procedure Warning(Msg:string);
Begin
  MessageDlg(Msg, TMsgDlgType.mtWarning, [TMsgDlgBtn.mbOK], 0);
end;

procedure DisplayError(Msg:string; EnableBeep:Boolean=True);
Begin
  if EnableBeep then System.SysUtils.Beep;
  MessageDlg(Msg, TMsgDlgType.mtError, [TMsgDlgBtn.mbOK], 0);
end;

Function Confirm(Msg:string; EnableBeep:Boolean=False; DefaultButton:TMsgDlgBtn=TMsgDlgBtn.mbNo):Boolean;
Begin
  if EnableBeep then
    System.SysUtils.Beep;
  Result := MessageDlg(Msg, TMsgDlgType.mtConfirmation, [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo], 0, DefaultButton) = mrYes;;
end;

procedure NewException(ErrorMsg:string);
Begin
  raise Exception.Create(ErrorMsg);
end;

Function QuitApplication:Boolean;
Begin
  Result := Confirm('Deseja encerrar a aplicação?', False);
end;


procedure FreeObject(var aObject);
var
  p:TObject;
begin
  if TObject(aObject)<>nil then
  begin
    p:=TObject(aObject);
    TObject(aObject):=nil;
    p.Free;
  end;
end;

function BackSlashed(const aFolder:string):string;
var
  L:Integer;
begin
  Result := aFolder;
  L := Length(Result);
  if L > 0 then
    if Result[L] <> System.IOUtils.TPath.DirectorySeparatorChar then
      Result:= Result + System.IOUtils.TPath.DirectorySeparatorChar;
end;

function HomeDir:String;
Begin
  Result:=BackSlashed(ExtractFilePath(ParamStr(0)));
end;


procedure Create;
begin
//
end;

procedure Destroy;
begin
//
end;

Initialization
  Create;

Finalization
  Destroy;
end.
