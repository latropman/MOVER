@echo off
NET SESSION >nul 2>&1
if %errorlevel% neq 0 (
    powershell -Command "Start-Process cmd -ArgumentList '/c, \"%~f0\"' -Verb runAs"
    exit /b
)
setlocal enabledelayedexpansion
C:\Windows\System32\chcp.com 65001 >nul

mkdir "C:\Scripts\MOVER"
start C:\Scripts\MOVER

:: MOVER PATH.reg
set "MOVERPATHBEGIN=MOVERPATHBEGIN"
set "MOVERPATHEND=MOVERPATHEND"
for /f "tokens=1 delims=:" %%a in ('findstr /n /c:"%MOVERPATHBEGIN%" "%~f0"') do set "start=%%a"
for /f "tokens=1 delims=:" %%a in ('findstr /n /c:"%MOVERPATHEND%" "%~f0"') do set "end=%%a"
powershell -WindowStyle Hidden -Command "(Get-Content '%~f0' | Select-Object -Skip (%start%) -First (%end% - %start% - 1)) | Set-Content 'C:\Scripts\MOVER\MOVER PATH.reg'"

:: MOVER SCRIPT.ps1
set "MOVERSCRIPTBEGIN=MOVERSCRIPTBEGIN"
set "MOVERSCRIPTEND=MOVERSCRIPTEND"
for /f "tokens=1 delims=:" %%a in ('findstr /n /c:"%MOVERSCRIPTBEGIN%" "%~f0"') do set "start=%%a"
for /f "tokens=1 delims=:" %%a in ('findstr /n /c:"%MOVERSCRIPTEND%" "%~f0"') do set "end=%%a"
powershell -WindowStyle Hidden -Command "(Get-Content '%~f0' -Encoding UTF8| Select-Object -Skip (%start%) -First (%end% - %start% - 1)) | Set-Content 'C:\Scripts\MOVER\MOVER SCRIPT.ps1' -Encoding Default"

:: README.txt
set "READMEBEGIN=READMEBEGIN"
set "READMEEND=READMEEND"
for /f "tokens=1 delims=:" %%a in ('findstr /n /c:"%READMEBEGIN%" "%~f0"') do set "start=%%a"
for /f "tokens=1 delims=:" %%a in ('findstr /n /c:"%READMEEND%" "%~f0"') do set "end=%%a"
powershell -WindowStyle Hidden -Command "(Get-Content '%~f0' | Select-Object -Skip (%start%) -First (%end% - %start% - 1)) | Set-Content 'C:\Scripts\MOVER\README.txt'"

start regedit /s "C:\Scripts\MOVER\MOVER PATH.reg"
start notepad C:\Scripts\MOVER\README.txt
timeout /t 2 /nobreak >nul
del /f /q "C:\Scripts\MOVER\MOVER PATH.reg"
exit

:: :: :: :: ::

MOVERPATHBEGIN
Windows Registry Editor Version 5.00

; Создаём основной пункт в контекстном меню
[HKEY_CLASSES_ROOT\Directory\background\shell\MOVER]
"MUIVerb"="MOVER"
"SubCommands"="MOVER.SUB1A;MOVER.SUB1B;MOVER.SUB2;MOVER.SUB3"
"Icon"="\"C:\\Windows\\System32\\shell32.dll,159\""
"SeparatorBefore"=""
"SeparatorAfter"=""

; Кнопка "Включить"
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\MOVER.SUB1A]
"MUIVerb"="Turn ON"

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\MOVER.SUB1A\command]
@="powershell.exe -WindowStyle Hidden -ExecutionPolicy Bypass -File \"C:\\Scripts\\MOVER\\MOVER SCRIPT.ps1\""

; Кнопка "Отключить"
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\MOVER.SUB1B]
"MUIVerb"="Turn OFF"
"CommandFlags"=dword:00000040

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\MOVER.SUB1B\command]
@="powershell -Command \"Stop-Process -Id (Get-Content 'C:\\Scripts\\MOVER\\MOVER PID.txt') -Force -ErrorAction SilentlyContinue; Remove-Item -Path 'C:\\Scripts\\MOVER\\MOVER PID.txt' -Force -ErrorAction SilentlyContinue\""

