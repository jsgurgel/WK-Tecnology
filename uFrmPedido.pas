unit uFrmPedido;

interface

uses
  Winapi.Windows,  System.SysUtils, System.Variants, System.Classes,
  FMX.Graphics, FMX.Controls, FMX.Forms,  FMX.StdCtrls,
  FMX.ExtCtrls, Data.DB,  FireDAC.Stan.Intf,
  FMX.DialogService,  FMX.Dialogs,
  FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS,
  FireDAC.Phys.Intf, FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client, System.Generics.Collections,
  uPedido, System.Rtti, FMX.Grid.Style, Data.Bind.EngExt, Fmx.Bind.DBEngExt,
  System.Bindings.Outputs, Fmx.Bind.Editors, Data.Bind.Components,
  Data.Bind.Grid, Data.Bind.DBScope, FMX.Grid, FMX.ScrollBox,
  FMX.Edit, FMX.Controls.Presentation, FMX.Types, FMX.Layouts,
  fmmain, System.UITypes, Fmx.Bind.Grid, fmFormPatterns;

type
  TfrmPedido = class(TfrmFormPatterns)
    lblCliente: TLabel;
    edtCodCliente: TEdit;
    btnBuscaCliente: TButton;
    edtNomeCliente: TEdit;
    edtCidadeCliente: TEdit;
    edtUFCliente: TEdit;
    lblProduto: TLabel;
    edtCodProduto: TEdit;
    btnBuscaProduto: TButton;
    edtDescProduto: TEdit;
    lblQuantidade: TLabel;
    edtQuantidade: TEdit;
    lblValorUnit: TLabel;
    edtValorUnit: TEdit;
    btnInserirItem: TButton;
    grdItens: TGrid;
    lblTotalPedido: TLabel;
    edtTotalPedido: TEdit;
    btnGravarPedido: TButton;
    btnCarregarPedido: TButton;
    btnCancelarPedido: TButton;
    mtItens: TFDMemTable;
    BindSourceDB1: TBindSourceDB;
    BindingsList1: TBindingsList;
    LinkGridToDataSourceBindSourceDB1: TLinkGridToDataSource;
    StringGridBindSourceDB1: TStringGrid;
    LinkGridToDataSourceBindSourceDB12: TLinkGridToDataSource;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnBuscaClienteClick(Sender: TObject);
    procedure btnBuscaProdutoClick(Sender: TObject);
    procedure btnInserirItemClick(Sender: TObject);
    procedure grdItensKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure btnGravarPedidoClick(Sender: TObject);
    procedure btnCarregarPedidoClick(Sender: TObject);
    procedure btnCancelarPedidoClick(Sender: TObject);
    procedure edtCodClienteExit(Sender: TObject);
    procedure edtCodProdutoExit(Sender: TObject);
  private
    FPedido: TPedido;
    procedure ConfigurarGrid;
    procedure LimparCamposProduto;
    procedure LimparCamposCliente;
    procedure LimparTela;
    procedure CarregarCliente(ACodigo: Integer);
    procedure CarregarProduto(ACodigo: Integer);
    procedure AtualizarTotalPedido;
    function ValidarCampos: Boolean;
    procedure HabilitarBotoes;
    function CustomStrToFloat(value: variant): double;
  public
    property Pedido: TPedido read FPedido write FPedido;
  end;

var
  frmPedido: TfrmPedido;
  FloatValue: TFloatRec;
  DialogService : TDialogService;

implementation
Uses uFrmBuscaCliente, uFrmBuscaProduto;

{$R *.fmx}

function TfrmPedido.CustomStrToFloat(value: variant): double;
const
  Komma: TFormatSettings = (DecimalSeparator: ',');
  Dot: TFormatSettings = (DecimalSeparator: '.');

Var
  aValue : string;

begin
  aValue := DeletarCharExpeciais(value);
  if not TryStrToFloat(aValue, Result, Komma) then
    Result := StrToFloat(aValue, Dot);
end;

