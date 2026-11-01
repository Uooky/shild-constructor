[Setup]
AppName=Shild Constructor
AppVersion=1.0
DefaultDirName={commonpf64}\Shild Constructor
DefaultGroupName=Shild Constructor
OutputBaseFilename=ShildConstructorSetup
Compression=lzma
SolidCompression=yes
PrivilegesRequired=admin
UninstallDisplayIcon={app}\shild_constructor.exe
AppPublisher=YourCompany
AppPublisherURL=https://yourcompany.example
AppSupportURL=https://yourcompany.example/support
AppUpdatesURL=https://yourcompany.example/update

[Files]
Source: "C:\path\to\your\project\build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: recursesubdirs createallsubdirs

[Icons]
Name: "{group}\Shild Constructor"; Filename: "{app}\shild_constructor.exe"
Name: "{commondesktop}\Shild Constructor"; Filename: "{app}\shild_constructor.exe"

[Run]
Filename: "{app}\shild_constructor.exe"; Description: "Запустить Shild Constructor"; Flags: nowait postinstall skipifsilent
