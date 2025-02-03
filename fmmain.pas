unit fmmain;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Menus,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Objects,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf,
  FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async,
  FireDAC.Phys, FireDAC.Phys.MySQL, FireDAC.Phys.MySQLDef, FireDAC.FMXUI.Wait,
  Data.DB, FireDAC.Comp.Client, FireDAC.Comp.UI, krUtil;

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
    mnCadCliente: TMenuItem;
    mnCadProduto: TMenuItem;
    procedure mnCloseClick(Sender: TObject);
    procedure mnPedidoClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure mnCadClienteClick(Sender: TObject);
    procedure mnCadProdutoClick(Sender: TObject);
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
Uses ufrmPedido, uFrmCadastroCliente, uFrmCadastroProduto;

{$R *.fmx}
procedure TfrmMain.LoadConnectionSettings;
begin
  FDConnection1.Connected := False;
  FDConnection1.Params.LoadFromFile('config.ini');
  FDPhysMySQLDriverLink1.VendorLib := HomeDir + 'libmysql.dll';
end;

procedure TfrmMain.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := QuitApplication;
end;

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  fConfig := HomeDir + 'config.ini';
  if not FileExists(fConfig) then
  Begin
    Warning('O arquivo de configurações não foi localidado na pasta do sistema.');
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

procedure TfrmMain.mnCadClienteClick(Sender: TObject);
Var
  frmCadastroCliente : TfrmCadastroCliente;
begin
  Try
    frmCadastroCliente := TfrmCadastroCliente.Create(self);
    frmCadastroCliente.ShowModal;
  Finally
    FreeObject(frmCadastroCliente);
  End;
end;

procedure TfrmMain.mnCadProdutoClick(Sender: TObject);
Var
  frmCadastroProduto : TfrmCadastroProduto;
begin
  Try
    frmCadastroProduto := TfrmCadastroProduto.Create(self);
    frmCadastroProduto.ShowModal;
  Finally
    FreeObject(frmCadastroProduto);
  End;
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
