unit uMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Registry, ShellAPI, SysFoldersUnicode, ExtCtrls, NTCommon,
  AbstrSec, RegSecur, VistaAltFixUnit, UnitMultInst;

type
  TfrmMain = class(TForm)
    pnlBottom: TPanel;
    btnInstall: TButton;
    grpInf: TGroupBox;
    grpAbt: TGroupBox;
    shpPanel: TShape;
    lblPtr: TLabel;
    lblEdition: TLabel;
    lblVerApi: TLabel;
    lblVerReg: TLabel;
    lblVerReg_m: TLabel;
    lblVerApi_m: TLabel;
    lblEdition_m: TLabel;
    lblStatus_m: TLabel;
    lblStatus: TLabel;
    lblThx: TLabel;
    lblTihiyWeb: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure lblTihiyWebMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure lblTihiyWebMouseLeave(Sender: TObject);
    procedure lblTihiyWebClick(Sender: TObject);
    procedure btnInstallClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

resourcestring
  scEdition = 'Edition:';
  scBuild   = 'Build (API):';
  scBuildEx = 'Build (Registry):';
  scStCaption = 'Status:';


  scInf = 'Status';
  scAbt = 'Information';
  scInstall = 'Install';
  scUnistall = 'Uninstall';

  scError = 'Error';
  scWarning = 'Warning';
  scErrorCLSID = 'CLSID Access Error!';
  scCorrupt = 'System resources are damaged';
  scErrorReadString = 'An error occurred while reading the registry.';
  scNotSup = 'The current OS is not supported!';
  scReady = 'Ready for installation';
  scInstalled = 'Installed';
  scAnotherProxy = 'Another proxy installed';
  scUntested = 'You are going to install on the untested build. Continue?';
  scLogoff = 'You will be signed out automatically. Save all your work and click OK';
  scThxTihiy = 'Many thanks to Tihiy!';

const
  SE_PRIVILEGE_ENABLED = $00000002;
  SE_PRIVILEGE_DISABLED = $00000000;
  TOKEN_QUERY = $00000008;
  TOKEN_ADJUST_PRIVILEGES = $00000020;

  MIN_SUP_BUILD = 7850;
  MAX_SUP_BUILD = 10240;

  scMainTittle = 'Universal Watermark Disabler';

  scBackup = '%SystemRoot%\system32\explorerframe.dll';
  scVersionKey = 'SOFTWARE\Microsoft\Windows NT\CurrentVersion';
  scRoot = 'HKEY_CLASSES_ROOT';
  scCLSIDKey = 'CLSID\{ab0b37ec-56f6-4a0e-a8fd-7a8bf7c2da96}\InProcServer32';
  scProductName = 'ProductName';
  scCurVer = 'CurrentVersion';
  scBuildLabEx= 'BuildLabEx';
  scExplorer = 'explorer.exe';
  //scMS = 'Microsoft Corporation';
  scMS = 'ExplorerFrame';
  scPainter = 'painter';
  scPtr = 'PainteR, 2015';

  scSite = 'www.StartIsBack.com';
  //scStatus = '%s';
  scProxy = 'PROXY';
  scLib86 = 'System32\painter_x86.dll';
  scLib64 = 'System32\painter_x64.dll';

var
  frmMain: TfrmMain;
  OldWow64RedirectionValue: LongBool;
  bUnistall,
  bIsWin64: Boolean;

implementation

{$R ver.res}
{$R *.dfm}

procedure TfrmMain.lblTihiyWebMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  lblTihiyWeb.Font.Style:=[fsUnderline];
end;

procedure TfrmMain.lblTihiyWebMouseLeave(Sender: TObject);
begin
  lblTihiyWeb.Font.Style:=[];
end;

procedure TfrmMain.lblTihiyWebClick(Sender: TObject);
var
  Web: WideString;
begin
  case GetSystemDefaultLangID of
  $0419: Web := 'http://startisback.com/index.ru.html';
  else Web := 'http://startisback.com/';
  end;
  ShellExecuteW(0, 'open', PWideChar(Web), nil, nil, SW_SHOW);
end;

function ReadRegistryKey(Root: Integer; Key,Value: WideString): WideString;
const
  KEY_WOW64_64KEY = $100;
  KEY_WOW64_32KEY = $200;
