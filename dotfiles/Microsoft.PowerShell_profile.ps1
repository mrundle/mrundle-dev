# To install:
#
#    if (-not (Test-Path $PROFILE)) { New-Item -Force $PROFILE }
#    cp .\Microsoft.PowerShell_profile.ps1 $PROFILE
#
# $PROFILE looks like:
#
#   PS C:\> echo $PROFILE
#   C:\Users\Mrundle\Documents\PowerShell\Microsoft.PowerShell_profile.ps1

# note: git-bash needs to be installed
Set-Alias -Name vi -Value C:\Users\Mrundle\AppData\Local\Programs\Git\usr\bin\vim.exe
Set-Alias -Name vim -Value C:\Users\Mrundle\AppData\Local\Programs\Git\usr\bin\vim.exe
