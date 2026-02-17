$json = Get-Content debug_index.json -Raw | ConvertFrom-Json
$json | Select-Object -ExpandProperty name | Out-File all_names.txt
