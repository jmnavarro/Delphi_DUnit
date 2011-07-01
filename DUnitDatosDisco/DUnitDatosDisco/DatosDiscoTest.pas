unit DatosDiscoTest;

interface

uses TestFramework, DatosDisco, dialogs;

type
        TDatosDiscoTest = class(TTestCase)
        private
                FFixture: TDatosDisco;

                function AbrirFichero(nombre: string; var size: LongWord): THandle;
                function SonFicherosIguales(f1, f2: string): boolean;
        public
                procedure Setup; override;
                procedure TearDown; override;

                class function Suite: ITestSuite; override;

        published
                procedure TestLeer;
                procedure TestGuardar;
                procedure TestExcepcion;
        end;

implementation

uses Windows, SysUtils;

const
        FICHERO_PATRON = 'patron.dat';
        NUMERO_PATRON = 10;
        CADENA_PATRON = 'esta es la cadena de prueba';


function TDatosDiscoTest.AbrirFichero(nombre: string; var size: LongWord): THandle;
var
	sizeHigh, sizeLow: DWORD;
begin
	result := CreateFile(PChar(nombre), GENERIC_READ, FILE_SHARE_READ, nil, OPEN_EXISTING, FILE_FLAG_SEQUENTIAL_SCAN, 0);
	if result <> INVALID_HANDLE_VALUE then
        begin
        	sizeLow := GetFileSize(result, @sizeHigh);
                if (sizeLow <> $FFFFFFFF) or (GetLastError = NO_ERROR) then
                        size := (sizeHigh shl 32) or sizeLow;
        end;
end;


function TDatosDiscoTest.SonFicherosIguales(f1, f2: string): boolean;
const
        CHUNK_SIZE = 256;
var
	buff1: array[0..CHUNK_SIZE-1] of Byte;
        buff2: array[0..CHUNK_SIZE-1] of Byte;
	size1, size2: LongWord;
	h1, h2: THandle;
        read2, read1: DWORD;
begin
        h1 := AbrirFichero(f1, size1);
        h2 := AbrirFichero(f2, size2);

        result := (size1 = size2);

        if result then
        begin
                read1 := 1;
                while result and (read1 > 0) do
                begin
                        ReadFile(h1, buff1, CHUNK_SIZE, read1, nil);
                        ReadFile(h2, buff2, CHUNK_SIZE, read2, nil);

                        result := (read1 = read2);
                        if result then
                        begin
                                result := (read1 <= 0) or CompareMem(@buff1[0], @buff2[0], read1);
                        end;
                end;
        end;

	CloseHandle(h1);
	CloseHandle(h2);
end;


class function TDatosDiscoTest.Suite: ITestSuite;
begin
        Result := TTestSuite.Create(self);
end;

procedure TDatosDiscoTest.Setup;
begin
        inherited;
        FFixture := TDatosDisco.Create;
end;

procedure TDatosDiscoTest.TearDown;
begin
        FFixture.Free;
        inherited;
end;

procedure TDatosDiscoTest.TestLeer;
begin
        // se ejecuta la acción...
        CheckTrue( FFixture.Leer(FICHERO_PATRON) );

        // ...y se comprueban los resultados
        CheckEquals(NUMERO_PATRON, FFixture.Dato.numero );
        CheckEquals(CADENA_PATRON, FFixture.Dato.cadena );
end;

procedure TDatosDiscoTest.TestGuardar;
const
        FICHERO_TMP = 'copia.tmp';
var
        d: TDatos;
begin
        DeleteFile(FICHERO_TMP);

        d.numero := NUMERO_PATRON;
        d.cadena := CADENA_PATRON;

        { se ejecuta la acción... }
        FFixture.Dato := d;
        Check( FFixture.Guardar(FICHERO_TMP) );
        try
                { ...y se comprueban los resultados }
                { El contenido del temporal debe ser el mismo que el del patrón }
                { Para ello utilizo una función auxiliar que compara el }
                { contenido de dos ficheros. }
                CheckTrue(SonFicherosIguales(FICHERO_TMP, FICHERO_PATRON));
        finally
                DeleteFile(FICHERO_TMP);
        end;
end;

procedure TDatosDiscoTest.TestExcepcion;
var
        d: TDatos;
        error: boolean;
begin
        d.numero := 123;
        d.cadena := '';
        try
                FFixture.Dato := d;
                error := true;
        except
                error := false;
        end;

        if error then
        begin
                Fail('Se esperaba una excepción');
        end;
end;


initialization
  RegisterTests([TDatosDiscoTest.Suite]);

end.