; Создаём ветку для настройки путей
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\MOVER.SUB2]
"MUIVerb"="Current folder"
"SubCommands"="MOVER.SUB2A;MOVER.SUB2B;MOVER.SUB2C;MOVER.SUB2D;MOVER.SUB2E;MOVER.SUB2F"
"CommandFlags"=dword:00000040

; Кнопка для установки пути сканирования
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\MOVER.SUB2A]
"MUIVerb"="Scan folder"
"CommandFlags"=dword:00000040

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\MOVER.SUB2A\command]
@="powershell.exe -NoProfile -Command \"& { $path = Get-Location; $registryKeyPath = 'HKCU:\\Software\\MOVER'; if (-not (Test-Path $registryKeyPath)) { New-Item -Path $registryKeyPath -Force; Set-ItemProperty -Path $registryKeyPath -Name 'source' -Value 'C:\\Users\\$env:USERNAME\\Downloads'; Set-ItemProperty -Path $registryKeyPath -Name 'video' -Value 'C:\\Users\\$env:USERNAME\\Videos'; Set-ItemProperty -Path $registryKeyPath -Name 'music' -Value 'C:\\Users\\$env:USERNAME\\Music'; Set-ItemProperty -Path $registryKeyPath -Name 'image' -Value 'C:\\Users\\$env:USERNAME\\Pictures'; Set-ItemProperty -Path $registryKeyPath -Name 'document' -Value 'C:\\Users\\$env:USERNAME\\Documents'; Set-ItemProperty -Path $registryKeyPath -Name 'archive' -Value 'C:\\Users\\$env:USERNAME\\Archives'; } Set-ItemProperty -Path $registryKeyPath -Name 'source' -Value $path.Path }\""

; Кнопка для установки пути перемещения видеофайлов
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\MOVER.SUB2B]
"MUIVerb"="Video"

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\MOVER.SUB2B\command]
@="powershell.exe -NoProfile -Command \"& { $path = Get-Location; $registryKeyPath = 'HKCU:\\Software\\MOVER'; if (-not (Test-Path $registryKeyPath)) { New-Item -Path $registryKeyPath -Force; Set-ItemProperty -Path $registryKeyPath -Name 'source' -Value 'C:\\Users\\$env:USERNAME\\Downloads'; Set-ItemProperty -Path $registryKeyPath -Name 'video' -Value 'C:\\Users\\$env:USERNAME\\Videos'; Set-ItemProperty -Path $registryKeyPath -Name 'music' -Value 'C:\\Users\\$env:USERNAME\\Music'; Set-ItemProperty -Path $registryKeyPath -Name 'image' -Value 'C:\\Users\\$env:USERNAME\\Pictures'; Set-ItemProperty -Path $registryKeyPath -Name 'document' -Value 'C:\\Users\\$env:USERNAME\\Documents'; Set-ItemProperty -Path $registryKeyPath -Name 'archive' -Value 'C:\\Users\\$env:USERNAME\\Archives'; } Set-ItemProperty -Path $registryKeyPath -Name 'video' -Value $path.Path }\""

; Кнопка для установки пути перемещения аудиофайлов
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\MOVER.SUB2C]
"MUIVerb"="Music"

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\MOVER.SUB2C\command]
@="powershell.exe -NoProfile -Command \"& { $path = Get-Location; $registryKeyPath = 'HKCU:\\Software\\MOVER'; if (-not (Test-Path $registryKeyPath)) { New-Item -Path $registryKeyPath -Force; Set-ItemProperty -Path $registryKeyPath -Name 'source' -Value 'C:\\Users\\$env:USERNAME\\Downloads'; Set-ItemProperty -Path $registryKeyPath -Name 'video' -Value 'C:\\Users\\$env:USERNAME\\Videos'; Set-ItemProperty -Path $registryKeyPath -Name 'music' -Value 'C:\\Users\\$env:USERNAME\\Music'; Set-ItemProperty -Path $registryKeyPath -Name 'image' -Value 'C:\\Users\\$env:USERNAME\\Pictures'; Set-ItemProperty -Path $registryKeyPath -Name 'document' -Value 'C:\\Users\\$env:USERNAME\\Documents'; Set-ItemProperty -Path $registryKeyPath -Name 'archive' -Value 'C:\\Users\\$env:USERNAME\\Archives'; } Set-ItemProperty -Path $registryKeyPath -Name 'music' -Value $path.Path }\""

