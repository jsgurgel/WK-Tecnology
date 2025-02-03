unit uFrmBuscaCliente;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls,
  FMX.Edit, FMX.Controls.Presentation, FMX.Layouts, FMX.Grid.Style,
  FMX.Grid, FMX.ScrollBox, Data.DB, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf,
  FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt, FireDAC.Comp.DataSet,
  FireDAC.Comp.Client, System.Rtti, Data.Bind.EngExt, fmmain,
  Fmx.Bind.DBEngExt, System.Bindings.Outputs, Fmx.Bind.Editors,
  Data.Bind.Components, Data.Bind.Grid, Data.Bind.DBScope,  Fmx.Bind.Grid,
  fmFormPatterns;

type
  TfrmBuscaCliente = class(TfrmFormPatterns)
    pnlTop: TPanel;
    lblFiltro: TLabel;
    edtFiltro: TEdit;
    btnPesquisar: TButton;
    pnlBottom: TPanel;
    btnSelecionar: TButton;
    btnCancelar: TButton;
    qryClientes: TFDQuery;
    BindSourceDB1: TBindSourceDB;
    BindingsList1: TBindingsList;
    grdClientes: TStringGrid;
    LinkGridToDataSourceBindSourceDB12: TLinkGridToDataSource;
    qryClientescodigo: TFDAutoIncField;
    qryClientesnome: TStringField;
    qryClientescidade: TStringField;
    qryClientesuf: TStringField;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnCancelarClick(Sender: TObject);
    procedure edtFiltroKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
    procedure btnSelecionarClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; var KeyChar: WideChar;
      Shift: TShiftState);
    procedure btnPesquisarClick(Sender: TObject);
  private
    FCodigoSelecionado: Integer;
    procedure CarregarDados(const AFiltro: string = '');
  public
    property CodigoSelecionado: Integer read FCodigoSelecionado write FCodigoSelecionado;
    class function Executar: Integer;
  end;

implementation

{$R *.fmx}

class function TfrmBuscaCliente.Executar: Integer;
var
  Form: TfrmBuscaCliente;
begin
  Form := TfrmBuscaCliente.Create(nil);
  try
    Form.ShowModal;
    Result := Form.CodigoSelecionado;
  finally
    Form.Free;
  end;
end;

procedure TfrmBuscaCliente.FormCreate(Sender: TObject);
begin
  inherited;
  FCodigoSelecionado := 0;
  qryClientes.Connection := frmmain.FDConnection1;
  CarregarDados;
end;

procedure TfrmBuscaCliente.FormDestroy(Sender: TObject);
begin
  inherited;
  qryClientes.Close;
end;

procedure TfrmBuscaCliente.FormKeyDown(Sender: TObject; var Key: Word;
  var KeyChar: WideChar; Shift: TShiftState);
begin
  inherited;
  if Key = 27 then
    close;
end;

procedure TfrmBuscaCliente.CarregarDados(const AFiltro: string = '');
var
  SQL: string;
begin
  SQL := 'SELECT codigo, nome, cidade, uf FROM clientes WHERE 1=1';
  
  if AFiltro <> '' then
    SQL := SQL + ' AND (UPPER(nome) LIKE :filtro OR UPPER(cidade) LIKE :filtro)';
    
  SQL := SQL + ' ORDER BY nome';
  
  qryClientes.Close;
  qryClientes.SQL.Text := SQL;
  
  if AFiltro <> '' then
    qryClientes.ParamByName('filtro').AsString := '%' + UpperCase(AFiltro) + '%';
    
  qryClientes.Open;
end;

procedure TfrmBuscaCliente.btnPesquisarClick(Sender: TObject);
begin
  inherited;
  CarregarDados(edtFiltro.Text);
end;

procedure TfrmBuscaCliente.btnSelecionarClick(Sender: TObject);
begin
  inherited;
  if not qryClientes.IsEmpty then
    FCodigoSelecionado := qryClientes.FieldByName('codigo').AsInteger;
  ModalResult := mrOk;
end;

procedure TfrmBuscaCliente.edtFiltroKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
begin
  inherited;
  if Key = vkReturn then
    btnPesquisarClick(Sender);
end;

procedure TfrmBuscaCliente.btnCancelarClick(Sender: TObject);
begin
  inherited;
  FCodigoSelecionado := 0;
  ModalResult := mrCancel;
end;

end.
