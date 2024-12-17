Function Read-Field
{
    param (
        $Field,
        $Default
    )
    if (-not $Field)
    {
        if ($Default)
        {
            Write-Log-Abstract -Category 'INF' -MessageName 'MissingFieldDefault' -AdditionalMessage "$Field"
            return $Default
        }
        if ($global:ADOptions.ErrorHandling -eq 3)
        {
            Write-Log-Abstract -Category 'ERR' -MessageName 'MissingField' -AdditionalMessage "$Field" -Throw
        } elseif ($global:ADOptions.ErrorHandling -eq 2)
        {
            Write-Log-Abstract -Category 'WAR' -MessageName 'MissingField' -AdditionalMessage "$Field"
        }
    }
    return $Field
}
