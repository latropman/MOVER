@echo off
setlocal enabledelayedexpansion
C:\Windows\System32\chcp.com 65001 >nul

:: Создаём папку, если она не существует
mkdir "C:\Scripts\MOVER"
start C:\Scripts\MOVER

:: Запускаем процесс поиска маркеров для копирования кода между ними в новые файлы

:: 0MOVERPATH.bat
set "MOVERPATHBEGIN=1MOVERPATHBEGIN"
set "MOVERPATHEND=1MOVERPATHEND"
for /f "tokens=1 delims=:" %%a in ('findstr /n /c:"%MOVERPATHBEGIN%" "%~f0"') do set "start=%%a"
for /f "tokens=1 delims=:" %%a in ('findstr /n /c:"%MOVERPATHEND%" "%~f0"') do set "end=%%a"
powershell -WindowStyle Hidden -Command "(Get-Content '%~f0' | Select-Object -Skip (%start%) -First (%end% - %start% - 1)) | Set-Content 'C:\Scripts\MOVER\1 - MOVER PATH.bat'"

:: MOVER TURN ON.bat
set "MOVERSWITCHBEGIN=2MOVERSWITCHBEGIN"
set "MOVERSWITCHEND=2MOVERSWITCHEND"
for /f "tokens=1 delims=:" %%a in ('findstr /n /c:"%MOVERSWITCHBEGIN%" "%~f0"') do set "start=%%a"
for /f "tokens=1 delims=:" %%a in ('findstr /n /c:"%MOVERSWITCHEND%" "%~f0"') do set "end=%%a"
powershell -WindowStyle Hidden -Command "(Get-Content '%~f0' | Select-Object -Skip (%start%) -First (%end% - %start% - 1)) | Set-Content 'C:\Scripts\MOVER\2 - MOVER TURN ON.bat'"

:: MOVER SCRIPT.ps1
set "MOVERSCRIPTBEGIN=3MOVERSCRIPTBEGIN"
set "MOVERSCRIPTEND=3MOVERSCRIPTEND"
for /f "tokens=1 delims=:" %%a in ('findstr /n /c:"%MOVERSCRIPTBEGIN%" "%~f0"') do set "start=%%a"
for /f "tokens=1 delims=:" %%a in ('findstr /n /c:"%MOVERSCRIPTEND%" "%~f0"') do set "end=%%a"
powershell -WindowStyle Hidden -Command "(Get-Content '%~f0' -Encoding UTF8| Select-Object -Skip (%start%) -First (%end% - %start% - 1)) | Set-Content 'C:\Scripts\MOVER\3 - MOVER SCRIPT.ps1' -Encoding Default"

:: README.txt
set "READMEBEGIN=4READMEBEGIN"
set "READMEEND=4READMEEND"
for /f "tokens=1 delims=:" %%a in ('findstr /n /c:"%READMEBEGIN%" "%~f0"') do set "start=%%a"
for /f "tokens=1 delims=:" %%a in ('findstr /n /c:"%READMEEND%" "%~f0"') do set "end=%%a"
powershell -WindowStyle Hidden -Command "(Get-Content '%~f0' | Select-Object -Skip (%start%) -First (%end% - %start% - 1)) | Set-Content 'C:\Scripts\MOVER\README.txt'"

set "desktop=%USERPROFILE%\Desktop"
powershell -WindowStyle Hidden -Command ^
  $ws = New-Object -ComObject WScript.Shell; ^
  $shortcut = $ws.CreateShortcut('%desktop%\MOVER TURN ON.lnk'); ^
  $shortcut.TargetPath = 'C:\Scripts\MOVER\2 - MOVER TURN ON.bat'; ^
  $shortcut.IconLocation = '%SystemRoot%\system32\shell32.dll,159'; ^
  $shortcut.Save()

start notepad C:\Scripts\MOVER\README.txt
exit


:: :: :: :: :: :: :: :: ::
::  1 - MOVER PATH.bat  ::
:: :: :: :: :: :: :: :: ::


1MOVERPATHBEGIN
@echo off
setlocal enabledelayedexpansion
C:\Windows\System32\chcp.com 65001 >nul

echo ==============================================================
echo =========== MOVER by Latropman (V001 / 2024-12-10) ===========
echo ==============================================================
echo.
:: Путь к JSON-файлу
set "json_file=C:\Scripts\MOVER\destinations.json"

