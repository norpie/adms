$LocalesDir = "$PSScriptRoot\..\locales"

Function Get-Supported-Locales
{
    $locales = Get-ChildItem -Path $LocalesDir -Filter '*.csv' | ForEach-Object { $_.BaseName }
    return $locales
}

Function Get-User-Locale
{
    # $UserLocale = Get-WinSystemLocale
    return 'nl_BE'
}

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
