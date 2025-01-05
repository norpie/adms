Describe "Paths" {
    BeforeAll {
        . $PSCommandPath.Replace('tests', 'src').Replace('.Tests.ps1','.ps1')
    }
    It "Parsing a path" {
        Get-Parsed-Path -Path "ROOT/Example/Path/To/OU" -TopLevel "DC=Example,DC=com" | Should -Be "OU=OU,OU=To,OU=Path,OU=Example,DC=Example,DC=com"
    }
    It "Parsing an empty path" {
        Get-Parsed-Path -Path "" -TopLevel "DC=Example,DC=com" | Should -Be "DC=Example,DC=com"
    }
    It "Parsing a path (last cn)" {
        Get-Parsed-Path -Path "ROOT/Example/Path/To/OU" -TopLevel "DC=Example,DC=com" -LastCN | Should -Be "CN=OU,OU=To,OU=Path,OU=Example,DC=Example,DC=com"
    }
    It "Unparsing a path" {
        Get-AD-Compatible-Path -Path "OU=OU,OU=To,OU=Path,OU=Example,DC=Example,DC=com" -TopLevel "DC=Example,DC=com" | Should -Be "ROOT/Example/Path/To/OU"
    }
    It "Unparsing a top level path" {
        Get-AD-Compatible-Path -Path "DC=Example,DC=com" -TopLevel "DC=Example,DC=com" | Should -Be "ROOT"
    }
}
