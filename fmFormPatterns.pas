unit fmFormPatterns;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, krUtil;

type
  TfrmFormPatterns = class(TForm)
    procedure FormKeyDown(Sender: TObject; var Key: Word; var KeyChar: WideChar;
      Shift: TShiftState);
  private
    { Private declarations }
  public
    procedure FreeObject(var aObject);
    Function Confirm(Msg:string; EnableBeep:Boolean=False; DefaultButton:TMsgDlgBtn=TMsgDlgBtn.mbNo):Boolean;
    Function QuitApplication:Boolean;
    procedure Warning(Msg:string);
    procedure DisplayError(Msg:string; EnableBeep:Boolean=True);
    function BackSlashed(const aFolder:string):string;
    function HomeDir:String;
    procedure ProcessMessages;
    function DeletarCharExpeciais(Value: String): String;
    { Public declarations }
  end;

var
  frmFormPatterns: TfrmFormPatterns;

implementation

{$R *.fmx}

{ TfrmFormPatterns }

function TfrmFormPatterns.DeletarCharExpeciais(Value: String): String;
begin
  Result := KrUtil.DeletarCharExpeciais(Value);
end;

procedure TfrmFormPatterns.DisplayError(Msg: string; EnableBeep: Boolean);
begin
  KrUtil.DisplayError(Msg, EnableBeep);
end;

procedure TfrmFormPatterns.FormKeyDown(Sender: TObject; var Key: Word;
  var KeyChar: WideChar; Shift: TShiftState);
begin
  if key = 27 then Close;

end;

procedure TfrmFormPatterns.FreeObject(var aObject);
begin
  krUtil.FreeObject(aObject);
end;

function TfrmFormPatterns.HomeDir: String;
begin
  Result := KrUtil.HomeDir;
end;

procedure TfrmFormPatterns.ProcessMessages;
begin
  KrUtil.ProcessMessages;
end;

function TfrmFormPatterns.QuitApplication: Boolean;
begin
  Result := KrUtil.QuitApplication;
end;

procedure TfrmFormPatterns.Warning(Msg: string);
begin
  KrUtil.Warning(Msg);
end;

{ TfrmFormPatterns }

function TfrmFormPatterns.BackSlashed(const aFolder: string): string;
begin
  Result := KrUtil.BackSlashed(aFolder);
end;

function TfrmFormPatterns.Confirm(Msg: string; EnableBeep: Boolean;
  DefaultButton: TMsgDlgBtn): Boolean;
begin
  Result := krutil.Confirm(Msg, EnableBeep, DefaultButton);
end;

end.
