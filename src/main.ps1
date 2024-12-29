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
    [switch]
    $RecursiveDelete,

    [string]
    $Entity,
    [string]
    $Operation,
    [string]
    $File
)

. $PSScriptRoot/log.ps1
. $PSScriptRoot/locale.ps1
. $PSScriptRoot/help.ps1
. $PSScriptRoot/ad/ou.ps1
. $PSScriptRoot/ad/user.ps1
. $PSScriptRoot/ad/export.ps1

$global:LoggingOptions = @{
    LogFile = Get-Log-File -LogDir $LogDir -LogFileName $LogFileName
    LogVerbosity = $LogVerbosity
    ConsoleVerbosity = $ConsoleVerbosity
}

$Locale = Get-Best-Locale

$global:LocaleOptions = @{
    Locale = $Locale
    LocaleData = Read-Locale -Locale $Locale
}

if ($Help -or $H)
{
    Write-Help
    exit
}

$global:ADOptions = @{
    ErrorHandling = $ErrorHandling
    OverwriteExisting = $OverwriteExisting
    FillDefaults = $FillDefaults
    RecursiveDelete = $RecursiveDelete
}

function Invoke-Operation
{
    param (
        [string]
        $Operation,
        $Content
    )
    if ($Entity -eq "OU")
    {
        Invoke-OU-Operation -Operation $Operation -Content $Content
    } elseif ($Entity -eq "User")
    {
        Invoke-User-Operation -Operation $Operation -Content $Content
    } elseif ($Entity -eq "Group")
    {
        Invoke-Group-Operation -Operation $Operation -Content $Content
    }
}

Write-Log-Header

if ($Entity -and $Operation -and $File)
{
    if (-not (Test-Path $File))
    {
        Write-Log-Abstract -Category ERR -MessageName "FileNotFound" -AdditionalMessage $File -Exit
    }
    $Content = Import-Csv -Path $File
    Invoke-Operation -Operation $Operation -Content $Content
} elseif (-not $Entity)
{
    Write-Log-Abstract -Category ERR -MessageName "MissingParameter" -AdditionalMessage "-Entity" -Exit
} elseif (-not $Operation)
{
    Write-Log-Abstract -Category ERR -MessageName "MissingParameter" -AdditionalMessage "-Operation" -Exit
} elseif (-not $File)
{
    Write-Log-Abstract -Category ERR -MessageName "MissingParameter" -AdditionalMessage "-File" -Exit
}

Write-Log-Footer