var
  Reg: TRegistry ;
begin
  Result := '';
  Reg := TRegistry.Create(KEY_READ or KEY_WOW64_64KEY);
  try
    with Reg do
    begin
    RootKey := Root;
      if OpenKey(Key, False) then
        if ValueExists(Value) then
        Result := ReadString(Value);
    end;
  finally
    Reg.Free;
  end ;
end;

function RegSetValue(RootKey: HKEY; Name: String; ValType: Cardinal; PVal: Pointer; ValSize: Cardinal): boolean;
const
  KEY_WOW64_64KEY = $100;
var
  SubKey: String;
  n: integer;
  dispo: DWORD;
  hTemp: HKEY;
begin
  Result := False;
    if RegCreateKeyEx(RootKey, PChar(Name), 0, nil, REG_OPTION_NON_VOLATILE, KEY_WOW64_64KEY or KEY_WRITE,
      nil, hTemp, @dispo) = ERROR_SUCCESS then
    begin
      SubKey := '';
      Result := (RegSetValueEx(hTemp, PChar(SubKey), 0, ValType, PVal, ValSize) = ERROR_SUCCESS);
      RegCloseKey(hTemp);
    end;
end;

function WriteRegistryKey(RootKey: HKEY; Name: String; Value: String): boolean;
begin
  Result := RegSetValue(RootKey, Name, REG_EXPAND_SZ, PChar(Value + #0), Length(Value) + 1);
end;

function CmpStr(sFirst,sSecond: WideString): Boolean;
begin
  Result := False;
  if UpperCase(sFirst) = UpperCase(sSecond) then
    Result := True;
end;

function CorruptString(var usString: WideString): Boolean;
begin
  Result := False;
  if (Length(usString) = 0) or (usString[1] = ' ') then
    Result := True;
end;

function BrandingLoadString(): WideString;
type
  TBrandingLoadString = function(pString: WideString; uID: Integer; wc: Pointer; buff: integer): integer;
  stdcall;
var
  DLLHandle: THandle;
  pBrandingLoadString: TBrandingLoadString;
  Branding: Integer;
  buffer: array[0..127] of WideChar;
  wsBrand: WideString;
begin
  Result := '';
  DllHandle := LoadLibrary('winbrand.dll');
  if DLLHandle <> 0 then
  begin
    pBrandingLoadString:= GetProcAddress(DLLHandle, 'BrandingLoadString');
    if @pBrandingLoadString <> nil then
    begin
      Branding := pBrandingLoadString('Basebrd',12,@buffer,Length(buffer));
      if Branding <> 0 then
        SetString(wsBrand, Buffer, Branding);
        if not CorruptString(wsBrand) then
          Result := wsBrand;
    end;
    FreeLibrary(DLLHandle);
  end;
end;

function LoadWindowsEditionString(): WideString;
begin
  Result := BrandingLoadString;
  if CorruptString(Result) then
  begin
    Result := ReadRegistryKey(HKEY_LOCAL_MACHINE,scVersionKey,scProductName);
    if CorruptString(Result) then
      Result := scCorrupt;
  end;
end;

function GetVerWinAPI(): WideString;
var
  tv: TOSVersionInfo;
begin
  //FillChar(tv, SizeOf(tv), 0);
  tv.dwOSVersionInfoSize := SizeOf(tv);
  GetVersionEx(tv);
  Result := IntToStr(tv.dwMajorVersion)+'.'+IntToStr(tv.dwMinorVersion)+'.'+IntToStr(tv.dwBuildNumber);
end;

function GetVerWinRegistry(): WideString;
var
  BuildEx: WideString;
begin
  Result := ReadRegistryKey(HKEY_LOCAL_MACHINE,scVersionKey,scCurVer);
  if CorruptString(Result) then
    Result := scErrorReadString else
    begin
      BuildEx := ReadRegistryKey(HKEY_LOCAL_MACHINE,scVersionKey,scBuildLabEx);
      if CorruptString(BuildEx) then
        Result := scErrorReadString else
        Result := Result+'.'+BuildEx;
    end;
end;

procedure Localize;
begin
  with frmMain do
  begin
    grpInf.Caption := scInf;
    grpAbt.Caption := scAbt;
    lblPtr.Caption := scPtr;
    lblEdition.Caption := scInstall;

    lblEdition_m.Caption := scEdition;
    lblVerApi_m.Caption := scBuild;
    lblVerReg_m.Caption := scBuildEx;
    lblStatus_m.Caption := scStCaption;

    lblEdition.Caption := LoadWindowsEditionString;
    lblVerApi.Caption := GetVerWinAPI;
    lblVerReg.Caption := GetVerWinRegistry;

    btnInstall.Caption := scInstall;

    lblThx.Caption := scThxTihiy;

    lblTihiyWeb.Caption := scSite;
  end;
end;

function Is64BitWindows: boolean;
type
  TIsWow64Process = function(hProcess: THandle; var Wow64Process: BOOL): BOOL;
    stdcall;
var
  DLLHandle: THandle;
  pIsWow64Process: TIsWow64Process;
  IsWow64: BOOL;
begin
  Result := False;
  DllHandle := LoadLibrary('kernel32.dll');
  if DLLHandle <> 0 then
  begin
    pIsWow64Process:= GetProcAddress(DLLHandle, 'IsWow64Process');
    Result := Assigned(pIsWow64Process)
      and pIsWow64Process(GetCurrentProcess, IsWow64) and IsWow64;
    FreeLibrary(DLLHandle);
  end;
end;

function DisableWowRedirection: Boolean;
type
  TWow64DisableWow64FsRedirection = function(var Wow64FsEnableRedirection: LongBool): LongBool;
  StdCall;
var hHandle: THandle;
  Wow64DisableWow64FsRedirection: TWow64DisableWow64FsRedirection;
begin Result := true;
  try hHandle := GetModuleHandle('kernel32.dll');
    @Wow64DisableWow64FsRedirection := GetProcAddress(hHandle, 'Wow64DisableWow64FsRedirection');
    if ((hHandle <> 0) and (@Wow64DisableWow64FsRedirection <> nil)) then Wow64DisableWow64FsRedirection(OldWow64RedirectionValue);
  except Result := False;
  end;
end;

function RevertWowRedirection: Boolean;
type
  TWow64RevertWow64FsRedirection = function(var Wow64RevertWow64FsRedirection: LongBool): LongBool;
  StdCall;
var hHandle: THandle;
  Wow64RevertWow64FsRedirection: TWow64RevertWow64FsRedirection;
begin Result := true;
  try hHandle := GetModuleHandle('kernel32.dll');
    @Wow64RevertWow64FsRedirection := GetProcAddress(hHandle, 'Wow64RevertWow64FsRedirection');
    if ((hHandle <> 0) and (@Wow64RevertWow64FsRedirection <> nil)) then Wow64RevertWow64FsRedirection(OldWow64RedirectionValue);
  except Result := False;
  end;
end;

function ExpandEnvStr(const szInput: WideString): WideString;
const
  MAXSIZE = 32768;
begin
  SetLength(Result,MAXSIZE);
  SetLength(Result,ExpandEnvironmentStringsW(PWideChar(szInput),
    @Result[1],length(Result)));
end;

procedure EnableInstall(sStatus: WideString);
begin
  with frmMain do
  begin
    btnInstall.Enabled := True;
    if not bUnistall then btnInstall.Caption := scInstall else
      btnInstall.Caption := scUnistall;
    lblStatus.Caption := sStatus;
    lblStatus.Font.Color := clGreen;
  end;
end;

procedure DisableInstall(sText,sCaption: WideString; bShowStatus: Boolean);
begin
  if not bShowStatus then
  MessageBoxW(Application.Handle,PWideChar(WideString(sText)),PWideChar(WideString(sCaption)),MB_ICONERROR+MB_OK) else
  with frmMain do
  begin
    btnInstall.Enabled := False;
    lblStatus.Caption := sText;
    lblStatus.Font.Color := clRed;
  end;
end;

function LoadVerString(var sFile: WideString): WideString;
var
  VISize,buffsize,VersionInfoSize: cardinal;
  VIBuff,trans: pointer;
  temp: integer;
  str: PWideChar;
  LangCharSet,LanguageInfo: WideString;
  
function GetStringValue(const From: string): string;
  begin
    VerQueryValueW(VIBuff,PWideChar('\StringFileInfo\'+LanguageInfo+'\'+From),pointer(str),buffsize);
    if buffsize > 0 then Result := str else Result := 'n/a';
  end;

begin
  VIBuff := nil;
  VISize := GetFileVersionInfoSizeW(PWideChar(sFile),buffsize);
  //VersionInfoSize := VISize;
  if VISize < 1 then
    Result:='' else
  begin
    VIBuff := AllocMem(VISize);
    GetFileVersionInfoW(PWideChar(sFile),cardinal(0),VISize,VIBuff);
    //li := ;
    VerQueryValueW(VIBuff,PWideChar(WideString('\VarFileInfo\Translation')),Trans,buffsize);
    if buffsize >= 4 then
    begin
      temp:=0;
      StrLCopy(@temp, PChar(Trans),2);
      LangCharSet:=IntToHex(temp, 4);
      StrLCopy(@temp, PChar(Trans)+2,2);
      LanguageInfo := LangCharSet+IntToHex(temp, 4);

      //Result := GetStringValue('CompanyName');
      Result := GetStringValue('InternalName');
    end else Result:='';
    FreeMem(VIBuff,VISize);
  end;
end;

procedure CheckCLSID();
var
  tv: TOSVersionInfo;
  sPath: WideString;
begin
  tv.dwOSVersionInfoSize := SizeOf(tv);
  GetVersionEx(tv);
  if (tv.dwBuildNumber < MIN_SUP_BUILD) then
  begin
    DisableInstall(scNotSup,scError,False);
    Application.Terminate;
    Application.ProcessMessages;
    Halt;
  end else
  begin
    sPath := ReadRegistryKey(HKEY_CLASSES_ROOT,scCLSIDKey,'');
    if CorruptString(sPath) then
      DisableInstall(scErrorCLSID,'',True) else
      begin
      sPath := ExpandEnvStr(sPath);
        if bIsWin64 then DisableWowRedirection;
      if FileExists(sPath) then
        begin
          sPath := LoadVerString(sPath);
          if CmpStr(sPath,scMS) then
          begin
            bUnistall := False;
            EnableInstall(scReady);
          end else
            if CmpStr(sPath,scPainter) then
            begin
              bUnistall := True;
              EnableInstall(scInstalled);
            end else DisableInstall(scAnotherProxy,'',True);
        end else DisableInstall(scCorrupt,'',True);
        if bIsWin64 then RevertWowRedirection;
      end;
  end;
end;

procedure TfrmMain.FormCreate(Sender: TObject);
var
  pHandle : HWND;
  PID: Cardinal;
begin
  TVistaAltFix.Create(Self);
  bUnistall := False;
  bIsWin64 := Is64BitWindows;
  Localize;
  CheckCLSID;
end;

function ExitExplorer(): Boolean;
var
  TrayHandle: HWND;
const
  WM_EXITEXPLORER = $5B4;
begin
  Result := False;
  TrayHandle := FindWindow('Shell_TrayWnd', nil);
  if TrayHandle <> 0 then
    Result := PostMessage(TrayHandle, WM_EXITEXPLORER, 0, 0);
end;

procedure MeCreateProcess(sProcess: WideString);
var
  SUInfo : TStartUpInfo;
  ProcInfo : TProcessInformation;
begin
  ZeroMemory(@SUInfo, SizeOf(TStartUpInfo));
    with SUInfo do
    begin
      cb := SizeOf(TStartUpInfo);
      dwFlags := STARTF_USESHOWWINDOW;
      wShowWindow := SW_SHOWNORMAL;
    end;
  CreateProcessW(PWideChar(sProcess), nil, nil, nil, False, 0, nil, nil, SUInfo, ProcInfo);
  Application.ProcessMessages;
end;

procedure StartExplorer();
var
  sWinPath: WideString;
  tv: TOSVersionInfo;
begin
  sWinPath := GetWindowsFolerPath;
  if Is64BitWindows then
  begin
    DisableWowRedirection;
    MeCreateProcess(sWinPath+scExplorer);
    RevertWowRedirection
  end else
    MeCreateProcess(sWinPath+scExplorer);
  tv.dwOSVersionInfoSize := SizeOf(tv);
  GetVersionEx(tv);
  if tv.dwBuildNumber > 9908 then
  begin
    MessageBox(Application.Handle,PChar(scLogoff),PChar(scWarning),MB_ICONWARNING+MB_OK);
    ExitWindowsEx(EWX_LOGOFF,$2);
  end;
end;

procedure ExtractRes(ResType, ResName, sFile: string);
var
  Res: TResourceStream;
  Dir: string;
begin
  Dir := ExtractFileDir(sFile);
  Res := TResourceStream.Create(Hinstance, Resname, PChar(ResType));
  try
    if not DirectoryExists(Dir) then
      ForceDirectories(Dir);
    Res.SavetoFile(sFile);
  finally
    Res.Free;
  end;
end;

function GetAccess(aRoot,aString: string): Boolean;
var
  RegSec: TNTRegSecurity;
  AUserName: string;
begin
  Result := False;
  RegSec := TNTRegSecurity.Create(nil);
  try
    RegSec.Win64Redirect := $100;
    RegSec.Rootkey := GetRootValue(aRoot);
    RegSec.CurrentPath := aString;
    RegSec.TakeOwnerShipAdmin;
    if (RegSec.AccessList = nil) then Exit;
      AUserName := GetEveryOneName('');
    RegSec.AccessList.Add(AUserName, kamFullControl, [], actAccessAllowed);
    Result := True;
  finally
    RegSec.Free;
  end;
end;

function DisableAccess(aRoot,aString: string): Boolean;
var
  RegSec: TNTRegSecurity;
  AUserName: string;
  i: Integer;
begin
  Result := False;
  RegSec := TNTRegSecurity.Create(nil);
  try
    RegSec.Win64Redirect := $100;
    RegSec.Rootkey := GetRootValue(aRoot);
    RegSec.CurrentPath := aString;
    //RegSec.TakeOwnerShipAdmin;
      if (RegSec.AccessList = nil) then Exit else
      begin
      AUserName := GetEveryOneName('');
        for i:=0 to RegSec.AccessList.Count-1 do
        begin
          if AUserName = RegSec.AccessList.Items[i].UserName then
          begin
            RegSec.AccessList.Delete(i);
            Result := True;
            Break;
          end;
        end;
      end;
  finally
    RegSec.Free;
  end;
end;

procedure TfrmMain.btnInstallClick(Sender: TObject);
var
  tv: TOSVersionInfo;
  btnSel: Integer;
  sRes,sPath: WideString;
begin
  btnInstall.Enabled := False;
  Application.ProcessMessages;
  if not bUnistall then
  begin
    tv.dwOSVersionInfoSize := SizeOf(tv);
    GetVersionEx(tv);
    if (tv.dwBuildNumber > MAX_SUP_BUILD) then
      if MessageBoxW(Application.Handle,PWideChar(WideString(scUntested)),PWideChar(WideString(scWarning)),MB_ICONWARNING+MB_YESNO) = IDNO then
        begin
        CheckCLSID;
        Exit;
        end;
    ExitExplorer;

    if bIsWin64 then
    begin
      DisableWowRedirection;
      sRes := 'PAINTER_X64';
      sPath := GetWindowsFolerPath+scLib64;
    end else
    begin
      sRes := 'PAINTER_X86';
      sPath := GetWindowsFolerPath+scLib86;
    end;
    ExtractRes(scProxy,sRes,sPath);
    if FileExists(sPath) then
      begin
        if not GetAccess(scRoot,scCLSIDKey) then frmMain.lblStatus.Caption := scErrorCLSID else
        begin
          WriteRegistryKey(HKEY_CLASSES_ROOT,scCLSIDKey,sPath);
          DisableAccess(scRoot,scCLSIDKey);
        end;
      end;
    if bIsWin64 then
      RevertWowRedirection;
  end else
  begin
    ExitExplorer;
    if not GetAccess(scRoot,scCLSIDKey) then frmMain.lblStatus.Caption := scErrorCLSID else
    begin
      if not WriteRegistryKey(HKEY_CLASSES_ROOT,scCLSIDKey,scBackup) then
        frmMain.lblStatus.Caption := scErrorCLSID else
        if bIsWin64 then
        DeleteFile(GetWindowsFolerPath+scLib64) else
        DeleteFile(GetWindowsFolerPath+scLib86);
      DisableAccess(scRoot,scCLSIDKey);
    end;
  end;
  Sleep(5000);
  StartExplorer;
  CheckCLSID;
end;

end.
