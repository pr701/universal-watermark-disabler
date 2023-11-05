unit SysFoldersUnicode;
 
interface
 
uses Windows, SysUtils, ShlObj;
 
function GetUserAppDataFolderPath : WideString;
function GetUserMyDocumentsFolderPath : WideString;
function GetUserFavoritesFolderPath : WideString;
function GetUserProfileFolderPath : WideString;
 
function GetCommonAppDataFolderPath : WideString;
 
function GetWindowsFolerPath : WideString;
function GetTempFolderPath : WideString;
 
implementation
 
const
  {$EXTERNALSYM CSIDL_COMMON_APPDATA}
  CSIDL_COMMON_APPDATA = $0023;
  CSIDL_PROFILE = $0028;

function StrPas(const Str: PChar): String; overload;
begin
  Result := Str;
end;

function StrPas(const Str: PWideChar): WideString; overload;
begin
  Result := Str;
end;

function GetSpecialFolderPath(CSIDL : Integer) : String;
var
  Path : PWideChar;
begin
  Result := '';
  GetMem(Path,MAX_PATH);
  Try
    If Not SHGetSpecialFolderPathW(0,Path,CSIDL,False) Then
      Raise Exception.Create('Shell function SHGetSpecialFolderPath fails.');
    Result := Trim(StrPas(Path));
    If Result = '' Then
      Raise Exception.Create('Shell function SHGetSpecialFolderPath return an empty string.');
    Result := IncludeTrailingPathDelimiter(Result);
  Finally
    FreeMem(Path,MAX_PATH);
  End;
end;
 
function GetTempFolderPath : WideString;
var
  Path : PChar;
begin
  Result := ExtractFilePath(ParamStr(0));
  GetMem(Path,MAX_PATH);
  Try
    If GetTempPath(MAX_PATH,Path) <> 0 Then
      Begin
        Result := Trim(StrPas(Path));
        Result := IncludeTrailingPathDelimiter(Result);
      End;
  Finally
    FreeMem(Path,MAX_PATH);
  End;
end;
 
function GetWindowsFolerPath : WideString;
var
  Path : PWideChar;
begin
  Result := ExtractFilePath(ParamStr(0));
  GetMem(Path,MAX_PATH);
  Try
    If GetWindowsDirectoryW(Path, MAX_PATH) <> 0 Then
      Begin
        Result := Trim(StrPas(Path));
        Result := IncludeTrailingPathDelimiter(Result);
      End;
  Finally
    FreeMem(Path,MAX_PATH);
  End;
end;
 
function GetUserAppDataFolderPath : WideString;
begin
  Result := GetSpecialFolderPath(CSIDL_APPDATA);
end;
 
function GetUserMyDocumentsFolderPath : WideString;
begin
  Result := GetSpecialFolderPath(CSIDL_PERSONAL);
end;
 
function GetUserFavoritesFolderPath : WideString;
begin
  Result := GetSpecialFolderPath(CSIDL_FAVORITES);
end;
 
function GetCommonAppDataFolderPath : WideString;
begin
  Result := GetSpecialFolderPath(CSIDL_COMMON_APPDATA);
end;

function GetUserProfileFolderPath : WideString;
begin
  Result := GetSpecialFolderPath(CSIDL_PROFILE);
end;

function GetUserFromWindows: WideString;
var
UserName : WideString;
UserNameLen : Dword;
begin
UserNameLen := 255;
SetLength(userName, UserNameLen);
if GetUserNameW(PWideChar(UserName), UserNameLen) then
   Result := Copy(UserName,1,UserNameLen - 1)
else
   Result := '';
end;
 
end.