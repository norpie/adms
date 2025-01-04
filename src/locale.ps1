$LocalesDir = "$PSScriptRoot\..\locales"

# Gets the list of supported locales from the locales directory
Function Get-Supported-Locales
{
    $locales = Get-ChildItem -Path $LocalesDir -Filter '*.csv' | ForEach-Object { $_.BaseName }
    return $locales
}

# Gets the user's locale from the system, e.g. en_US
Function Get-User-Locale
{
    $UserLocale = Get-WinSystemLocale
    $UserLocale -replace '-', '_'
    return $UserLocale
}

# Gets the best locale to use based on the user's locale and the supported locales
Function Get-Best-Locale
{
    param (
        [string]
        $UserLocale = (Get-User-Locale),
        [array]
        $Locales = (Get-Supported-Locales)
    )
    if ($Locales -contains $UserLocale)
    {
        return $UserLocale
    }
    $UserLanguage = $UserLocale.Split('_')[0]
    $LanguageMatch = $Locales | Where-Object { $_ -like "$UserLanguage*" }
    if ($LanguageMatch)
    {
        return $LanguageMatch
    }
    return 'en_US'
}

# Get the locale file for the current user's language
Function Read-Locale
{
    param(
        [string]
        $Locale
    )
    $LocaleFile = "$LocalesDir\$Locale.csv"
    $LocaleCsv = Import-Csv -Path $LocaleFile
    $HashTable=@{}
    foreach($r in $LocaleCsv)
    {
        $HashTable[$r.Name]=$r.Value
    }
    return $HashTable
}

# Get the message for the current user's language
Function Get-Message
{
    param(
        [string]
        $MessageName
    )
    $Message = $global:LocaleOptions.LocaleData[$MessageName]
    if (-not $Message)
    {
        return "Localization name not found for variable: $MessageName"
    }
    return $Message
}
