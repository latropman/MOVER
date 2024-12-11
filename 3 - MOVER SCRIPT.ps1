# �������� PID �������� ��������
$scriptPid = $PID
[System.Environment]::SetEnvironmentVariable('MOVER_PID', $scriptPid, [System.EnvironmentVariableTarget]::Process)
Write-Host "PID �������: $scriptPid ������� � ���������� ���������"

# ���� � JSON �����
$jsonFilePath = "C:\Scripts\MOVER\destinations.json"

# ���� �� ���������
$defaultDestinations = @{
    "video" = "C:\Users\$env:USERNAME\Videos"
    "music" = "C:\Users\$env:USERNAME\Music"
    "image" = "C:\Users\$env:USERNAME\Pictures"
    "document" = "C:\Users\$env:USERNAME\Documents"
    "source" = "C:\Users\$env:USERNAME\Downloads"
}

# ���� ��� ������ ����������� ����������
$unknownExtensionsFile = "C:\Scripts\MOVER\unknown_extensions.txt"

# �������� ������������
if (Test-Path -Path $jsonFilePath) {
    try {
        $destinations = Get-Content -Path $jsonFilePath -Raw | ConvertFrom-Json
    } catch {
        Write-Host "������ ������ JSON �����. ������������ ���� �� ���������."
        $destinations = $defaultDestinations
    }
} else {
    $destinations = $defaultDestinations
    $destinations | ConvertTo-Json -Depth 10 | Set-Content -Path $jsonFilePath
}

# �������� ����� � ����� ����������
$source = $destinations.source
$videoDestination = $destinations.video
$musicDestination = $destinations.music
$imageDestination = $destinations.image
$documentDestination = $destinations.document

$allDestinations = @($videoDestination, $musicDestination, $imageDestination, $documentDestination)
foreach ($dest in $allDestinations) {
    if (-not (Test-Path -Path $dest)) {
        New-Item -ItemType Directory -Path $dest | Out-Null
        Write-Host "������� �����: $dest"
    }
}

# �������� ����������� �����
function Is-FileReady($filePath) {
    try {
        $stream = [System.IO.File]::Open($filePath, 'Open', 'Read', 'None')
        $stream.Close()
        return $true
    } catch {
        return $false
    }
}

# ������� ����������� �����
function Move-File($file, $destination) {
    try {
        if (Is-FileReady $file) {
            Write-Host "��������� ����: $file -> $destination"
            Move-Item -Path $file -Destination $destination -Force
            Write-Host "���� ���������: $file"
        } else {
            Write-Host "���� $file ����������. ����������."
        }
    } catch {
        Write-Host "������ ����������� ����� $file. $_"
    }
}

# ����������� ����������� ����������
function Log-UnknownExtension($file) {
    $extension = [System.IO.Path]::GetExtension($file).ToLower()
    if (-not [string]::IsNullOrWhiteSpace($extension)) {
        Add-Content -Path $unknownExtensionsFile -Value $extension
    } else {
        Add-Content -Path $unknownExtensionsFile -Value "��� ����������"
    }
}

# ��������� �����
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

# ������ FileSystemWatcher
$fsw = New-Object System.IO.FileSystemWatcher
$fsw.Path = $source
$fsw.IncludeSubdirectories = $false
$fsw.Filter = '*.*'

# ���������� ������� ��������
$onCreated = Register-ObjectEvent $fsw Created -Action {
    param($sender, $eventArgs)
    Start-Sleep -Milliseconds 500
    Process-File $eventArgs.FullPath
}

# ��������� ���� ������������ ������ � �������� �����
Get-ChildItem -Path $source -File | ForEach-Object {
    Process-File $_.FullName
}

# ������� ������������ �����
Start-Job -ScriptBlock {
    param ($source, $destinations)
    while ($true) {
        Get-ChildItem -Path $source -File | ForEach-Object {
            Process-File $_.FullName
        }
        Start-Sleep -Seconds 1
    }
} -ArgumentList $source, $destinations

# ������ ����������
Write-Host "`n������ �������. ���������� �� ������ $source."
while ($true) {
    Start-Sleep -Seconds 1
}

