Function Read-Field
{
    param (
        $LoggingOptions,
        $LocaleOptions,
        $ADOptions,
        $Field,
        $Default = $null
    )
    if (-not $Field)
    {
        if ($ADOptions.FillDefaults)
        {
            Write-Log-Abstract -LoggingOptions $LoggingOptions -LocaleOptions $LocaleOptions -Category 'INF' -MessageName 'MissingFieldDefault' -AdditionalMessage "$Field"
            return $Default
        }
        if ($ADOptions.ErrorHandling -eq 3)
        {
            Write-Log-Abstract -LoggingOptions $LoggingOptions -LocaleOptions $LocaleOptions -Category 'ERR' -MessageName 'MissingField' -AdditionalMessage "$Field" -Throw
        } elseif ($ADOptions.ErrorHandling -eq 2)
        {
            Write-Log-Abstract -LoggingOptions $LoggingOptions -LocaleOptions $LocaleOptions -Category 'WAR' -MessageName 'MissingField' -AdditionalMessage "$Field"
        }
    }
    return $Field
}