:: Проверяем наличие JSON-файла, если его нет — создаём с путями по умолчанию
if not exist "%json_file%" (
    (
        echo {
        echo     "music":  "C:\\Users\\%username%\\Music",
        echo     "document":  "C:\\Users\\%username%\\Documents",
        echo     "video":  "C:\\Users\\%username%\\Videos",
        echo     "image":  "C:\\Users\\%username%\\Pictures",
        echo     "source":  "C:\\Users\\%username%\\Downloads"
        echo }
    ) > "%json_file%"
)

:: Извлечение данных из JSON
for /f "tokens=* delims=" %%A in ('powershell -command "(Get-Content -Path '%json_file%' | ConvertFrom-Json).source"') do set "source_folder=%%A"
for /f "tokens=* delims=" %%A in ('powershell -command "(Get-Content -Path '%json_file%' | ConvertFrom-Json).video"') do set "video_folder=%%A"
for /f "tokens=* delims=" %%A in ('powershell -command "(Get-Content -Path '%json_file%' | ConvertFrom-Json).music"') do set "music_folder=%%A"
for /f "tokens=* delims=" %%A in ('powershell -command "(Get-Content -Path '%json_file%' | ConvertFrom-Json).image"') do set "image_folder=%%A"
for /f "tokens=* delims=" %%A in ('powershell -command "(Get-Content -Path '%json_file%' | ConvertFrom-Json).document"') do set "document_folder=%%A"

:: Проверяем, удалось ли извлечь данные
if not defined source_folder (
    echo Ошибка: не удалось извлечь данные из %json_file%!
    pause
    exit /b
)
echo Данные файла %json_file% прочитаны:
:: Вывод путей в виде списка
echo • Путь для сканирования ^> %source_folder%
echo • Пути для перемещения:
echo • • Видео ^> %video_folder%
echo • • Аудио ^> %music_folder%
echo • • Изображения ^> %image_folder%
echo • • Документы ^> %document_folder%
echo.
echo     \/ • \/ • \/ • \/ • \/ • \/ • \/ • \/
echo.
:: Функция выбора пути через проводник
set "PSCommand=Add-Type -AssemblyName System.Windows.Forms; "
set "PSCommand=%PSCommand% $folder = New-Object System.Windows.Forms.FolderBrowserDialog; "
set "PSCommand=%PSCommand% $folder.ShowDialog() | Out-Null; $folder.SelectedPath"

:: Ввод выбора: изменить папку для сканирования или оставить текущую
:input_scan_choice
echo Хотите изменить папку для сканирования?
echo [1] Оставить %source_folder%
echo [2] Выбрать новую папку
set /p scan_choice="Введите позицию: "

:: Проверка на пустой ввод и неправильный выбор
if "%scan_choice%"=="" (
    echo Ошибка: вы не ввели ни одного значения! Повторите попытку.
echo.
    goto input_scan_choice
) else if "%scan_choice%"=="1" (
    set "source_folder=!source_folder!"
    echo Путь для Видео оставлен по умолчанию: %source_folder%
) else if "%scan_choice%"=="2" (
    set "new_source_folder="
    for /f "delims=" %%B in ('powershell -NoProfile -Command "%PSCommand%"') do (
        set "new_source_folder=%%B"
    )
    if not defined new_source_folder (
        echo Ошибка: папка для сканирования не выбрана или нажата кнопка Отмена!
	echo.
        goto input_scan_choice
    )
    set "source_folder=!new_source_folder!"
    echo Новый путь для сканирования: !source_folder!
    :: Обновляем путь в JSON
    powershell -command "Set-Content -Path '%json_file%' -Value '{\"video\": \"!video_folder!\", \"music\": \"!music_folder!\", \"image\": \"!image_folder!\", \"document\": \"!document_folder!\", \"source\": \"!source_folder!\"}'"
) else (
    echo Некорректный ввод. Повторите ввод!
    goto input_scan_choice
echo.
)
echo.
echo     --------------------------------------
echo.
:: Ввод выбора путей для сохранения
:input_video_choice
echo Хотите оставить путь для Видео по умолчанию или указать новый путь?
echo [1] Оставить %video_folder%
echo [2] Указать новый путь
set /p video_choice="Введите позицию: "

