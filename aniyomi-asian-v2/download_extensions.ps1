$repoIndexUrl = "https://raw.githubusercontent.com/yuzono/anime-repo/repo/index.min.json"
$repoApkBaseUrl = "https://raw.githubusercontent.com/yuzono/anime-repo/repo/apk/"
$targetExtensions = @("Javguru", "JavGG", "MissAV", "SupJav", "Netflav")
$outputDir = "apk"

# Create output directory if it doesn't exist
if (-not (Test-Path $outputDir)) {
    New-Item -ItemType Directory -Force -Path $outputDir
}

# Download the index
Write-Host "Downloading index from $repoIndexUrl..."
try {
    $indexContent = Invoke-WebRequest -Uri $repoIndexUrl -UseBasicParsing | Select-Object -ExpandProperty Content
    $extensions = $indexContent | ConvertFrom-Json
}
catch {
    Write-Error "Failed to download index: $_"
    exit 1
}

$newIndex = @()

foreach ($extName in $targetExtensions) {
    Write-Host "Processing $extName..."
    # Filter for the extension (flexible match on name or pkg)
    $ext = $extensions | Where-Object { 
        ($_.name -like "*$extName*" -or $_.pkg -like "*$extName*") -and $_.pkg -like "*animeextension*"
    } | Select-Object -First 1

    if ($ext) {
        Write-Host "  Found: $($ext.name) ($($ext.pkg))"
        $apkFilename = $ext.apk
        $downloadUrl = "$repoApkBaseUrl$apkFilename"
        $outputFilename = "$outputDir/$($extName.ToLower()).apk"

        Write-Host "  Downloading APK from $downloadUrl to $outputFilename..."
        try {
            Invoke-WebRequest -Uri $downloadUrl -OutFile $outputFilename
            

            # Create a clean object to avoid side effects
            $newEntry = $ext | Select-Object *
            
            # Use Add-Member to safely add/update properties
            # Ensure 'apk' matches our renamed file AND includes the directory prefix
            $apkValue = "apk/$($extName.ToLower()).apk"
            if ($newEntry | Get-Member -Name "apk") {
                $newEntry.apk = $apkValue
            }
            else {
                $newEntry | Add-Member -MemberType NoteProperty -Name "apk" -Value $apkValue -Force
            }

            # Ensure 'isNsfw' is set to true
            if ($newEntry | Get-Member -Name "isNsfw") {
                $newEntry.isNsfw = $true
            }
            else {
                $newEntry | Add-Member -MemberType NoteProperty -Name "isNsfw" -Value $true -Force
            }
            
            # Also set 'nsfw' to 1 (int) just in case
            if ($newEntry | Get-Member -Name "nsfw") {
                $newEntry.nsfw = 1
            }
            else {
                $newEntry | Add-Member -MemberType NoteProperty -Name "nsfw" -Value 1 -Force
            }

            $newIndex += $newEntry
        }
        catch {
            Write-Error "  Failed to download APK: $_"
        }
    }
    else {
        Write-Warning "  Extension '$extName' not found in source index."
    }
}


# Generate the new index.min.json
$jsonOutput = $newIndex | ConvertTo-Json -Depth 10 -Compress
# Write UTF-8 NO BOM to avoid issues with some JSON parsers (especially Aniyomi/Tachiyomi)
$utf8NoBom = New-Object System.Text.UTF8Encoding $false
[System.IO.File]::WriteAllText("$PWD/index.min.json", $jsonOutput, $utf8NoBom)

Write-Host "Success! Index generated with $($newIndex.Count) extensions."

