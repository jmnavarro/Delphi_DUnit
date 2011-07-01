program DUnitDatosDisco;

uses
  Forms,
  GUITestRunner,
  DatosDisco in 'DatosDisco.pas',
  DatosDiscoTest in 'DatosDiscoTest.pas';

{$R *.res}

begin
  Application.Initialize;
  TGUITestRunner.RunRegisteredTests;
end.