procedure TfrmPedido.FormCreate(Sender: TObject);
begin
  inherited;
  DialogService := TDialogService.Create;
  FPedido := TPedido.Create;
  ConfigurarGrid;
  HabilitarBotoes;
end;

procedure TfrmPedido.FormDestroy(Sender: TObject);
begin
  inherited;
  FreeObject(DialogService);
  FreeObject(FPedido);
end;

procedure TfrmPedido.ConfigurarGrid;
begin
  mtItens.Close;
  mtItens.FieldDefs.Clear;
  mtItens.FieldDefs.Add('codigo_produto', ftInteger);
  mtItens.FieldDefs.Add('descricao', ftString, 100);
  mtItens.FieldDefs.Add('quantidade', ftFloat);
  mtItens.FieldDefs.Add('valor_unitario', ftFloat);
  mtItens.FieldDefs.Add('valor_total', ftFloat);
  mtItens.CreateDataSet;

  grdItens.Columns[0].Header := 'Código';
  grdItens.Columns[0].Width := 70;

  grdItens.Columns[1].Header := 'Descrição';
  grdItens.Columns[1].Width := 250;


  grdItens.Columns[2].Header := 'Quantidade';
  grdItens.Columns[2].Width := 100;

  grdItens.Columns[3].Header := 'Vlr. Unit.';
  grdItens.Columns[3].Width := 100;

  grdItens.Columns[4].Header := 'Vlr. Total';
  grdItens.Columns[4].Width := 100;
end;

procedure TfrmPedido.CarregarCliente(ACodigo: Integer);
var
  Query: TFDQuery;
begin
  Query := TFDQuery.Create(nil);
  try
    Query.Connection := frmmain.FDConnection1;
    Query.SQL.Text := 
      'SELECT nome, cidade, uf FROM clientes WHERE codigo = :codigo';
    Query.ParamByName('codigo').AsInteger := ACodigo;
    Query.Open;

    if not Query.IsEmpty then
    begin
      edtNomeCliente.Text := Query.FieldByName('nome').AsString;
      edtCidadeCliente.Text := Query.FieldByName('cidade').AsString;
      edtUFCliente.Text := Query.FieldByName('uf').AsString;
      FPedido.CodigoCliente := ACodigo;
    end
    else
    begin
      Warning('Cliente não encontrado!');
      LimparCamposCliente;
    end;
  finally
    FreeObject(Query);
  end;
  
  HabilitarBotoes;
end;

procedure TfrmPedido.CarregarProduto(ACodigo: Integer);
var
  Query: TFDQuery;
begin
  Query := TFDQuery.Create(nil);
  try
    Query.Connection := frmmain.FDConnection1;
    Query.SQL.Text :=
      'SELECT descricao, preco_venda FROM produtos WHERE codigo = :codigo';
    Query.ParamByName('codigo').AsInteger := ACodigo;
    Query.Open;
    
    if not Query.IsEmpty then
    begin
      edtDescProduto.Text := Query.FieldByName('descricao').AsString;
      edtValorUnit.Text := FormatFloat('#,##0.00', Query.FieldByName('preco_venda').AsFloat);
      edtQuantidade.SetFocus;
    end
    else
    begin
      Warning('Produto não encontrado!');
      LimparCamposProduto;
    end;
  finally
    FreeObject(Query);
  end;
end;

procedure TfrmPedido.btnInserirItemClick(Sender: TObject);
var
  Item: TPedidoItem;
begin
  inherited;
  if not ValidarCampos then
    Exit;
    
  Item := TPedidoItem.Create;
  Item.CodigoProduto := StrToInt(edtCodProduto.Text);
  Item.DescricaoProduto := edtDescProduto.Text;
  Item.Quantidade := CustomStrToFloat(edtQuantidade.Text);
  Item.ValorUnitario := CustomStrToFloat(edtValorUnit.Text);
  Item.ValorTotal := Item.Quantidade * Item.ValorUnitario;
  
  FPedido.Itens.Add(Item);
  
  mtItens.Append;
  mtItens.FieldByName('codigo_produto').AsInteger := Item.CodigoProduto;
  mtItens.FieldByName('descricao').AsString := Item.DescricaoProduto;
  mtItens.FieldByName('quantidade').AsFloat := Item.Quantidade;
  mtItens.FieldByName('valor_unitario').AsFloat := Item.ValorUnitario;
  mtItens.FieldByName('valor_total').AsFloat := Item.ValorTotal;
  mtItens.Post;
  
  AtualizarTotalPedido;
  LimparCamposProduto;
