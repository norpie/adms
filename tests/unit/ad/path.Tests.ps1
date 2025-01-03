

Describe "Paths" {
    BeforeAll {
        . $PSCommandPath.Replace('tests\unit', 'src').Replace('.Tests.ps1','.ps1')
    }
    It "Parsing a path" {
        Get-Parsed-Path -Path "ROOT/Example/Path/To/OU" -TopLevel "DC=Example,DC=com" | Should -Be "OU=OU,OU=To,OU=Path,OU=Example,DC=Example,DC=com"
    }
    It "Parsing an empty path" {
        Get-Parsed-Path -Path "" -TopLevel "DC=Example,DC=com" | Should -Be "DC=Example,DC=com"
    }
    It "Unparsing a path" {
        Get-Unparsed-Path -Path "OU=OU,OU=To,OU=Path,OU=Example,DC=Example,DC=com" -TopLevel "DC=Example,DC=com" | Should -Be "ROOT/Example/Path/To/OU"
    }
    It "Unparsing a top level path" {
        Get-Unparsed-Path -Path "DC=Example,DC=com" -TopLevel "DC=Example,DC=com" | Should -Be "ROOT"
    }
}
