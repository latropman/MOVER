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

