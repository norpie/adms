

Describe "Get-Parsed-Path" {
    BeforeAll {
        . $PSCommandPath.Replace('tests', 'src').Replace('.Tests.ps1','.ps1')
    }
    It "Should return a parsed path" {
        Get-Parsed-Path -Path "Example/Path/To/OU" -TopLevel "DC=Example,DC=com" | Should -Be "OU=OU,OU=To,OU=Path,OU=Example,DC=Example,DC=com"
    }
}
