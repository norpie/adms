Import-Module $psscriptroot\EZLog\src\EZLog.psm1

$CategoryDictionary = @{
    'INF' = 1
    'WAR' = 2
    'ERR' = 3
}

Function Get-Log-File {
    param (
        [string]$LogDir,
        [string]$LogFileName = ""
    )
    if ($LogFileName -eq "") {
        $LogFileName = "adms_$(Get-Date -Format 'yyyy-MM-dd_HH-mm-ss').log"
    }
    if (-not (Test-Path $LogDir)) {
        New-Item -ItemType Directory -Path $LogDir
    }
    return "$LogDir\$LogFileName"
}

Function Write-Log-Header {
    param (
        $LoggingOptions
    )
    Write-EZLog -Header -LogFile $LoggingOptions.LogFile
}

Function Write-Log-Footer {
    param (
        $LoggingOptions
    )
    Write-EZLog -Footer -LogFile $LoggingOptions.LogFile
}

Function Write-Log {
    param (
        $LoggingOptions,
        [string]$Category,
        [string]$Message
    )
    if ($CategoryDictionary[$Category] -ge $LoggingOptions.LogVerbosity) {
        Write-EZLog -Category $Category -Message $Message -LogFile $LoggingOptions.LogFile
    }
    if ($CategoryDictionary[$Category] -ge $LoggingOptions.ConsoleVerbosity) {
        Write-Host "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss'), $Category, $Message"
    }
}
