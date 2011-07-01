unit DatosDisco;

interface

type
        TDatos = record
                numero: integer;
                cadena: string;
        end;

        TDatosDisco = class(TObject)
        private
                FDato: TDatos;

                function GetDato: TDatos;
                procedure SetDato(const value: TDatos);

        public
                constructor Create;
                destructor Destroy; override;

                function Leer(const archivo: string): boolean;
                function Guardar(const archivo: string): boolean;

                property Dato: TDatos read GetDato write SetDato;
        end;

implementation

uses Windows, SysUtils;


constructor TDatosDisco.Create;
begin
        inherited;
end;

destructor TDatosDisco.Destroy;
begin
        inherited;
end;


function TDatosDisco.GetDato: TDatos;
begin
        result := FDato;
end;

procedure TDatosDisco.SetDato(const value: TDatos);
begin
        if value.cadena = '' then
                raise Exception.Create('No se permiten cadenas vacías')
        else
                FDato := value;
end;


function TDatosDisco.Leer(const archivo: string): boolean;
var
        h: THandle;
        leido: DWORD;
        buff: array[0..255] of char;
begin
	h := CreateFile(PChar(archivo), GENERIC_READ, FILE_SHARE_READ, nil, OPEN_EXISTING, 0, 0);
        result := (h <> INVALID_HANDLE_VALUE);
       	if result then
        begin
                ReadFile(h, FDato.numero, sizeof(FDato.numero), leido, nil);

                FillChar(buff, 256, #0);
                ReadFile(h, buff, 255, leido, nil);
                SetLength(FDato.cadena, StrLen(buff));
                FDato.cadena := buff;

                CloseHandle(h);
        end;
end;

function TDatosDisco.Guardar(const archivo: string): boolean;
var
        h: THandle;
        escrito: DWORD;
        buff: array[0..255] of char;
begin
	h := CreateFile(PChar(archivo), GENERIC_WRITE, 0, nil, CREATE_NEW, 0, 0);
        result := (h <> INVALID_HANDLE_VALUE);
       	if result then
        begin
                WriteFile(h, FDato.numero, sizeof(FDato.numero), escrito, nil);

                FillChar(buff, 256, #0);
                StrLCopy(buff, PChar(FDato.cadena), 255);
                WriteFile(h, buff, StrLen(buff), escrito, nil);
                CloseHandle(h);
        end;
end;



end.
