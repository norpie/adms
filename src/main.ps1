param(
    [string]
    $LogDir = "$PSScriptRoot\..\logs",

    [string]
    $LogFileName,

    [int]
    [ValidateRange(1, 3)]
    $LogVerbosity = 1,

    [int]
    [ValidateRange(1, 3)]
    $ConsoleVerbosity = 1
)

. $PSScriptRoot/log.ps1
. $PSScriptRoot/locale.ps1

$LoggingOptions = @{
    LogFile = Get-Log-File -LogDir $LogDir -LogFileName $LogFileName
    LogVerbosity = $LogVerbosity
    ConsoleVerbosity = $ConsoleVerbosity
}

$Locale = Get-Best-Locale

$LocaleOptions = @{
    Locale = $Locale
    LocaleData = Read-Locale -Locale $Locale
}

$Greeting = Get-Message -LocaleOptions $LocaleOptions -MessageName 'GREET'

Write-Log-Header -LoggingOptions $LoggingOptions
Write-Log        -LoggingOptions $LoggingOptions -Category INF -Message "$Greeting"
Write-Log-Footer -LoggingOptions $LoggingOptions
