$urls = @(
    "https://raw.githubusercontent.com/yuzono/anime-repo/repo/index.min.json",
    "https://raw.githubusercontent.com/almightyhak/aniyomi-anime-repo/main/index.min.json"
)

foreach ($url in $urls) {
    Write-Host "Checking $url ..."
    try {
        $content = Invoke-WebRequest -Uri $url -UseBasicParsing
        if ($content.Content -match "Javguru|JavGG|MissAV") {
            Write-Host "FOUND targets in $url"
            # Print matching part details
            $json = $content.Content | ConvertFrom-Json
            $targets = "Javguru", "JavGG", "MissAV"
            foreach ($t in $targets) {
                $match = $json | Where-Object { $_.name -like "*$t*" -or $_.pkg -like "*$t*" }
                if ($match) {
                     Write-Host "  Found: $($match.name) - $($match.pkg) - Version: $($match.version)"
                }
            }
        } else {
            Write-Host "  Targets NOT found in $url"
        }
    } catch {
        Write-Host "  Failed to download $url : $_"
    }
    Write-Host "--------------------------------"
}
