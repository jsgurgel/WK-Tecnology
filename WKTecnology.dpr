program WKTecnology;

uses
  System.StartUpCopy,
  FMX.Forms,
  fmmain in 'fmmain.pas' {frmMain},
  uFrmPedido in 'uFrmPedido.pas' {frmPedido},
  uPedido in 'uPedido.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.
