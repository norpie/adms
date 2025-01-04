# This file implements the help command for the shell.
. $PSScriptRoot/locale.ps1

# This is the padding for the help command.
$Tab = [char]9

# This function returns the padding for the help command.
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

# This function writes the help command.
Function Write-Help {
    $Message = Get-Message -MessageName "Name"
    Write-Host $Message
    Write-Host "$Tab adms.ps1"
    $Parameters = @(
        "LogDir",
        "ActionLogDir",
        "LogFileName",
        "ActionLogFileName",
        "LogVerbosity",
        "ConsoleVerbosity",
        "Help",
        "ErrorHandling",
        "Reset"
        "OverwriteExisting",
        "FillDefaults",
        "RecursiveDelete",
        "Entity",
        "File",
        "Export"
    )
    $Aliases = @{
        "H" = "Help"
    }
    $Padding = Get-Padding -Content $Parameters
    $Padding = Get-Padding -CurrentPadding $Padding -Content $Aliases.Keys
    Write-Help-Section -Padding $Padding -SectionName "Parameters" -SectionContent $Parameters
    Write-Help-Section -Padding $Padding -SectionName "ParameterAliases" -SectionContent $Aliases
}

# Helper function to write a help section
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