; Кнопка для установки пути перемещения изображений
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\MOVER.SUB2D]
"MUIVerb"="Pictures"

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\MOVER.SUB2D\command]
@="powershell.exe -NoProfile -Command \"& { $path = Get-Location; $registryKeyPath = 'HKCU:\\Software\\MOVER'; if (-not (Test-Path $registryKeyPath)) { New-Item -Path $registryKeyPath -Force; Set-ItemProperty -Path $registryKeyPath -Name 'source' -Value 'C:\\Users\\$env:USERNAME\\Downloads'; Set-ItemProperty -Path $registryKeyPath -Name 'video' -Value 'C:\\Users\\$env:USERNAME\\Videos'; Set-ItemProperty -Path $registryKeyPath -Name 'music' -Value 'C:\\Users\\$env:USERNAME\\Music'; Set-ItemProperty -Path $registryKeyPath -Name 'image' -Value 'C:\\Users\\$env:USERNAME\\Pictures'; Set-ItemProperty -Path $registryKeyPath -Name 'document' -Value 'C:\\Users\\$env:USERNAME\\Documents'; Set-ItemProperty -Path $registryKeyPath -Name 'archive' -Value 'C:\\Users\\$env:USERNAME\\Archives'; } Set-ItemProperty -Path $registryKeyPath -Name 'image' -Value $path.Path }\""

; Кнопка для установки пути перемещения документов
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\MOVER.SUB2E]
"MUIVerb"="Documents"

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\MOVER.SUB2E\command]
@="powershell.exe -NoProfile -Command \"& { $path = Get-Location; $registryKeyPath = 'HKCU:\\Software\\MOVER'; if (-not (Test-Path $registryKeyPath)) { New-Item -Path $registryKeyPath -Force; Set-ItemProperty -Path $registryKeyPath -Name 'source' -Value 'C:\\Users\\$env:USERNAME\\Downloads'; Set-ItemProperty -Path $registryKeyPath -Name 'video' -Value 'C:\\Users\\$env:USERNAME\\Videos'; Set-ItemProperty -Path $registryKeyPath -Name 'music' -Value 'C:\\Users\\$env:USERNAME\\Music'; Set-ItemProperty -Path $registryKeyPath -Name 'image' -Value 'C:\\Users\\$env:USERNAME\\Pictures'; Set-ItemProperty -Path $registryKeyPath -Name 'document' -Value 'C:\\Users\\$env:USERNAME\\Documents'; Set-ItemProperty -Path $registryKeyPath -Name 'archive' -Value 'C:\\Users\\$env:USERNAME\\Archives'; } Set-ItemProperty -Path $registryKeyPath -Name 'document' -Value $path.Path }\""

; Кнопка для установки пути перемещения архивов
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\MOVER.SUB2F]
"MUIVerb"="Archives"

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\MOVER.SUB2F\command]
@="powershell.exe -NoProfile -Command \"& { $path = Get-Location; $registryKeyPath = 'HKCU:\\Software\\MOVER'; if (-not (Test-Path $registryKeyPath)) { New-Item -Path $registryKeyPath -Force; Set-ItemProperty -Path $registryKeyPath -Name 'source' -Value 'C:\\Users\\$env:USERNAME\\Downloads'; Set-ItemProperty -Path $registryKeyPath -Name 'video' -Value 'C:\\Users\\$env:USERNAME\\Videos'; Set-ItemProperty -Path $registryKeyPath -Name 'music' -Value 'C:\\Users\\$env:USERNAME\\Music'; Set-ItemProperty -Path $registryKeyPath -Name 'image' -Value 'C:\\Users\\$env:USERNAME\\Pictures'; Set-ItemProperty -Path $registryKeyPath -Name 'document' -Value 'C:\\Users\\$env:USERNAME\\Documents'; Set-ItemProperty -Path $registryKeyPath -Name 'archive' -Value 'C:\\Users\\$env:USERNAME\\Archives'; } Set-ItemProperty -Path $registryKeyPath -Name 'archive' -Value $path.Path }\""