:: Проверка на пустой или некорректный ввод
if "%video_choice%"=="" (
    echo Ошибка: вы не ввели ни одного значения! Повторите попытку.
echo.
    goto input_video_choice
) else if "%video_choice%"=="1" (
    echo Путь для Видео оставлен по умолчанию: %video_folder%
) else if "%video_choice%"=="2" (
    set "video_folder="
    for /f "delims=" %%B in ('powershell -NoProfile -Command "%PSCommand%"') do (
        set "video_folder=%%B"
    )
    if not defined video_folder (
        echo Ошибка: путь для видео не выбран или нажата кнопка Отмена!
        goto input_video_choice
    )
    echo Новый путь для видео: !video_folder!
) else (
    echo Некорректный ввод. Повторите ввод!
    goto input_video_choice
)
echo.
echo     --------------------------------------
echo.
:input_music_choice
echo Хотите оставить путь для Музыки по умолчанию или указать новый путь?
echo [1] Оставить %music_folder%
echo [2] Указать новый путь
set /p music_choice="Введите позицию: "

:: Проверка на пустой или некорректный ввод
if "%music_choice%"=="" (
    echo Ошибка: вы не ввели ни одного значения! Повторите попытку.
echo.
    goto input_music_choice
) else if "%music_choice%"=="1" (
    echo Путь для Музыки оставлен по умолчанию: %music_folder%
) else if "%music_choice%"=="2" (
    set "music_folder="
    for /f "delims=" %%B in ('powershell -NoProfile -Command "%PSCommand%"') do (
        set "music_folder=%%B"
    )
    if not defined music_folder (
        echo Ошибка: путь для музыки не выбран или нажата кнопка Отмена!
        goto input_music_choice
    )
    echo Новый путь для музыки: !music_folder!
) else (
    echo Некорректный ввод. Повторите ввод!
    goto input_music_choice
)
echo.
echo     --------------------------------------
echo.
:input_image_choice
echo Хотите оставить путь для Изображений по умолчанию или указать новый путь?
echo [1] Оставить %image_folder%
echo [2] Указать новый путь
set /p image_choice="Введите позицию: "

:: Проверка на пустой или некорректный ввод
if "%image_choice%"=="" (
    echo Ошибка: вы не ввели ни одного значения! Повторите попытку.
echo.
    goto input_image_choice
) else if "%image_choice%"=="1" (
    echo Путь для Изображений оставлен по умолчанию: %image_folder%
) else if "%image_choice%"=="2" (
    set "image_folder="
    for /f "delims=" %%B in ('powershell -NoProfile -Command "%PSCommand%"') do (
        set "image_folder=%%B"
    )
    if not defined image_folder (
        echo Ошибка: путь для изображений не выбран или нажата кнопка Отмена!
        goto input_image_choice
    )
    echo Новый путь для изображений: !image_folder!
) else (
    echo Некорректный ввод. Повторите ввод!
    goto input_image_choice
)
echo.
echo     --------------------------------------
echo.
:input_document_choice
echo Хотите оставить путь для Документов по умолчанию или указать новый путь?
echo [1] Оставить %document_folder%
echo [2] Указать новый путь
set /p document_choice="Введите позицию: "

:: Проверка на пустой или некорректный ввод
if "%document_choice%"=="" (
    echo Ошибка: вы не ввели ни одного значения! Повторите попытку.
echo.
    goto input_document_choice
) else if "%document_choice%"=="1" (
    echo Путь для Документов оставлен по умолчанию: %document_folder%
) else if "%document_choice%"=="2" (
    set "document_folder="
    for /f "delims=" %%B in ('powershell -NoProfile -Command "%PSCommand%"') do (
        set "document_folder=%%B"
    )
    if not defined document_folder (
        echo Ошибка: путь для документов не выбран или нажата кнопка Отмена!
        goto input_document_choice
    )
    echo Новый путь для документов: !document_folder!
) else (
    echo Некорректный ввод. Повторите ввод!
    goto input_document_choice
)

:: Заменяем одиночные слэши на двойные для всех путей
set "video_folder=!video_folder:\=\\!"
set "music_folder=!music_folder:\=\\!"
set "image_folder=!image_folder:\=\\!"
set "document_folder=!document_folder:\=\\!"
set "source_folder=!source_folder:\=\\!"

