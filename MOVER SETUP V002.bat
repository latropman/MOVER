@echo off
NET SESSION >nul 2>&1
if %errorlevel% neq 0 (
    powershell -Command "Start-Process cmd -ArgumentList '/c, \"%~f0\"' -Verb runAs"
    exit /b
)
setlocal enabledelayedexpansion
C:\Windows\System32\chcp.com 65001 >nul

mkdir "C:\Scripts\MOVER"
:: start C:\Scripts\MOVER

:: MOVER ICON.ps1
set "MOVERICONBEGIN=MOVERICONBEGIN"
set "MOVERICONEND=MOVERICONEND"
for /f "tokens=1 delims=:" %%a in ('findstr /n /c:"%MOVERICONBEGIN%" "%~f0"') do set "start=%%a"
for /f "tokens=1 delims=:" %%a in ('findstr /n /c:"%MOVERICONEND%" "%~f0"') do set "end=%%a"
powershell -WindowStyle Hidden -Command "(Get-Content '%~f0' -Encoding UTF8| Select-Object -Skip (%start%) -First (%end% - %start% - 1)) | Set-Content 'C:\Scripts\MOVER\MOVER ICON.ps1' -Encoding Default"

:: MOVER PATH.reg
set "MOVERPATHBEGIN=MOVERPATHBEGIN"
set "MOVERPATHEND=MOVERPATHEND"
for /f "tokens=1 delims=:" %%a in ('findstr /n /c:"%MOVERPATHBEGIN%" "%~f0"') do set "start=%%a"
for /f "tokens=1 delims=:" %%a in ('findstr /n /c:"%MOVERPATHEND%" "%~f0"') do set "end=%%a"
powershell -WindowStyle Hidden -Command "(Get-Content '%~f0' -Encoding UTF8| Select-Object -Skip (%start%) -First (%end% - %start% - 1)) | Set-Content 'C:\Scripts\MOVER\MOVER PATH.reg' -Encoding Default"

:: MOVER SCRIPT.ps1
set "MOVERSCRIPTBEGIN=MOVERSCRIPTBEGIN"
set "MOVERSCRIPTEND=MOVERSCRIPTEND"
for /f "tokens=1 delims=:" %%a in ('findstr /n /c:"%MOVERSCRIPTBEGIN%" "%~f0"') do set "start=%%a"
for /f "tokens=1 delims=:" %%a in ('findstr /n /c:"%MOVERSCRIPTEND%" "%~f0"') do set "end=%%a"
powershell -WindowStyle Hidden -Command "(Get-Content '%~f0' -Encoding UTF8| Select-Object -Skip (%start%) -First (%end% - %start% - 1)) | Set-Content 'C:\Scripts\MOVER\MOVER SCRIPT.ps1' -Encoding Default"

cd /d C:\Scripts\MOVER
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "C:\Scripts\MOVER\MOVER ICON.ps1"
start regedit /s "C:\Scripts\MOVER\MOVER PATH.reg"
timeout /t 1 /nobreak >nul
reg add "HKEY_CLASSES_ROOT\Directory\background\shell\MOVER" /v "Icon" /t REG_SZ /d "C:\\Scripts\\MOVER\\MOVER ICON.ico" /f
del /f /q "C:\Scripts\MOVER\MOVER ICON.ps1"
del /f /q "C:\Scripts\MOVER\MOVER PATH.reg"
timeout /t 1 /nobreak >nul

exit

:: :: :: :: ::

MOVERICONBEGIN
Add-Type -AssemblyName "System.Drawing"

$width = 105
$height = 105

$bgColor = [System.Drawing.Color]::FromArgb(115, 202, 188)

$bmp = New-Object System.Drawing.Bitmap $width, $height
$graphics = [System.Drawing.Graphics]::FromImage($bmp)

$graphics.Clear($bgColor)

$squareSize = 15
$centerCircleSize = 25

