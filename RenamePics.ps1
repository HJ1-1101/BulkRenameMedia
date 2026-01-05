Add-Type -AssemblyName System.Drawing

# Target extensions ONLY
$extensions = @('.jpg', '.jpeg', '.png', '.webp')

# Regex for already-renamed files (skip these)
$alreadyRenamedPattern = '^\d{6}_\d{4}(_\d+)?$'

$files = Get-ChildItem -File | Where-Object {
    $extensions -contains $_.Extension.ToLower() -and
    $_.BaseName -notmatch $alreadyRenamedPattern
}

$total = $files.Count
$index = 0

foreach ($f in $files) {
    $index++

    Write-Progress `
        -Activity "Renaming Picture media" `
        -Status "$index of ${total}: $($f.Name)"
        -PercentComplete (($index / $total) * 100)

    $base = $null

    try {
        # Read file into memory to avoid file lock
        $bytes = [System.IO.File]::ReadAllBytes($f.FullName)
        $ms = New-Object System.IO.MemoryStream(,$bytes)
        $img = [System.Drawing.Image]::FromStream($ms)

        if ($img.PropertyIdList -contains 36867) {
            $raw = [Text.Encoding]::ASCII.GetString(
                $img.GetPropertyItem(36867).Value
            ).Trim([char]0)

            $dt = [datetime]::ParseExact(
                $raw,
                'yyyy:MM:dd HH:mm:ss',
                $null
            )

            $base = $dt.ToString('yyMMdd_HHmm')
        }

        $img.Dispose()
        $ms.Dispose()
    }
    catch {
        # fallback if EXIF read fails
        $base = $f.LastWriteTime.ToString('yyMMdd_HHmm')
    }

    if (-not $base) {
        $base = $f.LastWriteTime.ToString('yyMMdd_HHmm')
    }

    $ext = $f.Extension
    $newName = "$base$ext"
    $i = 1

    while (Test-Path $newName) {
        $newName = "${base}_$i$ext"
        $i++
    }

    Rename-Item $f.FullName $newName
}

Write-Host "`nDone renaming picture files."
Write-Host "Press any key to exit..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