:: Обновляем JSON-файл с новыми путями
powershell -command "Set-Content -Path '%json_file%' -Value '{\"video\": \"!video_folder!\", \"music\": \"!music_folder!\", \"image\": \"!image_folder!\", \"document\": \"!document_folder!\", \"source\": \"!source_folder!\"}'"

:: Вывод всех путей в виде списка
echo.
echo     --------------------------------------
echo.
echo Путь для сканирования: !source_folder:\\=\!
echo Путь для видео: !video_folder:\\=\!
echo Путь для музыки: !music_folder:\\=\!
echo Путь для изображений: !image_folder:\\=\!
echo Путь для документов: !document_folder:\\=\!
echo.

:: Завершаем работу скрипта
echo ==============================================================
echo == Новые пути сохранены. Для выхода нажмите любую кнопку... ==
echo ==============================================================
pause >nul
exit

1MOVERPATHEND


:: :: :: :: :: :: :: :: :: :: ::
::    2 - MOVER TURN ON.bat   ::
:: :: :: :: :: :: :: :: :: :: ::


2MOVERSWITCHBEGIN
@echo off
setlocal enabledelayedexpansion
C:\Windows\System32\chcp.com 65001 >nul

set SCRIPT_PATH=C:\Scripts\MOVER\3 - MOVER SCRIPT.ps1
set ON_NAME=2 - MOVER TURN ON.bat
set OFF_NAME=2 - MOVER TURN OFF.bat

rem Путь к рабочему столу
set DESKTOP_PATH=%USERPROFILE%\Desktop

rem Путь к ярлыкам
set SHORTCUT_ON=%DESKTOP_PATH%\MOVER TURN ON.lnk
set SHORTCUT_OFF=%DESKTOP_PATH%\MOVER TURN OFF.lnk

rem Проверяем, является ли батник уже "MOVER TURN ON" или "MOVER TURN OFF"
if /I "%~nx0" == "%ON_NAME%" (
    rem Если батник "MOVER TURN ON", то запускаем скрипт и переименовываем батник в "MOVER TURN OFF"
    start "" powershell -WindowStyle Hidden -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_PATH%" >nul 2>&1
    rem Переименование батника в "MOVER TURN OFF"
    ren "%~f0" "%OFF_NAME%"

    rem Переименование ярлыка на рабочем столе
    if exist "%SHORTCUT_ON%" (
        rem Переименование ярлыка
        ren "%SHORTCUT_ON%" "MOVER TURN OFF.lnk"
        rem Смена иконки на 274 (MOVER TURN OFF)
        powershell -Command "$shortcut = (New-Object -ComObject WScript.Shell).CreateShortcut('%DESKTOP_PATH%\MOVER TURN OFF.lnk'); $shortcut.TargetPath = '%DESKTOP_PATH%\%OFF_NAME%'; $shortcut.IconLocation = 'C:\Windows\System32\shell32.dll,274'; $shortcut.Save();"
    )
    ie4uinit.exe -show
) else if /I "%~nx0" == "%OFF_NAME%" (
    rem Если батник "MOVER TURN OFF", то завершаем процесс и переименовываем батник в "MOVER TURN ON"
    rem Ищем все процессы PowerShell
    for /f "tokens=2 delims=," %%i in ('tasklist /FI "IMAGENAME eq powershell.exe" /FO CSV /NH') do (
        taskkill /F /PID %%i >nul 2>&1
    )

    rem Переименование батника в "2 - MOVER TURN ON"
    ren "%~f0" "%ON_NAME%"
    
    rem Переименование ярлыка на рабочем столе
    if exist "%SHORTCUT_OFF%" (
        rem Переименование ярлыка
        ren "%SHORTCUT_OFF%" "MOVER TURN ON.lnk"
        rem Смена иконки на 159 (MOVER TURN ON)
        powershell -Command "$shortcut = (New-Object -ComObject WScript.Shell).CreateShortcut('%DESKTOP_PATH%\MOVER TURN ON.lnk'); $shortcut.TargetPath = '%DESKTOP_PATH%\%ON_NAME%'; $shortcut.IconLocation = 'C:\Windows\System32\shell32.dll,159'; $shortcut.Save();"
    )
    ie4uinit.exe -show
)
exit
2MOVERSWITCHEND


