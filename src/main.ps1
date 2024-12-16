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
    $ConsoleVerbosity = 1,

    [switch]
    $Help,
    [switch]
    $H,

    [int]
    [ValidateRange(1, 3)]
    $ErrorHandling = 3, # 3 = Stop, 2 = Warn Skip, 1 = Silent Skip
    [switch]
    $OverwriteExisting,
    [switch]
    $FillDefaults,

    [string]
    $OUInputFile,
    [string]
    $UserInputFile,
    [string]
    $GroupInputFile,

    [string]
    $PolicyInputFile,

    [string]
    $LinkInputFile
)

. $PSScriptRoot/log.ps1
. $PSScriptRoot/locale.ps1
. $PSScriptRoot/help.ps1

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

if ($Help -or $H)
{
    Write-Help -LocaleOptions $LocaleOptions
    exit
}

$ADOptions = @{
    ErrorHandling = $ErrorHandling
    OverwriteExisting = $OverwriteExisting
    FillDefaults = $FillDefaults
}

Write-Log-Header -LoggingOptions $LoggingOptions
Write-Log-Footer -LoggingOptions $LoggingOptions
