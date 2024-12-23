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
    $OUAddInputFile,
    [string]
    $OUDeleteInputFile,
    [string]
    $OUModifyInputFile,

    [string]
    $UserAddInputFile,
    [string]
    $UserDeleteInputFile,
    [string]
    $UserModifyInputFile,

    [string]
    $GroupAddInputFile,
    [string]
    $GroupDeleteInputFile,
    [string]
    $GroupModifyInputFile,

    [string]
    $ExportOUsFile,
    [string]
    $ExportUsersFile,
    [string]
    $ExportGroupsFile,

    [string]
    $LinkInputFile
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

Write-Log-Header

# OU Operations
if ($OUAddInputFile)
{
    New-OUs -OUInputFile $OUAddInputFile
}

if ($OUDeleteInputFile)
{
    Remove-OUs -OUInputFile $OUDeleteInputFile
}

if ($OUModifyInputFile)
{
    Edit-OUs -OUInputFile $OUModifyInputFile
}

# User Operations
if ($UserAddInputFile)
{
    New-Users -UserInputFile $UserAddInputFile
}

if ($UserDeleteInputFile)
{
    Remove-Users -UserInputFile $UserDeleteInputFile
}

if ($UserModifyInputFile)
{
    Edit-Users -UserInputFile $UserModifyInputFile
    What;
}

# Group Operations
if ($GroupAddInputFile)
{
    New-Groups -GroupInputFile $GroupAddInputFile
}

if ($GroupDeleteInputFile)
{
    Remove-Groups -GroupInputFile $GroupDeleteInputFile
}

if ($GroupModifyInputFile)
{
    Edit-Groups -GroupInputFile $GroupModifyInputFile
}

# Export Operations
if ($ExportOUsFile)
{
    Export-OUs -OUExportFile $ExportOUsFile
}

if ($ExportGroupsFile)
{
    Export-Groups -GroupExportFile $ExportGroupsFile
}

if ($ExportUsersFile)
{
    Export-Users -UserExportFile $ExportUsersFile
}

Write-Log-Footer
