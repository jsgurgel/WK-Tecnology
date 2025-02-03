unit uFrmCadastroCliente;

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
  Data.Bind.Components, Data.Bind.Grid, Data.Bind.DBScope, fmmain, fmFormPatterns;

type
  TfrmCadastroCliente = class(TfrmFormPatterns)
    pnlTop: TPanel;
    lblFiltro: TLabel;
    edtFiltro: TEdit;
    btnPesquisar: TButton;
    grdClientes: TGrid;
    pnlBottom: TPanel;
    btnNovo: TButton;
    btnAlterar: TButton;
    btnExcluir: TButton;
    btnFechar: TButton;
    pnlDados: TPanel;
    lblCodigo: TLabel;
    edtCodigo: TEdit;
    lblNome: TLabel;
    edtNome: TEdit;
    lblCidade: TLabel;
    edtCidade: TEdit;
    lblUF: TLabel;
    edtUF: TEdit;
    btnGravar: TButton;
    btnCancelar: TButton;
    qryClientes: TFDQuery;
    BindSourceDB1: TBindSourceDB;
    BindingsList1: TBindingsList;
    LinkGridToDataSourceBindSourceDB1: TLinkGridToDataSource;
    Column1: TColumn;
    Column2: TColumn;
    Column3: TColumn;
    Column4: TColumn;
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
    procedure CarregarCliente;
    function ValidarCampos: Boolean;
    function ProximoCodigo: Integer;
  public
    { Public declarations }
  end;

var
  frmCadastroCliente: TfrmCadastroCliente;

implementation

{$R *.fmx}

procedure TfrmCadastroCliente.FormCreate(Sender: TObject);
begin
  inherited;
  qryClientes.Connection := frmmain.FDConnection1;
  CarregarDados;
  HabilitarControles(False);
  pnlDados.Visible := False;
end;

procedure TfrmCadastroCliente.FormDestroy(Sender: TObject);
begin
  inherited;
  qryClientes.Close;
end;

procedure TfrmCadastroCliente.CarregarDados(const AFiltro: string = '');
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

procedure TfrmCadastroCliente.btnPesquisarClick(Sender: TObject);
begin
  inherited;
  CarregarDados(edtFiltro.Text);
end;

procedure TfrmCadastroCliente.edtFiltroKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
begin
  inherited;
  if Key = vkReturn then
    btnPesquisarClick(Sender);
end;

procedure TfrmCadastroCliente.HabilitarControles(const AHabilitar: Boolean);
begin
  FModoEdicao := AHabilitar;
  
  pnlTop.Enabled := not AHabilitar;
  grdClientes.Enabled := not AHabilitar;
  btnNovo.Enabled := not AHabilitar;
  btnAlterar.Enabled := not AHabilitar and (not qryClientes.IsEmpty);
  btnExcluir.Enabled := not AHabilitar and (not qryClientes.IsEmpty);
  btnFechar.Enabled := not AHabilitar;
  
  edtNome.Enabled := AHabilitar;
  edtCidade.Enabled := AHabilitar;
  edtUF.Enabled := AHabilitar;
  btnGravar.Enabled := AHabilitar;
  btnCancelar.Enabled := AHabilitar;
end;

procedure TfrmCadastroCliente.LimparCampos;
begin
  edtCodigo.Text := '';
  edtNome.Text := '';
  edtCidade.Text := '';
  edtUF.Text := '';
end;

procedure TfrmCadastroCliente.CarregarCliente;
begin
  if not qryClientes.IsEmpty then
  begin
    edtCodigo.Text := qryClientes.FieldByName('codigo').AsString;
    edtNome.Text := qryClientes.FieldByName('nome').AsString;
    edtCidade.Text := qryClientes.FieldByName('cidade').AsString;
    edtUF.Text := qryClientes.FieldByName('uf').AsString;
  end;
end;