; Кнопка для полного удаления скрипта из системы
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\MOVER.SUB3]
@="Delete MOVER"

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\MOVER.SUB3\command]
@="powershell -Command \"Start-Process cmd.exe -ArgumentList '/c rd /s /q \"C:\\Scripts\\MOVER\" && reg delete \"HKEY_CLASSES_ROOT\\Directory\\background\\shell\\MOVER\" /f && reg delete \"HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Explorer\\CommandStore\\shell\\MOVER.SUB1A\" /f && reg delete \"HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Explorer\\CommandStore\\shell\\MOVER.SUB1B\" /f && reg delete \"HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Explorer\\CommandStore\\shell\\MOVER.SUB2\" /f && reg delete \"HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Explorer\\CommandStore\\shell\\MOVER.SUB2A\" /f && reg delete \"HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Explorer\\CommandStore\\shell\\MOVER.SUB2B\" /f && reg delete \"HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Explorer\\CommandStore\\shell\\MOVER.SUB2C\" /f && reg delete \"HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Explorer\\CommandStore\\shell\\MOVER.SUB2D\" /f && reg delete \"HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Explorer\\CommandStore\\shell\\MOVER.SUB2E\" /f && reg delete \"HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Explorer\\CommandStore\\shell\\MOVER.SUB2F\" /f && reg delete \"HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Explorer\\CommandStore\\shell\\MOVER.SUB3\" /f && reg delete \"HKEY_CURRENT_USER\\SOFTWARE\\MOVER\" /f' -Verb RunAs\""
MOVERPATHEND

:: :: :: :: ::

MOVERSCRIPTBEGIN
$scriptPid = $PID
Set-Content -Path "C:\Scripts\MOVER\MOVER PID.txt" -Value $scriptPid

$registryKeyPath = "HKCU:\Software\MOVER"
$defaultDestinations = @{
    "video" = "C:\Users\$env:USERNAME\Videos"
    "music" = "C:\Users\$env:USERNAME\Music"
    "image" = "C:\Users\$env:USERNAME\Pictures"
    "document" = "C:\Users\$env:USERNAME\Documents"
    "source" = "C:\Users\$env:USERNAME\Downloads"
    "archive" = "C:\Users\$env:USERNAME\Archives"
}

if (Test-Path $registryKeyPath) {
    try {
        $destinations = @{
            "video" = (Get-ItemProperty -Path $registryKeyPath -Name "video").video
            "music" = (Get-ItemProperty -Path $registryKeyPath -Name "music").music
            "image" = (Get-ItemProperty -Path $registryKeyPath -Name "image").image
            "document" = (Get-ItemProperty -Path $registryKeyPath -Name "document").document
            "source" = (Get-ItemProperty -Path $registryKeyPath -Name "source").source
            "archive" = (Get-ItemProperty -Path $registryKeyPath -Name "archive").archive
        }
    } catch {
        $destinations = $defaultDestinations
    }
} else {
    New-Item -Path $registryKeyPath -Force
    foreach ($key in $defaultDestinations.Keys) {
        Set-ItemProperty -Path $registryKeyPath -Name $key -Value $defaultDestinations[$key]
    }
    $destinations = $defaultDestinations
}

$source = $destinations.source
$videoDestination = $destinations.video
$musicDestination = $destinations.music
$imageDestination = $destinations.image
$documentDestination = $destinations.document
$archiveDestination = $destinations.archive
$unknownFilePath = "C:\Scripts\MOVER\UNKNOWN.txt"

$allDestinations = @($videoDestination, $musicDestination, $imageDestination, $documentDestination, $archiveDestination)
foreach ($dest in $allDestinations) {
    if (-not (Test-Path -Path $dest)) {
        New-Item -ItemType Directory -Path $dest | Out-Null
    }
}

function Is-FileReady($filePath) {
    try {
        $stream = [System.IO.File]::Open($filePath, 'Open', 'Read', 'None')
        $stream.Close()
        return $true
    } catch {
        return $false
    }
}

function Move-File($file, $destination) {
    try {
        if (Is-FileReady $file) {
            Move-Item -Path $file -Destination $destination -Force
        }
    } catch {
    }
}