$spacing = ($width - 3 * $squareSize) / 4
$centerX = $spacing + $squareSize + $spacing
$centerY = $spacing + $squareSize + $spacing

for ($i = 0; $i -lt 3; $i++) {
    for ($j = 0; $j -lt 3; $j++) {
        $x = $spacing + $j * ($squareSize + $spacing)
        $y = $spacing + $i * ($squareSize + $spacing)

        $graphics.FillRectangle([System.Drawing.Brushes]::Black, $x, $y, $squareSize, $squareSize)

        if ($i -eq 1 -and $j -eq 1) {
            continue
        }

        $pen = New-Object System.Drawing.Pen([System.Drawing.Color]::Black, 7)
        $graphics.DrawLine($pen, $centerX + $squareSize / 2, $centerY + $squareSize / 2, $x + $squareSize / 2, $y + $squareSize / 2)
    }
}

$centerCircleX = ($width - $centerCircleSize) / 2
$centerCircleY = ($height - $centerCircleSize) / 2
$graphics.FillEllipse([System.Drawing.Brushes]::White, $centerCircleX, $centerCircleY, $centerCircleSize, $centerCircleSize)

$borderPen = New-Object System.Drawing.Pen([System.Drawing.Color]::White, 15)
$graphics.DrawLine($borderPen, 0, 0, $width, 0)
$graphics.DrawLine($borderPen, 0, 0, 0, $height)
$graphics.DrawLine($borderPen, 0, $height - 1, $width, $height - 1)
$graphics.DrawLine($borderPen, $width - 1, 0, $width - 1, $height)

$bmpResized = New-Object System.Drawing.Bitmap $bmp, 35, 35
$graphicsResized = [System.Drawing.Graphics]::FromImage($bmpResized)
$graphicsResized.DrawImage($bmp, 0, 0, 35, 35)

$bmpResized.Save("MOVER ICON.ico", [System.Drawing.Imaging.ImageFormat]::Bmp)

$graphics.Dispose()
$bmp.Dispose()
$graphicsResized.Dispose()
$bmpResized.Dispose()
MOVERICONEND

:: :: :: :: ::

MOVERPATHBEGIN
Windows Registry Editor Version 5.00

; Создаём основной пункт в контекстном меню
[HKEY_CLASSES_ROOT\Directory\background\shell\MOVER]
"MUIVerb"="MOVER"
"SubCommands"="MOVER.SUB2;MOVER.SUB1A;MOVER.SUB4;MOVER.SUB3"
"SeparatorBefore"=""
"SeparatorAfter"=""

; Кнопка "Включить"
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\MOVER.SUB1A]
"MUIVerb"="ENABLE"

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\MOVER.SUB1A\command]
@="powershell.exe -WindowStyle Hidden -ExecutionPolicy Bypass -File \"C:\\Scripts\\MOVER\\MOVER SCRIPT.ps1\""

; Создаём ветку для настройки путей
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\MOVER.SUB2]
"MUIVerb"="SET PATHS"
"SubCommands"="MOVER.SUB2A;MOVER.SUB2B;MOVER.SUB2C;MOVER.SUB2D;MOVER.SUB2E;MOVER.SUB2F"
"CommandFlags"=dword:00000040

