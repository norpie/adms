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
    $File
)

. $PSScriptRoot/log.ps1
. $PSScriptRoot/locale.ps1
. $PSScriptRoot/help.ps1
. $PSScriptRoot/ad/ou.ps1
. $PSScriptRoot/ad/user.ps1
. $PSScriptRoot/ad/group.ps1
. $PSScriptRoot/ad/groupuser.ps1
. $PSScriptRoot/ad/export.ps1

Register-EngineEvent PowerShell.Exiting –Action {
    Write-Log-Footer
}

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

function Invoke-Actions
{
    param (
        [string]
        $Entity,
        $Actions
    )
    if ($Entity -eq "OU")
    {
        Invoke-OU-Actions -Actions $Actions
    } elseif ($Entity -eq "User")
    {
        Invoke-User-Actions -Actions $Actions
    } elseif ($Entity -eq "Group")
    {
        Invoke-Group-Actions -Actions $Actions
    } elseif ($Entity -eq "GroupUser")
    {
        Invoke-GroupUser-Actions -Actions $Actions
    } else
    {
        Write-Log-Abstract -Category ERR -MessageName "UnknownEntity" -AdditionalMessage $Entity -Exit
    }
}

Write-Log-Header

if ($Entity -and $File)
{
    if (-not (Test-Path $File))
    {
        Write-Log-Abstract -Category ERR -MessageName "FileNotFound" -AdditionalMessage $File -Exit
    }
    $Actions = Import-Csv -Path $File
    Invoke-Actions -Entity $Entity -Actions $Actions
} elseif (-not $Entity)
{
    Write-Log-Abstract -Category ERR -MessageName "MissingParameter" -AdditionalMessage "-Entity" -Exit
} elseif (-not $File)
{
    Write-Log-Abstract -Category ERR -MessageName "MissingParameter" -AdditionalMessage "-File" -Exit
}