:: :: :: :: :: :: ::
::    MOVER.ps1   ::
:: :: :: :: :: :: ::


3MOVERSCRIPTBEGIN
# Получаем PID текущего процесса
$scriptPid = $PID
[System.Environment]::SetEnvironmentVariable('MOVER_PID', $scriptPid, [System.EnvironmentVariableTarget]::Process)
Write-Host "PID скрипта: $scriptPid сохранён в переменную окружения"

# Путь к JSON файлу
$jsonFilePath = "C:\Scripts\MOVER\destinations.json"

# Пути по умолчанию
$defaultDestinations = @{
    "video" = "C:\Users\$env:USERNAME\Videos"
    "music" = "C:\Users\$env:USERNAME\Music"
    "image" = "C:\Users\$env:USERNAME\Pictures"
    "document" = "C:\Users\$env:USERNAME\Documents"
    "source" = "C:\Users\$env:USERNAME\Downloads"
}

# Путь для записи неизвестных расширений
$unknownExtensionsFile = "C:\Scripts\MOVER\unknown_extensions.txt"

# Загрузка конфигурации
if (Test-Path -Path $jsonFilePath) {
    try {
        $destinations = Get-Content -Path $jsonFilePath -Raw | ConvertFrom-Json
    } catch {
        Write-Host "Ошибка чтения JSON файла. Используются пути по умолчанию."
        $destinations = $defaultDestinations
    }
} else {
    $destinations = $defaultDestinations
    $destinations | ConvertTo-Json -Depth 10 | Set-Content -Path $jsonFilePath
}

# Исходная папка и папки назначения
$source = $destinations.source
$videoDestination = $destinations.video
$musicDestination = $destinations.music
$imageDestination = $destinations.image
$documentDestination = $destinations.document

$allDestinations = @($videoDestination, $musicDestination, $imageDestination, $documentDestination)
foreach ($dest in $allDestinations) {
    if (-not (Test-Path -Path $dest)) {
        New-Item -ItemType Directory -Path $dest | Out-Null
        Write-Host "Создана папка: $dest"
    }
}

# Проверка доступности файла
function Is-FileReady($filePath) {
    try {
        $stream = [System.IO.File]::Open($filePath, 'Open', 'Read', 'None')
        $stream.Close()
        return $true
    } catch {
        return $false
    }
}

# Функция перемещения файла
function Move-File($file, $destination) {
    try {
        if (Is-FileReady $file) {
            Write-Host "Перемещаю файл: $file -> $destination"
            Move-Item -Path $file -Destination $destination -Force
            Write-Host "Файл перемещён: $file"
        } else {
            Write-Host "Файл $file недоступен. Пропускаем."
        }
    } catch {
        Write-Host "Ошибка перемещения файла $file. $_"
    }
}

# Логирование неизвестных расширений
function Log-UnknownExtension($file) {
    $extension = [System.IO.Path]::GetExtension($file).ToLower()
    if (-not [string]::IsNullOrWhiteSpace($extension)) {
        Add-Content -Path $unknownExtensionsFile -Value $extension
    } else {
        Add-Content -Path $unknownExtensionsFile -Value "Без расширения"
    }
}

# Обработка файла
function Process-File($file) {
    if ($file -match '\.(mp4|avi|mkv|mov|wmv|flv|webm|mpeg|mpg|3gp)$') {
        Move-File $file $videoDestination
    } elseif ($file -match '\.(mp3|wav|flac|aac|ogg|m4a)$') {
        Move-File $file $musicDestination
    } elseif ($file -match '\.(jpg|jpeg|png|gif|bmp|tiff|webp)$') {
        Move-File $file $imageDestination
    } elseif ($file -match '\.(pdf|docx|doc|xlsx|txt|odt|pptx)$') {
        Move-File $file $documentDestination
    } else {
        Log-UnknownExtension $file
    }
}

# Создаём FileSystemWatcher
$fsw = New-Object System.IO.FileSystemWatcher
$fsw.Path = $source
$fsw.IncludeSubdirectories = $false
$fsw.Filter = '*.*'

