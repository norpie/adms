Describe "Paths" {
    BeforeAll {
        . $PSCommandPath.Replace('tests', 'src').Replace('.Tests.ps1','.ps1')
    }
    It "Get a locale that exists" {
        Get-Best-Locale -Locales @('en_US', 'nl_NL') -UserLocale 'en_US' | Should -Be 'en_US'
    }
    It "Get a locale for language that is not same country" {
        Get-Best-Locale -Locales @('en_US', 'nl_NL') -UserLocale 'nl_BE' | Should -Be 'nl_NL'
    }
    It "Get a locale for language that does not exist, defaults to en_US" {
        Get-Best-Locale -Locales @('en_US', 'nl_NL') -UserLocale 'fr_FR' | Should -Be 'en_US'
    }
}
