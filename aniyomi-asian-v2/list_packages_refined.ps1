$json = Get-Content debug_index.json -Raw | ConvertFrom-Json
$targets = "Javguru", "JavGG", "MissAV", "SupJav", "Netflav"
foreach ($target in $targets) {
    Write-Host "Searching for $target..."
    $match = $json | Where-Object { $_.name -like "*$target*" -or $_.pkg -like "*$target*" }
    if ($match) {
        $match | Select-Object name, pkg, version | Format-Table -AutoSize
    } else {
        Write-Host "  Not found."
    }
}
