# PowerShell Translation Examples

Below are reference examples showing how common bash scripts and prose instructions are translated into PowerShell 7.

## Example 1: Finding and Replacing Text in Files
### Original Bash
```bash
find src/ -type f -name "*.js" -exec sed -i 's/http:\/\/localhost/https:\/\/api.production.com/g' {} +
```

### PowerShell 7 Equivalent
```powershell
Get-ChildItem -Path "src" -Filter "*.js" -File -Recurse | ForEach-Object {
    $content = Get-Content -Path $_.FullName -Raw
    $updated = $content -replace 'http://localhost', 'https://api.production.com'
    if ($content -ne $updated) {
        Set-Content -Path $_.FullName -Value $updated -NoNewline
    }
}
```

---

## Example 2: API Call with JSON Parsing and Error Checking
### Original Bash
```bash
res=$(curl -s -w "%{http_code}" -o response.json -X POST \
  -H "Content-Type: application/json" \
  -d '{"status":"active"}' \
  https://api.example.com/users)

if [ "$res" -ne 200 ]; then
  echo "Error: API returned status $res" >&2
  exit 1
fi
```

### PowerShell 7 Equivalent
```powershell
$uri = "https://api.example.com/users"
$body = @{ status = "active" } | ConvertTo-Json
$headers = @{ "Content-Type" = "application/json" }

try {
    $response = Invoke-WebRequest -Uri $uri -Method Post -Body $body -Headers $headers -SkipHttpErrorCheck
    if ($response.StatusCode -ne 200) {
        Write-Error "Error: API returned status $($response.StatusCode)"
        exit 1
    }
    Set-Content -Path "response.json" -Value $response.Content
} catch {
    Write-Error "Failed to connect to API: $_"
    exit 1
}
```

---

## Example 3: Pipeline chaining with conditional execution
### Original Bash
```bash
./build.sh && ./test.sh || echo "Build or test failed"
```

### PowerShell 7 Equivalent
```powershell
# PowerShell 7 supports && and || pipeline operators directly!
.\build.ps1 && .\test.ps1 || Write-Output "Build or test failed"
```