end;

procedure TfrmPedido.grdItensKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  inherited;
  case Key of
    VK_RETURN:
      begin
        if not mtItens.IsEmpty then
        begin
          edtCodProduto.Text := mtItens.FieldByName('codigo_produto').AsString;
          edtDescProduto.Text := mtItens.FieldByName('descricao').AsString;
          edtQuantidade.Text := FormatFloat('#,##0.00', mtItens.FieldByName('quantidade').AsFloat);
          edtValorUnit.Text := FormatFloat('#,##0.00', mtItens.FieldByName('valor_unitario').AsFloat);
          
          mtItens.Delete;
          FPedido.Itens.Delete(mtItens.RecNo - 1);
          
          AtualizarTotalPedido;
          edtQuantidade.SetFocus;
        end;
      end;

    VK_DELETE:
      begin
        if not mtItens.IsEmpty then
        begin
          if MessageDlg('Deseja realmente excluir este item?', TMsgDlgType.mtConfirmation, [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo], 0) = mrYes then
          begin
            FPedido.Itens.Delete(mtItens.RecNo - 1);
            mtItens.Delete;
            AtualizarTotalPedido;
          end;
        end;
      end;
  end;
end;

procedure TfrmPedido.btnGravarPedidoClick(Sender: TObject);
Const
  Dot: TFormatSettings = (DecimalSeparator: '.');

