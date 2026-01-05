# BulkRenameMedia
This repo is for renaming large amounts of pictures and videos in a specific folder based on dates taken. This allows for ease of organization and search.

### ExifTool Use:
You will need to download the correct version of exiftools from the site: https://exiftool.org/
Unzip and change the name of the .exe inside from exiftools(-k).exe to exiftools.exe
Move the whole folder whereever and add the folder path to PATH (in environment variables settings)

### PS1 Usage:
Move the RenamePics.ps1 and RenameVids.ps1 into the folder to sort media.
Open powershell in that folder.
Run this command:

'''ps1
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "RenamePics.ps1"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "RenameVids.ps1"
'''

### Notes:
Change lines that look like below if you want a different name format:
Ex). yyMMdd_HHmm => 251231_2359
'''ps1
$base = $dt.ToString('yyMMdd_HHmm')
$base = $f.LastWriteTime.ToString('yyMMdd_HHmm')
'''
