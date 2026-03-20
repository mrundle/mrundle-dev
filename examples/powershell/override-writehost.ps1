function Write-Host {
    param(
        [Parameter(Position=0, ValueFromPipeline=$true)]
        [Object]$Object,
        [switch]$NoNewline
    )
    $timestamp = Get-Date -UFormat "%Y-%m-%dT%H:%M:%S%Z:00"
    Microsoft.PowerShell.Utility\Write-Host "[$timestamp] $Object" -NoNewline:$NoNewline
}

# tests
Write-Host "testing normal call"
"testing piped call" | Write-Host
Write-Host "testing non-string input (type coercion)..."
Write-Host 42
Write-Host $true
Write-Host "testing -NoNewline"
Write-Host "call1" -NoNewline
Write-Host "call2" -NoNewline
Write-Host
Write-Host "testing empty/blank calls"
try {
    Write-Host
    Write-Host ""
    Write-Host $null
} catch {
    Write-Error "FAIL: empty Write-Host threw: $_"
}
Write-Host finished
