unit UnitMultInst;
 
interface
 
const
  MI_QUERYWINDOWHANDLE=1;
  MI_RESPONWINDOWHANDLE=2;
 
  MI_ERROR_NONE=0;
  MI_ERROR_FAILSUBCLASS=1;
  MI_ERROR_CREATINGMUTEX=2;
 
  // Call this function to determine if there are startup errors.
  // The value will be one or more MI_ERROR_* error flags
  function GetMIError: Integer;
 
implementation
 
uses
  Forms, Windows, SysUtils;
 
const
  UniqueAppStr = 'UniversalWatermarkDisabler';
 
var
  MessageId: integer;
  WProc: TFNWndProc;
  MutHandle: THandle;
  MIError: integer;
 
function GetMIError: Integer;
begin
  Result:=MIError;
end;
 
function NewWndProc(Handle: HWND; Msg: Integer; wParam, lParam: Longint): Longint; stdcall;
begin
  Result:=0;
  // if registered message...
  if Msg = MessageId then
  begin
    case wParam of
      MI_QUERYWINDOWHANDLE:
        { The new application instance requests a handle to the main window to give it focus,
          so it needs to restore the application window to its normal state
          and send a response message with the handle of main window. }
      begin
        if IsIconic(Application.Handle) then
        begin
          Application.MainForm.WindowState:=wsNormal;
          Application.Restore;
        end;
        PostMessage(HWND(lParam), MessageId, MI_RESPONWINDOWHANDLE, Application.MainForm.Handle);
      end;
      MI_RESPONWINDOWHANDLE:
      // Set focus and terminate this instance
      begin
        SetForegroundWindow(HWND(lParam));
        Application.Terminate;
      end;
    end;
  end
  // Otherwise, we send a message to old window procedure.
  else
  Result:=CallWindowProc(WProc, Handle, Msg, wParam, lParam);
end;
 
procedure SubClassApplication;
begin
  WProc:=TFNWndProc(SetWindowLong(Application.Handle, GWL_WNDPROC, Longint(@NewWndProc)));
  if WProc=nil then
  MIError:=MIError{ or MI_FAIL_SUBCLASS};
end;
 
procedure DoFirstInstance;
begin
  MutHandle:=CreateMutex(nil, false, UniqueAppStr);
  if MutHandle=0 then
  MIError:=MIError or MI_ERROR_CREATINGMUTEX;
end;
 
procedure BroadcastFocusMessage;
var
  BSMRecipients: DWORD;
begin
  BSMRecipients:=BSM_APPLICATIONS;
  BroadCastSystemMessage(BSF_IGNORECURRENTTASK or BSF_POSTMESSAGE, @BSMRecipients, MessageId, MI_QUERYWINDOWHANDLE, Application.Handle);
end;
 
procedure InitInstance;
begin
  SubClassApplication; // Replacing an application window procedure
  MutHandle:=CreateMutex(nil, false, UniqueAppStr);
  if MutHandle=0 then
  DoFirstInstance
  else
  BroadcastfocusMessage;
end;
 
initialization
  MessageId:=RegisterWindowMessage(UniqueAppStr);
  InitInstance;
 
finalization
  if WProc<>nil then
  // Restoring the old window procedure
  SetWindowLong(Application.Handle, GWL_WNDPROC, LongInt(WProc));
  if MutHandle<>0 then CloseHandle(MutHandle); // Free mutex
 
end.