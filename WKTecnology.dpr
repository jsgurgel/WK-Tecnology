program WKTecnology;

uses
  System.StartUpCopy,
  FMX.Forms,
  fmmain in 'fmmain.pas' {frmMain},
  uFrmPedido in 'uFrmPedido.pas' {frmPedido},
  uPedido in 'uPedido.pas',
  uFrmBuscaCliente in 'uFrmBuscaCliente.pas' {frmBuscaCliente},
  fmFormPatterns in 'fmFormPatterns.pas' {frmFormPatterns},
  uFrmBuscaProduto in 'uFrmBuscaProduto.pas' {frmBuscaProduto},
  uFrmCadastroCliente in 'uFrmCadastroCliente.pas' {frmCadastroCliente},
  krUtil in 'krUtil.pas',
  uFrmCadastroProduto in 'uFrmCadastroProduto.pas' {frmCadastroProduto};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfrmMain, frmMain);
  Application.CreateForm(TfrmFormPatterns, frmFormPatterns);
  Application.Run;
end.
