$ErrorActionPreference = 'SilentlyContinue'

# Target extensions ONLY
$extensions = @('.mp4', '.mov', '.webp', '.gif')

# Regex for already-renamed files (skip these)
$alreadyRenamedPattern = '^\d{6}_\d{4}(_\d+)?$'

# Tags that exiftools should check in order
$tags = @(
    'CreateDate',
    'MediaCreateDate',
    'TrackCreateDate'
)

$files = Get-ChildItem -File | Where-Object {
    $extensions -contains $_.Extension.ToLower() # -and
    $_.BaseName -notmatch $alreadyRenamedPattern
}

$total = $files.Count
$index = 0

$shell = New-Object -ComObject Shell.Application

foreach ($f in $files) {
    $index++

    Write-Progress `
        -Activity "Renaming Video media" `
        -Status "$index of ${total}: $($f.Name)"
        -PercentComplete (($index / $total) * 100)

    $base = $null
    $ext  = $f.Extension.ToLower()

    # Try media metadata for MP4 only

    foreach ($tag in $tags) {
        try {
            $raw = & exiftool -s -s -s -$tag $f.FullName
            if ($raw) {
                $dt = [datetime]::ParseExact(
                    $raw,
                    'yyyy:MM:dd HH:mm:ss',
                    $null
                )
                $base = $dt.ToString('yyMMdd_HHmm')
                break
            }
        }
        catch { }
    }

    # Fallback to filesystem time
    if (-not $base) {
        $base = $f.LastWriteTime.ToString('yyMMdd_HHmm')
    }

    $newName = "$base$ext"
    $i = 1

    while (Test-Path $newName) {
        $newName = "${base}_$i$ext"
        $i++
    }

    Rename-Item $f.FullName $newName
}

Write-Host "`nDone renaming video files."
Write-Host "Press any key to exit..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
