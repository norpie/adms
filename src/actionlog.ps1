# Get the action log file path and create the file if it doesn't exist
Function Get-Action-Log-File
{
    param (
        [string]$LogDir,
        [string]$LogFileName = ""
    )
    if ($LogFileName -eq "")
    {
        $LogFileName = "adms_actionlog_$(Get-Date -Format 'yyyy-MM-dd_HH-mm-ss').csv"
    }
    if (-not (Test-Path $LogDir))
    {
        New-Item -ItemType Directory -Path $LogDir
    }
    return "$LogDir\$LogFileName"
}

# Write the header to the action log file
Function Write-Action-Log-Header
{
    $ActionLog = $global:LoggingOptions.ActionLogFile
    Add-Content -Path $ActionLog -Value "Entity,Action,Id,Result"
}

# Write an action to the action log file
Function Write-Action-To-Action-Log
{
    param (
        [string]$Entity,
        [string]$Action,
        [string]$Id,
        [string]$Result
    )
    $ActionLog = $global:LoggingOptions.ActionLogFile
    Add-Content -Path $ActionLog -Value "$Entity,$Action,$Id,$Result"
    $ActionObject = @{
        Entity = $Entity
        Action = $Action
        Id = $Id
        Result = $Result
    }
    $global:ActionLog += $ActionObject
}
