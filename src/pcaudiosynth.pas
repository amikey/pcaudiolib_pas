program pcaudiosynth;

{$mode objfpc}{$H+}
   {$DEFINE UseCThreads}
uses
{$IFDEF UNIX}
  cthreads, 
  cwstring, {$ENDIF}
  Classes,
  SysUtils,
  ctypes,
  CustApp,
  pcaudio;

type

  TConsole = class(TCustomApplication)
  private
    procedure ConsolePlay;
  protected
    procedure doRun; override;
  public
    constructor Create(TheOwner: TComponent); override;
  end;

var
freqsine : cfloat = 440.0;
samplerate : cfloat = 44100.0;
audioobj : paudio_object = nil;
lensine : cfloat;
posLsine, posRsine : integer;
ordir, pc_FileName: string;
x : integer = 0;
pf : array of cfloat; 

procedure ReadSynth;  
var
x2 : integer = 0;
begin

 while x2 < length(pf) -1 do

  begin
  pf[x2] :=  Sin( ( ((x2 div 2)+ posLsine)/ lensine ) * Pi * 2 ) ;
  pf[x2+1] :=  Sin( ( ((x2 div 2) + posRsine)/lensine ) * Pi * 2 );
  
  
     if posLsine +1 > lensine -1 then posLsine := 0 else
  posLsine := posLsine +1 ;

  if posRsine +1 > lensine -1 then posRsine := 0 else
  posRsine := posRsine +1 ;


  x2 := x2 + 2 ;
  end;

end;

  procedure TConsole.ConsolePlay;
  begin
    ordir := IncludeTrailingBackslash(ExtractFilePath(ParamStr(0)));
     pc_FileName := ordir + 'libpcaudio.so.0';
    if pc_load(pc_FileName ) then
    writeln('libpcaudio.so.0 loaded') else
    writeln('libpcaudio.so.0 NOT loaded');
    
   lensine := samplerate / freqsine *2 ; 
   posLsine := 0 ;
   posRsine := 0 ;

   setlength(pf,1024);
      
   audioobj := create_audio_device_object(nil, nil, nil);
   
     if audioobj = nil then
    writeln('audioobj = nil ;(') else
    writeln('audioobj assigned');

   audio_object_open(audioobj, AUDIO_OBJECT_FORMAT_FLOAT32LE, 44100,2);

  while x < 150 do
begin
ReadSynth;
audio_object_write(audioobj,@pf[0], 512); 
audio_object_flush(audioobj);
audio_object_drain(audioobj); 
inc(x);
end;

 audio_object_close(audioobj);
 audio_object_destroy(audioobj);

 end;

  procedure TConsole.doRun;
  begin
    ConsolePlay;
 //   writeln('Press a key to exit...');
 //   readln;
   writeln('Ciao...');
    pc_unload(); // Do not forget this !
    Terminate;   
  end;

constructor TConsole.Create(TheOwner: TComponent);
  begin
    inherited Create(TheOwner);
    StopOnException := True;
  end;

var
  Application: TConsole;
begin
  Application := TConsole.Create(nil);
  Application.Title := 'Sine-Wave and Pcaudiolib';
  Application.Run;
  Application.Free;
end.