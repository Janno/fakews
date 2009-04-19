program fakews_exe;

{$APPTYPE CONSOLE}

uses
  SysUtils, uallHook, uallUtil, Windows;

function RunProcess(FileName: string; ShowCmd: DWORD; wait: Boolean; ProcID: PCardinal): Longword;
var
  StartupInfo: TStartupInfo;
  ProcessInfo: TProcessInformation;
begin
  FillChar(StartupInfo, SizeOf(StartupInfo), #0);
  StartupInfo.cb          := SizeOf(StartupInfo);
  StartupInfo.dwFlags     := STARTF_USESHOWWINDOW or STARTF_FORCEONFEEDBACK;
  StartupInfo.wShowWindow := ShowCmd;
  if not CreateProcess(nil,
    @Filename[1],
    nil,
    nil,
    False,
    CREATE_NEW_CONSOLE or
    NORMAL_PRIORITY_CLASS,
    nil,
    nil,
    StartupInfo,
    ProcessInfo)
    then
      Result := WAIT_FAILED
  else
  begin
    if wait = FALSE then
    begin
      if ProcID <> nil then ProcID^ := ProcessInfo.dwProcessId;
      exit;
    end;
    WaitForSingleObject(ProcessInfo.hProcess, INFINITE);
    GetExitCodeProcess(ProcessInfo.hProcess, Result);
  end;
  if ProcessInfo.hProcess <> 0 then
    CloseHandle(ProcessInfo.hProcess);
  if ProcessInfo.hThread <> 0 then
    CloseHandle(ProcessInfo.hThread);
end;

var PID: Cardinal;
begin
        if ParamCount() < 1 then begin
                WriteLn(Output,'Parameters:');
                WriteLn(Output, '1. Application to be executed.')
        end
        else begin
                RunProcess(ParamStr(1), SW_RESTORE, FALSE, @PID);
                WriteLn(Output, 'Injecting '+ExtractFilePath(ParamStr(0))+'fakews.dll');
                if InjectLibrary(PID,pchar(ExtractFilePath(ParamStr(0))+'fakews.dll')) then begin
                        WriteLn(Output, 'Hook injected.');
                end
                else begin
                        WriteLn(Output, 'Hook failed!');
                end;
        end;
end.
