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

$LoggingOptions = @{
    LogFile = Get-Log-File -LogDir $LogDir -LogFileName $LogFileName
    LogVerbosity = $LogVerbosity
    ConsoleVerbosity = $ConsoleVerbosity
}

Write-Log-Header -LoggingOptions $LoggingOptions
Write-Log        -LoggingOptions $LoggingOptions -Category INF -Message 'This is an information to be written in the log file'
Write-Log        -LoggingOptions $LoggingOptions -Category ERR -Message 'This is an error to be written in the log file'
Write-Log        -LoggingOptions $LoggingOptions -Category WAR -Message 'This is a warning to be written in the log file'
Write-Log-Footer -LoggingOptions $LoggingOptions
