function Write-Host {
    param(
        [Parameter(Position=0, ValueFromPipeline=$true)]
        [Object]$Object,
        [switch]$NoNewline
    )
    $timestamp = Get-Date -UFormat "%Y-%m-%dT%H:%M:%S%Z:00"
    Microsoft.PowerShell.Utility\Write-Host "[$timestamp] $Object" -NoNewline:$NoNewline
}

Write-Host "testing normal call"
"testing piped call" | Write-Host
Write-Host "testing null call..."
Write-Host $null
Write-Host "testing non-string input (type coercion)..."
Write-Host 42
Write-Host $true
Write-Host "testing -NoNewline"
Write-Host "call1" -NoNewline
Write-Host "call2" -NoNewline
Write-Host
Write-Host finished
