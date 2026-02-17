$urls = @(
    "https://raw.githubusercontent.com/Nemadorjee/anuj-study-repo/main/index.min.json",
    "https://raw.githubusercontent.com/Nemadorjee/anuj-study-repo/main/aniyomi-asian-v2/index.min.json",
    "https://raw.githubusercontent.com/Nemadorjee/anuj-study-repo/master/index.min.json"
)

foreach ($u in $urls) {
    Write-Host "---------------------------------------------------"
    Write-Host "Checking Index URL: $u ..."
    try {
        $r = Invoke-WebRequest -Uri $u -UseBasicParsing -ErrorAction Stop
        if ($r.StatusCode -eq 200) {
            Write-Host "  [OK] Index found." -ForegroundColor Green
            
            # Parse JSON to check APK links
            try {
                $json = $r.Content | ConvertFrom-Json
                Write-Host "  Found $($json.Count) extensions in index."
                
                # Assume base URL is the directory of the index
                $baseUrl = $u.Substring(0, $u.LastIndexOf('/'))
                
                foreach ($ext in $json) {
                    $apkUrl = "$baseUrl/$($ext.apk)"
                    Write-Host "  Checking APK: $($ext.name) -> $apkUrl"
                    try {
                        $apkCheck = Invoke-WebRequest -Uri $apkUrl -Method Head -ErrorAction Stop
                        if ($apkCheck.StatusCode -eq 200) {
                            Write-Host "    [OK] APK Found" -ForegroundColor Green
                        }
                        else {
                            Write-Host "    [FAIL] Status: $($apkCheck.StatusCode)" -ForegroundColor Red
                        }
                    }
                    catch {
                        Write-Host "    [FAIL] APK Missing or Unreachable: $_" -ForegroundColor Red
                    }
                }

            }
            catch {
                Write-Host "  [FAIL] content is not valid JSON: $_" -ForegroundColor Red
            }
        }
    }
    catch {
        Write-Host "  [FAIL] Index URL unreachable: $_" -ForegroundColor Red
    }
}
