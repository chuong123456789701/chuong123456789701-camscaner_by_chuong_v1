; installer.iss — Script tạo bộ cài cho CamScaner by Chương
; Tác giả: Chương
; Miễn phí 100% — Không quảng cáo

#define MyAppName "CamScaner by Chương"
#define MyAppVersion "1.0.0"
#define MyAppPublisher "Chương"
#define MyAppExeName "camscaner_by_chuong_v1.exe"
#define MyAppURL "https://github.com/chuong/camscaner_by_chuong_v1"

[Setup]
AppId={{8F3A5B2C-1D4E-4F6A-9B8C-7E5D3A1F2B4C}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppVerName={#MyAppName} {#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
DefaultDirName={autopf}\{#MyAppName}
DefaultGroupName={#MyAppName}
DisableProgramGroupPage=yes
OutputDir=installer_output
OutputBaseFilename=CamScaner_by_Chuong_Setup_v1
SetupIconFile=windows\runner\resources\app_icon.ico
Compression=lzma2/ultra64
SolidCompression=yes
WizardStyle=modern
PrivilegesRequired=lowest
ArchitecturesInstallIn64BitMode=x64
UninstallDisplayIcon={app}\{#MyAppExeName}
UninstallDisplayName={#MyAppName}

[Languages]
Name: "vietnamese"; MessagesFile: "compiler:Languages\Vietnamese.isl"
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "Tạo biểu tượng ngoài Desktop"; GroupDescription: "Tuỳ chọn:"; Flags: checkedonce
Name: "quicklaunchicon"; Description: "Tạo biểu tượng trong Quick Launch"; GroupDescription: "Tuỳ chọn:"; Flags: unchecked

[Files]
Source: "build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{group}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"
Name: "{group}\Gỡ cài đặt {#MyAppName}"; Filename: "{uninstallexe}"
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon
Name: "{userappdata}\Microsoft\Internet Explorer\Quick Launch\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: quicklaunchicon

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "Mở {#MyAppName} ngay"; Flags: nowait postinstall skipifsilent

[UninstallDelete]
Type: filesandordirs; Name: "{app}"

[CustomMessages]
vietnamese.CreateDesktopIcon=Tạo biểu tượng ngoài Desktop
vietnamese.LaunchApp=Mở {#MyAppName} ngay
vietnamese.AdditionalIcons=Biểu tượng bổ sung: