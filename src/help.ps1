# This file implements the help command for the shell.
. $PSScriptRoot/locale.ps1

$Tab = [char]9

Function Get-Padding {
    param (
        $CurrentPadding,
        $Content
    )
    $MaxLength = $CurrentPadding
    foreach ($Content in $Content) {
        if ($Content.Length -gt $MaxLength) {
            $MaxLength = $Content.Length
        }
    }
    return $MaxLength
}

Function Write-Help {
    $Message = Get-Message -MessageName "Name"
    Write-Host $Message
    Write-Host "$Tab adms.ps1"
    $Parameters = @(
        "LogDir",
        "LogFileName",
        "LogVerbosity",
        "ConsoleVerbosity",
        "Help",
        "ErrorHandling",
        "OverwriteExisting",
        "FillDefaults",
        "OUInputFile",
        "UserInputFile",
        "GroupInputFile",
        "PolicyInputFile",
        "LinkInputFile"
    )
    $Aliases = @{
        "H" = "Help"
    }
    $Padding = Get-Padding -Content $Parameters
    $Padding = Get-Padding -CurrentPadding $Padding -Content $Aliases.Keys
    Write-Help-Section -Padding $Padding -SectionName "Parameters" -SectionContent $Parameters
    Write-Help-Section -Padding $Padding -SectionName "ParameterAliases" -SectionContent $Aliases
}

Function Write-Help-Section {
    param (
        $Padding,
        $SectionName,
        $SectionContent
    )
    $Message = Get-Message -MessageName $SectionName
    Write-Host $Message
    if ($SectionContent -is [array]) {
        foreach ($Content in $SectionContent) {
            $Message = Get-Message -MessageName "Help$Content"
            $Content = $Content.PadRight($Padding)
            Write-Host "$Tab -${Content} $Message"
        }
    } else {
        foreach ($Key in $SectionContent.Keys) {
            $Value = $SectionContent[$Key]
            $PaddedKey = $Key.PadRight($Padding)
            Write-Host "$Tab -$PaddedKey -$Value"
        }
    }
}
