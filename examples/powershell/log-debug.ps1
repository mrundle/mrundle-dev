function logCheckpoint {
    # this function write-hosts a timestamp message noting the file, line, and
    # (if any) function where it was called
    param ([string]$optional_message = "n/a")
    $timestamp = Get-Date -UFormat "%Y-%m-%dT%H:%M:%S%Z:00"
    $obj = Get-PSCallStack | Select-Object -Index 1
    Write-Host (
        "[$timestamp] Checkpoint @ $($obj.ScriptName):$($obj.ScriptLineNumber) " +
        "(func=$($obj.FunctionName), args=$($obj.Arguments)) msg=($optional_message)"
    )
}

function someFunction {
    logCheckpoint
}

Write-Host "calling checkpoint from inside function..."
someFunction someFunctionArg1 someFunctionArg2
Write-Host "calling checkpoint from outside function..."
logCheckpoint
Write-Host "calling checkpoint with message..."
logCheckpoint "important context"
