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