begin
  inherited;
  if FPedido.Itens.Count = 0 then
  begin
    Warning('Adicione pelo menos um item ao pedido!');
    Exit;
  end;

  FPedido.DataEmissao := Date;
  FPedido.ValorTotal := CustomStrToFloat(edtTotalPedido.Text);

  if FPedido.Gravar then
  begin
    Warning('Pedido gravado com sucesso!' + #13 + 'Número: ' + IntToStr(FPedido.NumeroPedido));
    LimparTela;
  end;
end;

procedure TfrmPedido.btnCarregarPedidoClick(Sender: TObject);
var
  NumeroPedido: string;
begin
  inherited;
  if not InputQuery('Carregar Pedido', 'Informe o número do pedido:', NumeroPedido) then
    Exit;


  if FPedido.Carregar(StrToInt(NumeroPedido)) then
  begin
    edtCodCliente.Text := IntToStr(FPedido.CodigoCliente);
    CarregarCliente(FPedido.CodigoCliente);
    
    mtItens.EmptyDataSet;
    for var Item in FPedido.Itens do
    begin
      mtItens.Append;
      mtItens.FieldByName('codigo_produto').AsInteger := Item.CodigoProduto;
      mtItens.FieldByName('descricao').AsString := Item.DescricaoProduto;
      mtItens.FieldByName('quantidade').AsFloat := Item.Quantidade;
      mtItens.FieldByName('valor_unitario').AsFloat := Item.ValorUnitario;
      mtItens.FieldByName('valor_total').AsFloat := Item.ValorTotal;
      mtItens.Post;
    end;
    
    AtualizarTotalPedido;
  end
  else
    Warning('Pedido não encontrado!');
end;

procedure TfrmPedido.btnCancelarPedidoClick(Sender: TObject);
var
  NumeroPedido: string;
begin
  inherited;
  if not InputQuery('Cancelar Pedido', 'Informe o número do pedido:', NumeroPedido) then
    Exit;

  if Confirm('Confirma o cancelamento do pedido ' + NumeroPedido + '?') then
  begin
    if FPedido.Cancelar(StrToInt(NumeroPedido)) then
    begin
      Warning('Pedido cancelado com sucesso!');
      LimparTela;
    end
    else
      Warning('Pedido não encontrado!');
  end;
end;

procedure TfrmPedido.AtualizarTotalPedido;
var
  Total: Double;
begin
  Total := 0;
  mtItens.First;
  while not mtItens.Eof do
  begin
    Total := Total + mtItens.FieldByName('valor_total').AsFloat;
    mtItens.Next;
  end;
  
  edtTotalPedido.Text := FormatFloat('#,##0.00', Total);
end;

procedure TfrmPedido.LimparCamposProduto;
begin
  edtCodProduto.Text.Empty;
  edtDescProduto.Text.Empty;
  edtQuantidade.Text.Empty;
  edtValorUnit.Text.Empty;
  edtCodProduto.SetFocus;
end;

procedure TfrmPedido.LimparCamposCliente;
begin
  edtCodCliente.Text.Empty;
  edtNomeCliente.Text.Empty;
  edtCidadeCliente.Text.Empty;
  edtUFCliente.Text.Empty;
  FPedido.CodigoCliente := 0;
end;

procedure TfrmPedido.LimparTela;
begin
  LimparCamposCliente;
  LimparCamposProduto;
  mtItens.EmptyDataSet;
  edtTotalPedido.Text.Empty;
  FreeObject(FPedido);
  FPedido := TPedido.Create;
  HabilitarBotoes;
end;

procedure TfrmPedido.HabilitarBotoes;
begin
  btnCarregarPedido.Visible := FPedido.CodigoCliente = 0;
  btnCancelarPedido.Visible := FPedido.CodigoCliente = 0;
  btnGravarPedido.Enabled := FPedido.CodigoCliente > 0;
  btnInserirItem.Enabled := FPedido.CodigoCliente > 0;
end;

function TfrmPedido.ValidarCampos: Boolean;
begin
  Result := False;
  
  if Trim(edtCodProduto.Text) = '' then
  begin
    Warning('Informe o código do produto!');
    edtCodProduto.SetFocus;
    Exit;
  end;
  
  if Trim(edtQuantidade.Text) = '' then
  begin
    Warning('Informe a quantidade!');
    edtQuantidade.SetFocus;
    Exit;
  end;
  
  if StrToFloatDef(edtQuantidade.Text, 0) <= 0 then
  begin
    Warning('Quantidade deve ser maior que zero!');
    edtQuantidade.SetFocus;
    Exit;
  end;
  
  if Trim(edtValorUnit.Text) = '' then
  begin
    Warning('Informe o valor unitário!');
    edtValorUnit.SetFocus;
    Exit;
  end;
  
  if CustomStrToFloat(edtValorUnit.Text) <= 0 then
  begin
    Warning('Valor unitário deve ser maior que zero!');
    edtValorUnit.SetFocus;
    Exit;
  end;
  
  Result := True;
end;

procedure TfrmPedido.edtCodClienteExit(Sender: TObject);
begin
  inherited;
  if Trim(edtCodCliente.Text) <> '' then
    CarregarCliente(StrToIntDef(edtCodCliente.Text, 0));
end;

procedure TfrmPedido.edtCodProdutoExit(Sender: TObject);
begin
  inherited;
  if Trim(edtCodProduto.Text) <> '' then
    CarregarProduto(StrToIntDef(edtCodProduto.Text, 0));
end;

procedure TfrmPedido.btnBuscaClienteClick(Sender: TObject);
var
  CodigoCliente: Integer;

begin
  CodigoCliente := TfrmBuscaCliente.Executar;
  if CodigoCliente > 0 then
  begin
    edtCodCliente.Text := IntToStr(CodigoCliente);
    CarregarCliente(CodigoCliente);
  end;
end;

procedure TfrmPedido.btnBuscaProdutoClick(Sender: TObject);
var
  CodigoProduto: Integer;

begin
  CodigoProduto := TfrmBuscaProduto.Executar;
  if CodigoProduto > 0 then
  begin
    edtCodProduto.Text := IntToStr(CodigoProduto);
    CarregarProduto(CodigoProduto);
  end;
end;

end.
