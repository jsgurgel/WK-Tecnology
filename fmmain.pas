unit fmmain;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Menus,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Objects,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf,
  FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async,
  FireDAC.Phys, FireDAC.Phys.MySQL, FireDAC.Phys.MySQLDef, FireDAC.FMXUI.Wait,
  Data.DB, FireDAC.Comp.Client, FireDAC.Comp.UI;

type
  TfrmMain = class(TForm)
    MainMenu1: TMainMenu;
    mnCadastro: TMenuItem;
    mnVendas: TMenuItem;
    mnPedido: TMenuItem;
    mnClose: TMenuItem;
    Image1: TImage;
    FDConnection1: TFDConnection;
    FDPhysMySQLDriverLink1: TFDPhysMySQLDriverLink;
    FDGUIxWaitCursor1: TFDGUIxWaitCursor;
    FDTransaction1: TFDTransaction;
    procedure mnCloseClick(Sender: TObject);
    procedure mnPedidoClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    procedure LoadConnectionSettings;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmMain: TfrmMain;
  fConfig:String;

implementation
Uses ufrmPedido;

{$R *.fmx}
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

function HomeDir:String;
Begin
  Result:=ExtractFilePath(ParamStr(0));
end;

procedure TfrmMain.LoadConnectionSettings;
begin
  FDConnection1.Connected := False;
  FDConnection1.Params.LoadFromFile('config.ini');
  FDPhysMySQLDriverLink1.VendorLib := HomeDir + '\libmysql.dll';
end;

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  fConfig := HomeDir + 'config.ini';
  if not FileExists(fConfig) then
  Begin
    ShowMessage('O arquivo de configurações não foi localidado na pasta do sistema.');
    exit;
  End;

  LoadConnectionSettings;
  try
    FDConnection1.Connected := True;
  except
    on E: Exception do
      raise Exception.Create('Erro ao conectar ao banco de dados: ' + E.Message);
  end;
end;

procedure TfrmMain.FormDestroy(Sender: TObject);
begin
  FDConnection1.Connected := false;
end;

procedure TfrmMain.mnCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmMain.mnPedidoClick(Sender: TObject);
Var
  frmPedido: TfrmPedido;
begin
  frmPedido := TfrmPedido.create(self);
  Try
    frmPedido.ShowModal;
  Finally
    FreeObject(frmPedido);
  End;
end;

end.
