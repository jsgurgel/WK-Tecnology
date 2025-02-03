unit uFrmCadastroProduto;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls,
  FMX.Edit, FMX.Controls.Presentation, FMX.Layouts, FMX.Grid.Style,
  FMX.Grid, FMX.ScrollBox, Data.DB, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf,
  FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt, FireDAC.Comp.DataSet,
  FireDAC.Comp.Client, System.Rtti, Data.Bind.EngExt,
  Fmx.Bind.DBEngExt, System.Bindings.Outputs, Fmx.Bind.Editors,
  Data.Bind.Components, Data.Bind.Grid, Data.Bind.DBScope, fmmain, fmFormPatterns,
  FMX.NumberBox, FMX.EditBox, Fmx.Bind.Grid;

type
  TfrmCadastroProduto = class(TfrmFormPatterns)
    pnlTop: TPanel;
    lblFiltro: TLabel;
    edtFiltro: TEdit;
    btnPesquisar: TButton;
    grdProdutos: TGrid;
    pnlBottom: TPanel;
    btnNovo: TButton;
    btnAlterar: TButton;
    btnExcluir: TButton;
    btnFechar: TButton;
    pnlDados: TPanel;
    lblCodigo: TLabel;
    edtCodigo: TEdit;
    lblDescricao: TLabel;
    edtDescricao: TEdit;
    lblPrecoVenda: TLabel;
    edtPrecoVenda: TNumberBox;
    btnGravar: TButton;
    btnCancelar: TButton;
    qryProdutos: TFDQuery;
    BindSourceDB1: TBindSourceDB;
    BindingsList1: TBindingsList;
    LinkGridToDataSourceBindSourceDB1: TLinkGridToDataSource;
    Column1: TColumn;
    Column2: TColumn;
    Column3: TColumn;
    StringGridBindSourceDB1: TStringGrid;
    LinkGridToDataSourceBindSourceDB12: TLinkGridToDataSource;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnPesquisarClick(Sender: TObject);
    procedure btnNovoClick(Sender: TObject);
    procedure btnAlterarClick(Sender: TObject);
    procedure btnExcluirClick(Sender: TObject);
    procedure btnFecharClick(Sender: TObject);
    procedure btnGravarClick(Sender: TObject);
    procedure btnCancelarClick(Sender: TObject);
    procedure edtFiltroKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
  private
    FModoEdicao: Boolean;
    procedure CarregarDados(const AFiltro: string = '');
    procedure HabilitarControles(const AHabilitar: Boolean);
    procedure LimparCampos;
    procedure CarregarProduto;
    function ValidarCampos: Boolean;
    function ProximoCodigo: Integer;
  public
    { Public declarations }
  end;

var
  frmCadastroProduto: TfrmCadastroProduto;

implementation

{$R *.fmx}

procedure TfrmCadastroProduto.FormCreate(Sender: TObject);
begin
  inherited;
  qryProdutos.Connection := frmmain.FDConnection1;
  CarregarDados;
  HabilitarControles(False);
  pnlDados.Visible := False;
end;

procedure TfrmCadastroProduto.FormDestroy(Sender: TObject);
begin
  inherited;
  qryProdutos.Close;
end;

procedure TfrmCadastroProduto.CarregarDados(const AFiltro: string = '');
var
  SQL: string;
begin
  SQL := 'SELECT codigo, descricao, preco_venda FROM produtos WHERE 1=1';
  
  if AFiltro <> '' then
    SQL := SQL + ' AND (UPPER(descricao) LIKE :filtro)';
    
  SQL := SQL + ' ORDER BY descricao';
  
  qryProdutos.Close;
  qryProdutos.SQL.Text := SQL;
  
  if AFiltro <> '' then
    qryProdutos.ParamByName('filtro').AsString := '%' + UpperCase(AFiltro) + '%';
    
  qryProdutos.Open;
end;

procedure TfrmCadastroProduto.btnPesquisarClick(Sender: TObject);
begin
  inherited;
  CarregarDados(edtFiltro.Text);
end;

procedure TfrmCadastroProduto.edtFiltroKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
begin
  inherited;
  if Key = vkReturn then
    btnPesquisarClick(Sender);
end;

procedure TfrmCadastroProduto.HabilitarControles(const AHabilitar: Boolean);
begin
  FModoEdicao := AHabilitar;
  
  pnlTop.Enabled := not AHabilitar;
  grdProdutos.Enabled := not AHabilitar;
  btnNovo.Enabled := not AHabilitar;
  btnAlterar.Enabled := not AHabilitar and (not qryProdutos.IsEmpty);
  btnExcluir.Enabled := not AHabilitar and (not qryProdutos.IsEmpty);
  btnFechar.Enabled := not AHabilitar;
  
  edtDescricao.Enabled := AHabilitar;
  edtPrecoVenda.Enabled := AHabilitar;
  btnGravar.Enabled := AHabilitar;
  btnCancelar.Enabled := AHabilitar;
