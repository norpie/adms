Describe "OU Invoking" {

    BeforeAll {
        . $PSCommandPath.Replace('tests', 'src').Replace('.Tests.ps1','.ps1')
    }

    Context "When action is 'Add'" {
        BeforeEach {
            $Action = @{
                Action = "Add"
                Path = "ROOT"
                Name = "Company"
                Protected = $true
                Description = "Top-level company organisational unit"
            }
            Mock New-OU {} -Verifiable -ParameterFilter { $OU -eq $Action }

            Invoke-OU-Action -Action $Action
        }

        It "calls New-OU" {
            Should -InvokeVerifiable
        }
    }

    Context "When action is 'Modify'" {
        BeforeEach {
            $Action = @{
                Action = "Modify"
                Path = "ROOT"
                Name = "Company"
                Protected = $true
                Description = "Top-level company organisational unit"
            }
            Mock Set-OU {} -Verifiable -ParameterFilter { $OU -eq $Action }
            Invoke-OU-Action -Action $Action
        }

        It "calls Set-OU" {
            Should -InvokeVerifiable
        }
    }

    Context "When action is 'Remove'" {
        BeforeEach {
            $Action = @{
                Action = "Remove"
                Path = "ROOT"
                Name = "Company"
            }
            Mock Remove-OU {} -Verifiable -ParameterFilter { $OU -eq $Action }
            Invoke-OU-Action -Action $Action
        }

        It "calls Remove-OU" {
            Should -InvokeVerifiable
        }
    }

    Context "When action is not applicable" {
        BeforeAll {
            $Action = @{
                Action = "Invalid"
            }
            Mock Write-Log-Abstract {} -Verifiable -ParameterFilter { $Throw }
            Invoke-OU-Action -Action $Action
        }

        It "Writes log with throw" {
            Should -InvokeVerifiable
        }
    }
}
