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

