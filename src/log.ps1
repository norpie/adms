Import-Module EZLog.psm1

. $psscriptroot\locale.ps1

$CategoryDictionary = @{
    'INF' = 1
    'WAR' = 2
    'ERR' = 3
}

# Get the log file for current date etc.
Function Get-Log-File
{
    param (
        [string]$LogDir,
        [string]$LogFileName = ""
    )
    if ($LogFileName -eq "")
    {
        $LogFileName = "adms_$(Get-Date -Format 'yyyy-MM-dd_HH-mm-ss').log"
    }
    if (-not (Test-Path $LogDir))
    {
        New-Item -ItemType Directory -Path $LogDir
    }
    return "$LogDir\$LogFileName"
}

# Wrapper for EZLog header with set params
Function Write-Log-Header
{
    Write-EZLog -Header -LogFile $global:LoggingOptions.LogFile
}

# Wrapper for EZLog footer with set params
Function Write-Log-Footer
{
    Write-EZLog -Footer -LogFile $global:LoggingOptions.LogFile
}

# Wrapper for EZLog with set params, takes raw message and category
Function Write-Log
{
    param (
        [string]$Category,
        [string]$Message
    )
    if ($CategoryDictionary[$Category] -ge $global:LoggingOptions.ConsoleVerbosity)
    {
        Write-Host "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss'), $Category, $Message"
    }
    if ($CategoryDictionary[$Category] -ge $global:LoggingOptions.LogVerbosity)
    {
        Write-EZLog -Category $Category -Message $Message -LogFile $LoggingOptions.LogFile
    }
}

# Wrapper for Write-Log, takes message name which is used to get message from dictionary,
# additional message and switch for throw exception or exit program.
Function Write-Log-Abstract
{
    param (
        [string]$Category,
        [string]$MessageName,
        $AdditionalMessage,
        [switch]$Throw,
        [switch]$Exit
    )
    $Message = Get-Message -MessageName $MessageName
    $FullMessage = "$Message"
    if ($AdditionalMessage -ne "")
    {
        $FullMessage = "$Message $AdditionalMessage"
    }
    Write-Log -Category $Category -Message $FullMessage
    if ($Exit)
    {
        exit
    }
    if ($Throw)
    {
        throw $FullMessage
    }
}