# Обработчик события создания
$onCreated = Register-ObjectEvent $fsw Created -Action {
    param($sender, $eventArgs)
    Start-Sleep -Milliseconds 500
    Process-File $eventArgs.FullPath
}

# Обработка всех существующих файлов в исходной папке
Get-ChildItem -Path $source -File | ForEach-Object {
    Process-File $_.FullName
}

# Фоновое сканирование папки
Start-Job -ScriptBlock {
    param ($source, $destinations)
    while ($true) {
        Get-ChildItem -Path $source -File | ForEach-Object {
            Process-File $_.FullName
        }
        Start-Sleep -Seconds 1
    }
} -ArgumentList $source, $destinations

# Запуск наблюдения
Write-Host "`nСкрипт запущен. Наблюдение за папкой $source."
while ($true) {
    Start-Sleep -Seconds 1
}

3MOVERSCRIPTEND

4READMEBEGIN
==============================================================
=========== MOVER by Latropman (V001 / 2024-12-10) ===========
==============================================================

Привет!

Скрипт «MOVER» предназначен для автоматической сортировки файлов по заданным папкам в рамках ОС Windows. Он помогает упростить управление файлами, перемещая их из исходной папки в соответствующие директории в зависимости от категории (видео, музыка, изображения, документы). Всё перед запуском настраивается пользователем вручную и в последствии работает автоматически и в фоновом режиме.

Принцип работы:
• • • Программа анализирует содержимое исходной папки (по умолчанию — папка "Загрузки") и определяет типы файлов по их расширению;
• • • Файлы с неизвестными расширениями фиксируются в специальном текстовом файле unknown_extensions.txt. Буду благодарен, если при появлении такого файла в C:\Scripts\MOVER ты пришлёшь его мне @latropch, чтобы я внёс эти расширения в будущих обновлениях.

Начало работы:
• • • Запускаем файл "1 - MOVER PATH.bat", чтобы настроить путь к папке для сканирования, а также для папок заявленных категорий;
• • • После завершения настройки путей запускаем 2 - MOVER TURN ON.bat из папки либо ярлык на рабочем столе, после чего он переименовывается в 2 - MOVER TURN OFF: это значит, что он работает и готов к отключению по требованию пользователя. Скрипт работает в фоновом режиме до тех пор, пока не будет снова открыт этот файл.

Вспомогательные файлы:
• • • destinations.json - файл конфигурации, где хранятся пути для каждой категории файлов. При его удалении и повторном запуске скрипта создаётся новый файл, в котором будут установлены пути по умолчанию. В таком случае, придётся заново их настроить через 1 - MOVER PATH.bat.

Это мой первый софт, который пригодится, как говорится, "в быту", но в первую очередь был написан для упрощения моей работы в видеомонтаже: в Davinci Resolve появилась возможность автоматического обновления содержимого папок внутри программы, то есть когда добавляешь файлы в проводнике, эти же файлы появляются и в самой монтажке - и можно сразу же начать с ними работу без ручных перемещений. Захотелось улучшить этот процесс: чтобы при скачивании файлов скрипт перемещал различные медиафайлы сразу в папку с проектом, дабы вообще не приходилось таскать все файлы руками. Вот и вся цель.

Есть много схожих программ, но они либо дорогие для меня (тем более, как оказалось, сам могу что-то сделать в этой области), либо работают некорректно. В моём же скрипте сканирование работает постоянно и в фоновом режиме, а жрёт он памяти точно не более, чем все остальные (в пике было зафиксировано 32 000 КБ). Как минимум, его можно отметить за неистово малый размер, который на выходе даже легче, чем сам "установочник".

Весь код доступен через стандартный блокнот, так что если появятся подозрения о каком-нибудь майнинге или прочих кибернепотребствах - всё прозрачно на 100% и можно проверить. У программистов отнимать хлеб не собираюсь, ибо своих монтажных проблем хватает. Так что критику на профессионально-серьёзных щах прошу оставить для более весомых в нашей жизни вещей. Но, тем не менее, очень рад буду фидбэку по багам, ошибкам и предложениям с улучшениями в @latropch или прям сюда в комментах!

Если глаза дошли до этих строк: благодарю за скачивание программы, приятного пользования и спасибо за рыбу %))

Мой канал в Telegram - @latropman.
4READMEEND