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
. $PSScriptRoot/actionlog.ps1
. $PSScriptRoot/locale.ps1
. $PSScriptRoot/help.ps1
. $PSScriptRoot/report.ps1
. $PSScriptRoot/ad/ou.ps1
. $PSScriptRoot/ad/user.ps1
. $PSScriptRoot/ad/group.ps1
. $PSScriptRoot/ad/groupuser.ps1
. $PSScriptRoot/ad/export.ps1

Register-EngineEvent PowerShell.Exiting –Action {
    Write-Log-Footer
} -SupportEvent

$global:LoggingOptions = @{
    LogFile = Get-Log-File -LogDir $LogDir -LogFileName $LogFileName
    ActionLogFile = Get-Action-Log-File -LogDir $ActionLogDir -LogFileName $ActionLogFileName
    LogVerbosity = $LogVerbosity
    ConsoleVerbosity = $ConsoleVerbosity
}

$global:ActionLog = @()

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

function Reset
{
    Write-Log-Abstract -Category INF -MessageName "Resetting"
    $OUs = Get-ADOrganizationalUnit -Filter * -Properties CanonicalName | Where-Object { $_.Name -notin $DefaultOUs } | Sort-Object -Descending { $_.DistinguishedName.Length }
    foreach ($OU in $OUs)
    {
        Write-Log-Abstract -Category INF -MessageName "RemovingOU" -AdditionalMessage $OU.Name
        Set-ADObject -Identity $OU.DistinguishedName -ProtectedFromAccidentalDeletion:$false
        Remove-ADOrganizationalUnit -Identity $OU.DistinguishedName -Recursive -Confirm:$false
        Write-Log-Abstract -Category INF -MessageName "RemovedOU" -AdditionalMessage $OU.Name
    }
    Write-Log-Abstract -Category INF -MessageName "Resetted"
}

Write-Log-Header
Write-Action-Log-Header

if ($Reset)
{
    Reset
    exit
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

Function Invoke-Export
{
    param (
        [string]
        $Entity,
        [string]
        $File
    )
    if ($Entity -eq "OU")
    {
        Export-OUs -File $File
    } elseif ($Entity -eq "User")
    {
        Export-Users -File $File
    } elseif ($Entity -eq "Group")
    {
        Export-Groups -File $File
    } else
    {
        Write-Log-Abstract -Category ERR -MessageName "UnknownEntity" -AdditionalMessage $Entity -Exit
    }
}

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

Write-Help