function TfrmCadastroCliente.ValidarCampos: Boolean;
begin
  Result := False;

  if Trim(edtNome.Text) = '' then
  begin
    Warning('O nome do cliente é obrigatório!');
    edtNome.SetFocus;
    Exit;
  end;

  if Trim(edtCidade.Text) = '' then
  begin
    Warning('A cidade é obrigatória!');
    edtCidade.SetFocus;
    Exit;
  end;

  if Trim(edtUF.Text) = '' then
  begin
    Warning('A UF é obrigatória!');
    edtUF.SetFocus;
    Exit;
  end;

  if Length(Trim(edtUF.Text)) <> 2 then
  begin
    Warning('A UF deve ter 2 caracteres!');
    edtUF.SetFocus;
    Exit;
  end;

  Result := True;
end;

function TfrmCadastroCliente.ProximoCodigo: Integer;
var
  Query: TFDQuery;
begin
  Query := TFDQuery.Create(nil);
  try
    Query.Connection := frmmain.FDConnection1;
    Query.SQL.Text := 'SELECT MAX(codigo) + 1 AS proximo_codigo FROM clientes';
    Query.Open;
    
    Result := Query.FieldByName('proximo_codigo').AsInteger;
    if Result = 0 then
      Result := 1;
  finally
    FreeObject(Query);
  end;
end;

procedure TfrmCadastroCliente.btnNovoClick(Sender: TObject);
begin
  inherited;
  LimparCampos;
  edtCodigo.Text := IntToStr(ProximoCodigo);
  HabilitarControles(True);
  pnlDados.Visible := True;
  edtNome.SetFocus;
end;

procedure TfrmCadastroCliente.btnAlterarClick(Sender: TObject);
begin
  inherited;
  if qryClientes.IsEmpty then
    Exit;
    
  CarregarCliente;
  HabilitarControles(True);
  pnlDados.Visible := True;
  edtNome.SetFocus;
end;

procedure TfrmCadastroCliente.btnExcluirClick(Sender: TObject);
var
  Query: TFDQuery;
begin
  inherited;
  if qryClientes.IsEmpty then
    Exit;
    
  if MessageDlg('Confirma a exclusão deste cliente?',
    TMsgDlgType.mtConfirmation, [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo], 0) = mrYes then
  begin
    Query := TFDQuery.Create(nil);
    try
      Query.Connection := frmmain.FDConnection1;
      Query.SQL.Text := 'DELETE FROM clientes WHERE codigo = :codigo';
      Query.ParamByName('codigo').AsInteger := qryClientes.FieldByName('codigo').AsInteger;
      Query.ExecSQL;
      
      Warning('Cliente excluído com sucesso!');
      CarregarDados(edtFiltro.Text);
    finally
      FreeObject(Query);
    end;
  end;
end;

procedure TfrmCadastroCliente.btnGravarClick(Sender: TObject);
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
    
    // Verifica se o registro já existe
    Query.SQL.Text := 'SELECT codigo FROM clientes WHERE codigo = :codigo';
    Query.ParamByName('codigo').AsInteger := StrToInt(edtCodigo.Text);
    Query.Open;
    
    if Query.IsEmpty then
      SQL := 'INSERT INTO clientes (codigo, nome, cidade, uf) VALUES (:codigo, :nome, :cidade, :uf)'
    else
      SQL := 'UPDATE clientes SET nome = :nome, cidade = :cidade, uf = :uf WHERE codigo = :codigo';
    
    Query.Close;
    Query.SQL.Text := SQL;
    Query.ParamByName('codigo').AsInteger := StrToInt(edtCodigo.Text);
    Query.ParamByName('nome').AsString := edtNome.Text;
    Query.ParamByName('cidade').AsString := edtCidade.Text;
    Query.ParamByName('uf').AsString := edtUF.Text;
    Query.ExecSQL;
    
    Warning('Cliente gravado com sucesso!');
    
    HabilitarControles(False);
    pnlDados.Visible := False;
    CarregarDados(edtFiltro.Text);
  finally
    FreeObject(Query);
  end;
end;

procedure TfrmCadastroCliente.btnCancelarClick(Sender: TObject);
begin
  inherited;
  HabilitarControles(False);
  pnlDados.Visible := False;
end;

procedure TfrmCadastroCliente.btnFecharClick(Sender: TObject);
begin
  inherited;
  Close;
end;

end.
