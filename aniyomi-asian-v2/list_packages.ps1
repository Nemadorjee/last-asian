$json = Get-Content debug_index.json -Raw | ConvertFrom-Json
$json | Where-Object { $_.name -match "Jav|Miss|Sup|Net|Tachiyomi" } | Select-Object name, pkg, version | Format-Table -AutoSize
