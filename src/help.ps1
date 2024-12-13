# This file implements the help command for the shell.
. $PSScriptRoot/locale.ps1

Function Write-Help {
    param(
        $LocaleOptions
    )
    $Parameters = @(
        "LogDir",
        "LogFileName",
        "LogVerbosity",
        "ConsoleVerbosity",
        "Help"
    )
    $Tab = [char]9
    $Message = Get-Message -LocaleOptions $LocaleOptions -MessageName "NAME"
    Write-Host $Message
    Write-Host "$Tab adms.ps1"
    $Message = Get-Message -LocaleOptions $LocaleOptions -MessageName "PARAMETERS"
    Write-Host $Message
    foreach ($Parameter in $Parameters) {
        $Message = Get-Message -LocaleOptions $LocaleOptions -MessageName "Help$Parameter"
        Write-Host "$Tab ${Parameter}: $Message"
    }
}
