. $PSScriptRoot\..\log.ps1

# Helper function to read a field and handle missing fields properly
Function Read-Field
{
    param (
        $Field,
        $FieldName,
        $Default
    )
    if (-not $Field)
    {
        if ($Default -and $global:ADOptions.FillDefaults)
        {
            Write-Log-Abstract -Category 'INF' -MessageName 'MissingFieldDefault' -AdditionalMessage "$($FieldName): $Default"
            return $Default
        }
        if ($global:ADOptions.ErrorHandling -eq 3)
        {
            Write-Log-Abstract -Category 'ERR' -MessageName 'MissingField' -AdditionalMessage "$FieldName" -Throw
        } elseif ($global:ADOptions.ErrorHandling -eq 2)
        {
            Write-Log-Abstract -Category 'WAR' -MessageName 'MissingField' -AdditionalMessage "$FieldName"
        }
    }
    return $Field
}
