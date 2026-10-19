; DrawPets Windows installer (Inno Setup 6). Built by tools/release/release.sh:
;
;   ISCC.exe -DAppVersion=0.1.0 tools\release\installer.iss
;
; Packs the export in build\windows\ into build\release\DrawPets-Setup.exe. The same design as
; DrawFight's, Wizard Wars' and Wizard Survivors' installers.
;
; Per-user, no admin prompt: it installs to %LOCALAPPDATA%\Programs\DrawPets, which the player
; can write to - and must, because the game updates itself by robocopying new files into its own
; folder (scripts/update_screen.gd). Program Files would leave it stuck on its version.
; See .ai/releasing.md.

#ifndef AppVersion
  #error Pass the version: ISCC -DAppVersion=X.Y.Z tools\release\installer.iss
#endif

[Setup]
; Never change this GUID: it is how Windows knows a new setup is the same program, so it upgrades
; in place instead of installing a second copy.
AppId={{73BE4DC9-6C0F-40AE-9E28-61091CF6AB30}
AppName=DrawPets
AppVersion={#AppVersion}
; Apps & features shows the name alone; the version has its own column there.
UninstallDisplayName=DrawPets
AppPublisher=ECEC
AppPublisherURL=https://ecec.dev/games/drawpets
; Paths below are relative to the repo root.
SourceDir=..\..
PrivilegesRequired=lowest
DefaultDirName={localappdata}\Programs\DrawPets
DisableProgramGroupPage=yes
DisableDirPage=auto
UsePreviousAppDir=yes
WizardStyle=modern
SetupIconFile=icon\icon.ico
UninstallDisplayIcon={app}\DrawPets.exe
OutputDir=build\release
OutputBaseFilename=DrawPets-Setup
Compression=lzma2/max
SolidCompression=yes
CloseApplications=yes
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"

[Files]
; The export only. "How to play.txt" is written into the zip by package.py, never into
; build\windows, so it is not picked up here.
Source: "build\windows\*"; DestDir: "{app}"; Flags: recursesubdirs createallsubdirs ignoreversion

[Icons]
Name: "{autoprograms}\DrawPets"; Filename: "{app}\DrawPets.exe"
Name: "{autodesktop}\DrawPets"; Filename: "{app}\DrawPets.exe"; Tasks: desktopicon

[Run]
Filename: "{app}\DrawPets.exe"; Description: "Play DrawPets now"; Flags: postinstall nowait skipifsilent

[UninstallDelete]
; The whole folder, including files the self-updater added. The pets and everything else a kid
; made live in %APPDATA%\Godot\app_userdata\DrawPets\ and are deliberately left alone.
Type: filesandordirs; Name: "{app}"
