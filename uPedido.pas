unit uPedido;

interface

uses
  System.SysUtils, System.Classes, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf,
  FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt, Data.DB,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client, fmmain,
  System.Generics.Collections;

type
  TPedidoItem = class
  private
    FCodigoProduto: Integer;
    FDescricaoProduto: string;
    FQuantidade: Double;
    FValorUnitario: Double;
    FValorTotal: Double;
  public
    property CodigoProduto: Integer read FCodigoProduto write FCodigoProduto;
    property DescricaoProduto: string read FDescricaoProduto write FDescricaoProduto;
    property Quantidade: Double read FQuantidade write FQuantidade;
    property ValorUnitario: Double read FValorUnitario write FValorUnitario;
    property ValorTotal: Double read FValorTotal write FValorTotal;
  end;

  TPedido = class
  private
    FNumeroPedido: Integer;
    FDataEmissao: TDateTime;
    FCodigoCliente: Integer;
    FValorTotal: Double;
    FItens: TObjectList<TPedidoItem>;
    
    function GetProximoNumeroPedido: Integer;
  public
    constructor Create;
    destructor Destroy; override;
    
    function Gravar: Boolean;
    function Carregar(ANumeroPedido: Integer): Boolean;
    function Cancelar(ANumeroPedido: Integer): Boolean;
    
    property NumeroPedido: Integer read FNumeroPedido write FNumeroPedido;
    property DataEmissao: TDateTime read FDataEmissao write FDataEmissao;
    property CodigoCliente: Integer read FCodigoCliente write FCodigoCliente;
    property ValorTotal: Double read FValorTotal write FValorTotal;
    property Itens: TObjectList<TPedidoItem> read FItens;
  end;

implementation


{ TPedido }

constructor TPedido.Create;
begin
  inherited;
  FItens := TObjectList<TPedidoItem>.Create(True);
end;

destructor TPedido.Destroy;
begin
  FItens.Free;
  inherited;
end;

function TPedido.GetProximoNumeroPedido: Integer;
var
  Query: TFDQuery;
begin
  Query := TFDQuery.Create(nil);
  try
    Query.Connection := frmmain.FDConnection1;
    Query.SQL.Text := 'SELECT COALESCE(MAX(numero_pedido), 0) + 1 AS proximo FROM pedidos';
    Query.Open;
    Result := Query.FieldByName('proximo').AsInteger;
  finally
    Query.Free;
  end;
end;

function TPedido.Gravar: Boolean;
var
  Transaction: TFDTransaction;
  QueryPedido, QueryItem: TFDQuery;
  Item: TPedidoItem;
begin
  Result := False;
  Transaction := TFDTransaction.Create(nil);
  QueryPedido := TFDQuery.Create(nil);
  QueryItem := TFDQuery.Create(nil);
  try
    Transaction.Connection := frmmain.FDConnection1;
    QueryPedido.Connection := frmmain.FDConnection1;
    QueryItem.Connection := frmmain.FDConnection1;

    Transaction.StartTransaction;
    try
      if FNumeroPedido = 0 then
        FNumeroPedido := GetProximoNumeroPedido;

      // Grava cabeçalho do pedido
      QueryPedido.SQL.Text :=
        'INSERT INTO pedidos (numero_pedido, data_emissao, codigo_cliente, valor_total) ' +
        'VALUES (:numero_pedido, :data_emissao, :codigo_cliente, :valor_total)';
        
      QueryPedido.ParamByName('numero_pedido').AsInteger := FNumeroPedido;
      QueryPedido.ParamByName('data_emissao').AsDate := FDataEmissao;
      QueryPedido.ParamByName('codigo_cliente').AsInteger := FCodigoCliente;
      QueryPedido.ParamByName('valor_total').AsFloat := FValorTotal;
      QueryPedido.ExecSQL;

      // Grava itens do pedido
      for Item in FItens do
      begin
        QueryItem.SQL.Text :=
          'INSERT INTO pedidos_produtos (numero_pedido, codigo_produto, quantidade, ' +
          'valor_unitario, valor_total) VALUES (:numero_pedido, :codigo_produto, ' +
          ':quantidade, :valor_unitario, :valor_total)';
          
        QueryItem.ParamByName('numero_pedido').AsInteger := FNumeroPedido;
        QueryItem.ParamByName('codigo_produto').AsInteger := Item.CodigoProduto;
        QueryItem.ParamByName('quantidade').AsFloat := Item.Quantidade;
        QueryItem.ParamByName('valor_unitario').AsFloat := Item.ValorUnitario;
        QueryItem.ParamByName('valor_total').AsFloat := Item.ValorTotal;
        QueryItem.ExecSQL;
      end;

      Transaction.Commit;
      Result := True;
    except
      Transaction.Rollback;
      raise;
    end;
  finally
    Transaction.Free;
    QueryPedido.Free;
    QueryItem.Free;
  end;
