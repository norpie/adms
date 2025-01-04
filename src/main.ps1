param(
    [string]
    $LogDir = "$PSScriptRoot\..\logs",
    [string]
    $ActionLogDir = "$PSScriptRoot\..\actionlogs",
    [string]
    $LogFileName,
    [string]
    $ActionLogFileName,

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

    [switch]
    $Reset,

    [string]
    $Entity,
    [string]
    $File,

    [switch]
    $Export,

    [switch]
    $MakeReport,
    [string]
    $ApiReport
)

. $PSScriptRoot/log.ps1
. $PSScriptRoot/reset.ps1
. $PSScriptRoot/actionlog.ps1
. $PSScriptRoot/locale.ps1
. $PSScriptRoot/help.ps1
. $PSScriptRoot/report.ps1
. $PSScriptRoot/ad/ou.ps1
. $PSScriptRoot/ad/user.ps1
. $PSScriptRoot/ad/group.ps1
. $PSScriptRoot/ad/groupuser.ps1
. $PSScriptRoot/ad/export.ps1

# Add exit handler, write log footer
Register-EngineEvent PowerShell.Exiting –Action {
    Write-Log-Footer
} -SupportEvent

# Set global logging options
$global:LoggingOptions = @{
    LogFile = Get-Log-File -LogDir $LogDir -LogFileName $LogFileName
    ActionLogFile = Get-Action-Log-File -LogDir $ActionLogDir -LogFileName $ActionLogFileName
    LogVerbosity = $LogVerbosity
    ConsoleVerbosity = $ConsoleVerbosity
}

# Set global action log
$global:ActionLog = @()

# Set global locale options
$Locale = Get-Best-Locale
$global:LocaleOptions = @{
    Locale = $Locale
    LocaleData = Read-Locale -Locale $Locale
}

# Handle `Help` and `H` params
if ($Help -or $H)
{
    Write-Help
    exit
}

# Set global active directory handling options
$global:ADOptions = @{
    ErrorHandling = $ErrorHandling
    OverwriteExisting = $OverwriteExisting
    FillDefaults = $FillDefaults
    RecursiveDelete = $RecursiveDelete
}

# Write both log headers
Write-Log-Header
Write-Action-Log-Header

# Handle `Reset` param
if ($Reset)
{
    Reset
    exit
}

# Handle all AD actions
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

# Main
if ($Entity -and $File)
{
    if ($Export)
    {
        Invoke-Export -Entity $Entity -File $File
    } else
    {
        if (-not (Test-Path $File))
        {
            Write-Log-Abstract -Category ERR -MessageName "FileNotFound" -AdditionalMessage $File -Exit
        }
        $Actions = Import-Csv -Path $File
        Invoke-Actions -Entity $Entity -Actions $Actions
        if ($MakeReport)
        {
            Write-Report -ApiReport $ApiReport
        }
    }
    exit
} elseif (-not $Entity)
{
    Write-Log-Abstract -Category ERR -MessageName "MissingParameter" -AdditionalMessage "-Entity" -Exit
} elseif (-not $File)
{
    Write-Log-Abstract -Category ERR -MessageName "MissingParameter" -AdditionalMessage "-File" -Exit
}

# If no parameters are passed, show help
Write-Help