function Add-UnknownExtension($extension) {
    $existingExtensions = @()
    if (Test-Path -Path $unknownFilePath) {
        $existingExtensions = Get-Content -Path $unknownFilePath | ForEach-Object { $_.Trim() }
    }
    
    if ($existingExtensions -notcontains $extension) {
        Add-Content -Path $unknownFilePath -Value $extension
    }
}

function Process-File($file) {
    if ($file -match '\.(mp4|mkv|avi|mov|wmv|flv|webm|mpeg|mpg|3gp|ts|vob|rm|ogv|h264|hevc|m4v|f4v|asf|iso|mp4v|divx|bik|mxf|qt|dat|mod|vdr|rmvb|m2ts)$') {
        Move-File $file $videoDestination
    } elseif ($file -match '\.(mp3|wav|aac|flac|ogg|wma|m4a|opus|alac|aiff|ra|ac3|midi|caf|ape|mp2|tta|spx|sflac|wv|tak|xmf|dts|snd|pcm|mka|wpl)$') {
        Move-File $file $musicDestination
    } elseif ($file -match '\.(jpg|jpeg|png|gif|bmp|tiff|svg|webp|heif|raw|psd|ai|eps|pdf|ico|indd|cr2|nef|jfif|heic|hdr|jpe|tga|ppm|pcx|emf|fits|art|wbmp)$') {
        Move-File $file $imageDestination
    } elseif ($file -match '\.(pdf|doc|docx|txt|rtf|xls|xlsx|ppt|pptx|csv|html|xml|epub|md|tex|odt|odf|abw|pages|pptm|xltx|dotx|wpd|fodt|fb2|odg|fodp)$') {
        Move-File $file $documentDestination
    } elseif ($file -match '\.(zip|rar|7z|tar|gz|bz2|xz|iso|tar.gz|tgz)$') {
        Move-File $file $archiveDestination
    } else {
        $extension = [System.IO.Path]::GetExtension($file).ToLower()
        Add-UnknownExtension $extension
    }
}

Get-ChildItem -Path $source -File | ForEach-Object {
    Process-File $_.FullName
}

$fsw = New-Object System.IO.FileSystemWatcher
$fsw.Path = $source
$fsw.IncludeSubdirectories = $false
$fsw.Filter = '*.*'

$onCreated = Register-ObjectEvent $fsw Created -Action {
    param($sender, $eventArgs)
    Start-Sleep -Milliseconds 500
    if (Test-Path $eventArgs.FullPath) {
        Process-File $eventArgs.FullPath
    }
}

while ($true) {
    Start-Sleep -Seconds 1
}
MOVERSCRIPTEND

:: :: :: :: ::

READMEBEGIN
=============== MOVER by @latropman ===============
=================== 2024-12-21 ====================
====================== V-002 ======================

Изменения:
• Новое управление через контекстное меню Проводника;
• Добавлен полный деинсталлятор скрипта через контекстное меню;
• Добавлена категория Архивы;
• Добавлены некоторые расширения в прежние категории;
• Исправлена повторяющаяся фиксация неизвестных расширений;
• Исправлена проблема двойного запуска процесса в Диспетчере задач;
• Удалён старый файл настройки путей;
• Удалён старый файл запуска в папке и ярлык на рабочем столе;
• Общий размер файлов снизился c 23.5 до 6.8 КБ

Принцип работы:
• Программа анализирует содержимое исходной папки (по умолчанию — папка "Загрузки") и определяет типы файлов по их расширению, автоматически перемещая их по заданным путям в фоновом режиме.
• Файлы с неизвестными расширениями фиксируются в специальном текстовом файле UNKNOWN.txt и буду благодарен, если при появлении такого файла в C:\Scripts\MOVER ты пришлёшь его мне @latropch, чтобы я внёс эти расширения в будущих обновлениях.

Начало работы:
• После установки в контекстном меню Проводника появится пункт MOVER, через который можно указать как папку сканирования, так и пути для перемещения файлов. Чтобы установить, например, папку для сканирования, потребуется открыть нужную папку и через контекстное меню (ПКМ) выбрать Scan folder.
• После завершения настройки путей запустить скрипт можно, нажав правую кнопку мыши в любой папке -> MOVER -> Turn ON. Выключить - Turn OFF.
READMEEND