; Кнопка для установки пути сканирования
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\MOVER.SUB2A]
"MUIVerb"="Source"
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
@="UNINSTALL"

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\MOVER.SUB3\command]
@="powershell -Command \"Start-Process cmd.exe -ArgumentList '/c rd /s /q \"C:\\Scripts\\MOVER\" && reg delete \"HKEY_CLASSES_ROOT\\Directory\\background\\shell\\MOVER\" /f && reg delete \"HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Explorer\\CommandStore\\shell\\MOVER.SUB1A\" /f && reg delete \"HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Explorer\\CommandStore\\shell\\MOVER.SUB2\" /f && reg delete \"HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Explorer\\CommandStore\\shell\\MOVER.SUB2A\" /f && reg delete \"HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Explorer\\CommandStore\\shell\\MOVER.SUB2B\" /f && reg delete \"HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Explorer\\CommandStore\\shell\\MOVER.SUB2C\" /f && reg delete \"HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Explorer\\CommandStore\\shell\\MOVER.SUB2D\" /f && reg delete \"HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Explorer\\CommandStore\\shell\\MOVER.SUB2E\" /f && reg delete \"HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Explorer\\CommandStore\\shell\\MOVER.SUB2F\" /f && reg delete \"HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Explorer\\CommandStore\\shell\\MOVER.SUB3\" /f && reg delete \"HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Explorer\\CommandStore\\shell\\MOVER.SUB4\" /f && reg delete \"HKEY_CURRENT_USER\\SOFTWARE\\MOVER\" /f' -Verb RunAs\""

; Кнопка README с описанием скрипта
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\MOVER.SUB4]
@="README"
"CommandFlags"=dword:00000040

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\MOVER.SUB4\command]
@="cmd.exe /c title README && color F0 && mode con: cols=120 lines=60 && echo. && echo. && echo. && echo                                • • • • • • • • MOVER by Latropman • • • • • • • • && echo                                • • • • • • • • • • 2024-12-26 • • • • • • • • • •  && echo                                • • • • • • • • • • •  V002  • • • • • • • • • • •  && echo. && echo. && echo. && echo. && echo • • • ИЗМЕНЕНИЯ: && echo       • • • Новое управление через контекстное меню Проводника; && echo       • • • Добавлена категория Архивы; && echo       • • • Добавлен полный деинсталлятор скрипта через контекстное меню; && echo       • • • Добавлена генерация иконки для контекстного меню; && echo       • • • Добавлен значок в системном трее как маркер запущенного скрипта с возможностью && echo             завершения его работы, а также переход в установленные пользователем папки; && echo       • • • Добавлена функция переименования файлов: такие конфликтные символы, как, например, && echo             квадратные скобки или эмодзи, не считываются скриптом, оставляя файлы в исходной папке, && echo             поэтому перед перемещением они будут изменены на нижнее подчёркивание; && echo       • • • Увеличен список расширений в прежних категориях; && echo       • • • Исправлена повторяющаяся фиксация неизвестных расширений; && echo       • • • Исправлена проблема двойного запуска процесса в Диспетчере задач; && echo       • • • Удалён старый файл настройки путей; && echo       • • • Удалён старый файл запуска в папке и ярлык на рабочем столе; && echo       • • • Общий размер файлов снизился c 24 до 16 КБ. && echo. && echo • • • ПРИНЦИП РАБОТЫ: && echo       • • • Программа анализирует содержимое исходной папки (по умолчанию — папка 'Загрузки') && echo             и определяет типы файлов по их расширению, автоматически перемещая их по заданным путям && echo             в фоновом режиме. && echo       • • • Файлы с неизвестными расширениями фиксируются в специальном текстовом файле UNKNOWN.txt && echo             и буду благодарен, если при появлении такого файла в C:\\Scripts\\MOVER ты пришлёшь его мне && echo             в Telegram @latropch, чтобы я внёс эти расширения в будущих обновлениях. && echo. && echo • • • НАЧАЛО РАБОТЫ: && echo       • • • После установки в контекстном меню Проводника появится пункт MOVER, через который можно && echo             указать как папку сканирования, так и пути для перемещения файлов. Чтобы установить, && echo             например, папку для сканирования, нужно открыть папку, из которой необходимо переместить && echo             файлы, и через SET PATHS выбрать Source. && echo       • • • После завершения настройки путей запустить скрипт можно, нажав правую кнопку мыши && echo             в любой папке - MOVER - Enable, а чтобы выключить - Exit в иконке трея. && echo. && echo. && echo. && echo. && echo                                • • • Для закрытия окна нажмите любую кнопку • • •                                    && pause >nul"
MOVERPATHEND

