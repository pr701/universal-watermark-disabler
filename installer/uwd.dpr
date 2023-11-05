program uwd;

uses
  Forms,
  uMain in 'uMain.pas' {frmMain};

//{$R *.res}

begin
  Application.Initialize;
  Application.Title := 'Universal Watermark Disabler';
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.
