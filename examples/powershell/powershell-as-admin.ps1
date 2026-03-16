# NOTE: domain, username, and powershell exe name are setup-specific
$domain = "$($env:USERDOMAIN)"
$username = "$($env:USERNAME)-admin"
$powershell = "pwsh.exe"
runas "/user:$($domain)\$($username)" $powershell