:: :: :: :: ::

MOVERSCRIPTBEGIN
Add-Type -AssemblyName 'System.Windows.Forms'
Add-Type -AssemblyName 'System.Drawing'

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

function Sanitize-FileName($filePath) {
    $fileName = [System.IO.Path]::GetFileName($filePath)
    $directory = [System.IO.Path]::GetDirectoryName($filePath)

    $invalidChars = [System.IO.Path]::GetInvalidFileNameChars()
    foreach ($char in $invalidChars) {
        $fileName = $fileName -replace [Regex]::Escape($char), "_"
    }

    $emojiPattern = '[\uD83C-\uDBFF\uDC00-\uDFFF\u2600-\u27BF]'
    $fileName = $fileName -replace $emojiPattern, "_"

    return Join-Path -Path $directory -ChildPath $fileName
}

function Move-File($file, $destination) {
    try {
        #Start-Sleep -Seconds 3
        if (Is-FileReady $file) {
            $sanitizedFile = Sanitize-FileName $file
            if ($file -ne $sanitizedFile) {
                Rename-Item -Path $file -NewName $sanitizedFile
            }
            Move-Item -Path $sanitizedFile -Destination $destination -Force
        }
    } catch {
        # Обработка исключений
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

$runspace = [runspacefactory]::CreateRunspace()
$runspace.Open()

$runspacePipeline = $runspace.CreatePipeline()
$runspacePipeline.Commands.AddScript({
function Get-WindowsTheme {
    $themeKey = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize'
    $useLightTheme = (Get-ItemProperty -Path $themeKey -Name 'AppsUseLightTheme').AppsUseLightTheme
    return $useLightTheme
}

    function Show-TrayIcon {
    Add-Type -AssemblyName 'System.Windows.Forms'
    Add-Type -AssemblyName 'System.Drawing'

    $trayIcon = New-Object System.Windows.Forms.NotifyIcon
    $trayIcon.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon("C:\\Scripts\\MOVER\\MOVER ICON.ico")
    $trayIcon.Visible = $true
    $trayIcon.Text = "Scan enabled"

    $contextMenu = New-Object System.Windows.Forms.ContextMenuStrip
    $regKey = 'HKCU:\SOFTWARE\MOVER'

    function Get-RegistryValue($keyPath, $valueName) {
        try {
            (Get-ItemProperty -Path $keyPath -Name $valueName -ErrorAction Stop).$valueName
        } catch {
            $null
        }
    }

    $sourcePath = Get-RegistryValue $regKey 'source'
    $videoPath = Get-RegistryValue $regKey 'video'
    $musicPath = Get-RegistryValue $regKey 'music'
    $imagePath = Get-RegistryValue $regKey 'image'
    $documentPath = Get-RegistryValue $regKey 'document'
    $archivePath = Get-RegistryValue $regKey 'archive'

    $useLightTheme = Get-WindowsTheme

    $backgroundColor = if ($useLightTheme -eq 1) { '#FFFFFF' } else { '#202020' }
    $textColor = if ($useLightTheme -eq 1) { '#000000' } else { '#FFFFFF' }
    $separatorColor = if ($useLightTheme -eq 1) { '#E0E0E0' } else { '#202020' }

    $pathsItem = New-Object System.Windows.Forms.ToolStripMenuItem
    $pathsItem.Text = "Paths"
    $contextMenu.Items.Add($pathsItem)

    if ($sourcePath) {
        $scanFolderItem = $pathsItem.DropDownItems.Add("Source")
        $scanFolderItem.ToolTipText = $sourcePath
        $scanFolderItem.Add_Click({
            Start-Process -FilePath explorer.exe -ArgumentList "`"$sourcePath`""
        })
        $scanFolderItem.BackColor = $backgroundColor
        $scanFolderItem.ForeColor = $textColor
    }

    if ($videoPath) {
        $videoFolderItem = $pathsItem.DropDownItems.Add("Video")
        $videoFolderItem.ToolTipText = $videoPath
        $videoFolderItem.Add_Click({
            Start-Process -FilePath explorer.exe -ArgumentList "`"$videoPath`""
        })
        $videoFolderItem.BackColor = $backgroundColor
        $videoFolderItem.ForeColor = $textColor
    }

    if ($musicPath) {
        $musicFolderItem = $pathsItem.DropDownItems.Add("Music")
        $musicFolderItem.ToolTipText = $musicPath
        $musicFolderItem.Add_Click({
            Start-Process -FilePath explorer.exe -ArgumentList "`"$musicPath`""
        })
        $musicFolderItem.BackColor = $backgroundColor
        $musicFolderItem.ForeColor = $textColor
    }

    if ($imagePath) {
        $imageFolderItem = $pathsItem.DropDownItems.Add("Pictures")
        $imageFolderItem.ToolTipText = $imagePath
        $imageFolderItem.Add_Click({
            Start-Process -FilePath explorer.exe -ArgumentList "`"$imagePath`""
        })
        $imageFolderItem.BackColor = $backgroundColor
        $imageFolderItem.ForeColor = $textColor
    }

    if ($documentPath) {
        $documentFolderItem = $pathsItem.DropDownItems.Add("Document")
        $documentFolderItem.ToolTipText = $documentPath
        $documentFolderItem.Add_Click({
            Start-Process -FilePath explorer.exe -ArgumentList "`"$documentPath`""
        })
        $documentFolderItem.BackColor = $backgroundColor
        $documentFolderItem.ForeColor = $textColor
    }

    if ($archivePath) {
        $archiveFolderItem = $pathsItem.DropDownItems.Add("Archive")
        $archiveFolderItem.ToolTipText = $archivePath
        $archiveFolderItem.Add_Click({
            Start-Process -FilePath explorer.exe -ArgumentList "`"$archivePath`""
        })
        $archiveFolderItem.BackColor = $backgroundColor
        $archiveFolderItem.ForeColor = $textColor
    }

    $contextMenu.Items.Add("-")

    $turnOffItem = $contextMenu.Items.Add("Exit")
    $turnOffItem.Add_Click({
        Start-Job -ScriptBlock {
            Stop-Process -Id (Get-Content 'C:\\Scripts\\MOVER\\MOVER PID.txt') -Force -ErrorAction SilentlyContinue
            Remove-Item -Path 'C:\\Scripts\\MOVER\\MOVER PID.txt' -Force -ErrorAction SilentlyContinue
        }
        $trayIcon.Visible = $false
        $trayIcon.Dispose()
    })
    $turnOffItem.BackColor = $backgroundColor
    $turnOffItem.ForeColor = $textColor

    $contextMenu.BackColor = $backgroundColor
    $contextMenu.ForeColor = $textColor
    $contextMenu.Items | ForEach-Object {
        $_.BackColor = $backgroundColor
        $_.ForeColor = $textColor
    }

    foreach ($item in $contextMenu.Items) {
        if ($item.GetType().Name -eq 'ToolStripSeparator') {
            $item.ForeColor = $separatorColor
            $item.Margin = New-Object System.Windows.Forms.Padding(0)
        }
    }

    $contextMenu.RenderMode = [System.Windows.Forms.ToolStripRenderMode]::System

    $trayIcon.ContextMenuStrip = $contextMenu
    [System.Windows.Forms.Application]::Run()
    }
    Show-TrayIcon
})

$runspacePipeline.InvokeAsync()

while ($true) {
    Get-ChildItem -Path $source -File | ForEach-Object {
        Process-File $_.FullName
    }
    Start-Sleep -Seconds 1
}
MOVERSCRIPTEND