end;

function TPedido.Carregar(ANumeroPedido: Integer): Boolean;
var
  QueryPedido, QueryItens: TFDQuery;
  Item: TPedidoItem;
begin
  Result := False;
  QueryPedido := TFDQuery.Create(nil);
  QueryItens := TFDQuery.Create(nil);
  try
    QueryPedido.Connection := frmmain.FDConnection1;
    QueryItens.Connection := frmmain.FDConnection1;

    // Carrega dados do pedido
    QueryPedido.SQL.Text :=
      'SELECT * FROM pedidos WHERE numero_pedido = :numero_pedido';
    QueryPedido.ParamByName('numero_pedido').AsInteger := ANumeroPedido;
    QueryPedido.Open;

    if QueryPedido.IsEmpty then
      Exit;

    FNumeroPedido := QueryPedido.FieldByName('numero_pedido').AsInteger;
    FDataEmissao := QueryPedido.FieldByName('data_emissao').AsDateTime;
    FCodigoCliente := QueryPedido.FieldByName('codigo_cliente').AsInteger;
    FValorTotal := QueryPedido.FieldByName('valor_total').AsFloat;

    // Carrega itens do pedido
    FItens.Clear;
    QueryItens.SQL.Text :=
      'SELECT p.*, pr.descricao FROM pedidos_produtos p ' +
      'INNER JOIN produtos pr ON pr.codigo = p.codigo_produto ' +
      'WHERE p.numero_pedido = :numero_pedido';
    QueryItens.ParamByName('numero_pedido').AsInteger := ANumeroPedido;
    QueryItens.Open;

    while not QueryItens.Eof do
    begin
      Item := TPedidoItem.Create;
      Item.CodigoProduto := QueryItens.FieldByName('codigo_produto').AsInteger;
      Item.DescricaoProduto := QueryItens.FieldByName('descricao').AsString;
      Item.Quantidade := QueryItens.FieldByName('quantidade').AsFloat;
      Item.ValorUnitario := QueryItens.FieldByName('valor_unitario').AsFloat;
      Item.ValorTotal := QueryItens.FieldByName('valor_total').AsFloat;
      FItens.Add(Item);
      
      QueryItens.Next;
    end;

    Result := True;
  finally
    QueryPedido.Free;
    QueryItens.Free;
  end;
end;

function TPedido.Cancelar(ANumeroPedido: Integer): Boolean;
var
  Transaction: TFDTransaction;
  Query: TFDQuery;
begin
  Result := False;
  Transaction := TFDTransaction.Create(nil);
  Query := TFDQuery.Create(nil);
  try
    Transaction.Connection := frmmain.FDConnection1;
    Query.Connection := frmmain.FDConnection1;
    
    Transaction.StartTransaction;
    try
      // Remove itens do pedido
      Query.SQL.Text := 'DELETE FROM pedidos_produtos WHERE numero_pedido = :numero_pedido';
      Query.ParamByName('numero_pedido').AsInteger := ANumeroPedido;
      Query.ExecSQL;

      // Remove pedido
      Query.SQL.Text := 'DELETE FROM pedidos WHERE numero_pedido = :numero_pedido';
      Query.ParamByName('numero_pedido').AsInteger := ANumeroPedido;
      Query.ExecSQL;

      Transaction.Commit;
      Result := True;
    except
      Transaction.Rollback;
      raise;
    end;
  finally
    Transaction.Free;
    Query.Free;
  end;
end;

end.
