unit uFrmBuscaProduto;

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
  TfrmBuscaProduto = class(TfrmFormPatterns)
    pnlTop: TPanel;
    lblFiltro: TLabel;
    edtFiltro: TEdit;
    btnPesquisar: TButton;
    pnlBottom: TPanel;
    btnSelecionar: TButton;
    btnCancelar: TButton;
    qryProdutos: TFDQuery;
    BindSourceDB1: TBindSourceDB;
    BindingsList1: TBindingsList;
    grdProdutos: TStringGrid;
    LinkGridToDataSourceBindSourceDB12: TLinkGridToDataSource;
    qryProdutoscodigo: TFDAutoIncField;
    qryProdutosdescricao: TStringField;
    qryProdutospreco_venda: TBCDField;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnCancelarClick(Sender: TObject);
    procedure edtFiltroKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
    procedure btnSelecionarClick(Sender: TObject);
    procedure qryClientesAfterScroll(DataSet: TDataSet);
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

class function TfrmBuscaProduto.Executar: Integer;
var
  Form: TfrmBuscaProduto;
begin
  Form := TfrmBuscaProduto.Create(nil);
  try
    Form.ShowModal;
    Result := Form.CodigoSelecionado;
  finally
    Form.Free;
  end;
end;

procedure TfrmBuscaProduto.FormCreate(Sender: TObject);
begin
  inherited;
  FCodigoSelecionado := 0;
  qryProdutos.Connection := frmmain.FDConnection1;
  CarregarDados;
end;

procedure TfrmBuscaProduto.FormDestroy(Sender: TObject);
begin
  inherited;
  qryProdutos.Close;
end;

procedure TfrmBuscaProduto.FormKeyDown(Sender: TObject; var Key: Word;
  var KeyChar: WideChar; Shift: TShiftState);
begin
  inherited;
  if Key = 27 then
    close;
end;

procedure TfrmBuscaProduto.qryClientesAfterScroll(DataSet: TDataSet);
begin
  inherited;
  if not qryProdutos.IsEmpty then
    FCodigoSelecionado := qryProdutos.FieldByName('codigo').AsInteger;
end;

procedure TfrmBuscaProduto.CarregarDados(const AFiltro: string = '');
var
  SQL: string;
begin
  SQL := 'SELECT codigo, descricao, preco_venda FROM produtos WHERE 1=1';

  if AFiltro <> '' then
    SQL := SQL + ' AND (UPPER(descricao) LIKE :filtro';
    
  SQL := SQL + ' ORDER BY descricao';
  
  qryProdutos.Close;
  qryProdutos.SQL.Text := SQL;
  
  if AFiltro <> '' then
    qryProdutos.ParamByName('filtro').AsString := '%' + UpperCase(AFiltro) + '%';
    
  qryProdutos.Open;
end;

procedure TfrmBuscaProduto.btnCancelarClick(Sender: TObject);
begin
  inherited;
  FCodigoSelecionado := 0;
  ModalResult := mrCancel;
end;

procedure TfrmBuscaProduto.btnPesquisarClick(Sender: TObject);
begin
  inherited;
  CarregarDados(edtFiltro.Text);
end;

procedure TfrmBuscaProduto.btnSelecionarClick(Sender: TObject);
begin
  inherited;
  if not qryProdutos.IsEmpty then
    FCodigoSelecionado := qryProdutos.FieldByName('codigo').AsInteger;
  ModalResult := mrOk;
end;

procedure TfrmBuscaProduto.edtFiltroKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
begin
  inherited;
  if Key = vkReturn then
    btnPesquisarClick(Sender);
end;

end.