end;

procedure TfrmCadastroProduto.LimparCampos;
begin
  edtCodigo.Text := '';
  edtDescricao.Text := '';
  edtPrecoVenda.Value := 0;
end;

procedure TfrmCadastroProduto.CarregarProduto;
begin
  if not qryProdutos.IsEmpty then
  begin
    edtCodigo.Text := qryProdutos.FieldByName('codigo').AsString;
    edtDescricao.Text := qryProdutos.FieldByName('descricao').AsString;
    edtPrecoVenda.Value := qryProdutos.FieldByName('preco_venda').AsFloat;
  end;
end;

function TfrmCadastroProduto.ValidarCampos: Boolean;
begin
  Result := False;

  if Trim(edtDescricao.Text) = '' then
  begin
    Warning('A descrição do produto é obrigatória!');
    edtDescricao.SetFocus;
    Exit;
  end;

  if edtPrecoVenda.Value <= 0 then
  begin
    Warning('O preço de venda deve ser maior que zero!');
    edtPrecoVenda.SetFocus;
    Exit;
  end;

  Result := True;
end;

function TfrmCadastroProduto.ProximoCodigo: Integer;
var
  Query: TFDQuery;
begin
  Query := TFDQuery.Create(nil);
  try
    Query.Connection := frmmain.FDConnection1;
    Query.SQL.Text := 'SELECT MAX(codigo) + 1 AS proximo_codigo FROM produtos';
    Query.Open;
    
    Result := Query.FieldByName('proximo_codigo').AsInteger;
    if Result = 0 then
      Result := 1;
  finally
    FreeObject(Query);
  end;
end;

procedure TfrmCadastroProduto.btnNovoClick(Sender: TObject);
begin
  inherited;
  LimparCampos;
  edtCodigo.Text := IntToStr(ProximoCodigo);
  HabilitarControles(True);
  pnlDados.Visible := True;
  edtDescricao.SetFocus;
end;

procedure TfrmCadastroProduto.btnAlterarClick(Sender: TObject);
begin
  inherited;
  if qryProdutos.IsEmpty then
    Exit;
    
  CarregarProduto;
  HabilitarControles(True);
  pnlDados.Visible := True;
  edtDescricao.SetFocus;
end;

procedure TfrmCadastroProduto.btnExcluirClick(Sender: TObject);
var
  Query: TFDQuery;
begin
  inherited;
  if qryProdutos.IsEmpty then
    Exit;
    
  if MessageDlg('Confirma a exclusão deste produto?',
    TMsgDlgType.mtConfirmation, [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo], 0) = mrYes then
  begin
    Query := TFDQuery.Create(nil);
    try
      Query.Connection := frmmain.FDConnection1;
      Query.SQL.Text := 'DELETE FROM produtos WHERE codigo = :codigo';
      Query.ParamByName('codigo').AsInteger := qryProdutos.FieldByName('codigo').AsInteger;
      Query.ExecSQL;
      
      Warning('Produto excluído com sucesso!');
      CarregarDados(edtFiltro.Text);
    finally
      FreeObject(Query);
    end;
  end;
end;

procedure TfrmCadastroProduto.btnGravarClick(Sender: TObject);
var
  Query: TFDQuery;
  SQL: string;
begin
  inherited;
  if not ValidarCampos then
    Exit;
    
  Query := TFDQuery.Create(nil);
  try
    Query.Connection := frmmain.FDConnection1;

    Query.SQL.Text := 'SELECT codigo FROM produtos WHERE codigo = :codigo';
    Query.ParamByName('codigo').AsInteger := StrToInt(edtCodigo.Text);
    Query.Open;
    
    if Query.IsEmpty then
      SQL := 'INSERT INTO produtos (codigo, descricao, preco_venda) VALUES (:codigo, :descricao, :preco_venda)'
    else
      SQL := 'UPDATE produtos SET descricao = :descricao, preco_venda = :preco_venda WHERE codigo = :codigo';
    
    Query.Close;
    Query.SQL.Text := SQL;
    Query.ParamByName('codigo').AsInteger := StrToInt(edtCodigo.Text);
    Query.ParamByName('descricao').AsString := edtDescricao.Text;
    Query.ParamByName('preco_venda').AsBCD := edtPrecoVenda.Value;
    Query.ExecSQL;
    
    Warning('Produto gravado com sucesso!');
    
    HabilitarControles(False);
    pnlDados.Visible := False;
    CarregarDados(edtFiltro.Text);
  finally
    FreeObject(Query);
  end;
end;

procedure TfrmCadastroProduto.btnCancelarClick(Sender: TObject);
begin
  inherited;
  HabilitarControles(False);
  pnlDados.Visible := False;
end;

procedure TfrmCadastroProduto.btnFecharClick(Sender: TObject);
begin
  inherited;
  Close;
end;

end.
