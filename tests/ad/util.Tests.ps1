Describe "Read-Field function" {

    BeforeAll {
        . $PSCommandPath.Replace('tests', 'src').Replace('.Tests.ps1','.ps1')
    }

    Context "Reading null, when ErrorHandling is 3" {
        BeforeEach {
            $global:ADOptions = @{
                ErrorHandling = 3
            }

            Mock Write-Log-Abstract {} -Verifiable -ParameterFilter { $Throw }
            Mock Write-Log-Abstract {}

            $result = Read-Field -Field $null
        }

        It "Should Write-Log-Abstract with throw" {
            Should -InvokeVerifiable
        }

        It "Should return null" {
            $result | Should -BeNullOrEmpty
        }
    }

    Context "Reading null, when ErrorHandling is 2" {
        BeforeEach {
            $global:ADOptions = @{
                ErrorHandling = 2
            }

            Mock Write-Log-Abstract {} -Verifiable -ParameterFilter { $Throw -eq $false }
            Mock Write-Log-Abstract {}

            $result = Read-Field -Field $null
        }

        It "Should not Write-Log-Abstract with throw" {
            Should -InvokeVerifiable
        }

        It "Should return null" {
            $result | Should -BeNullOrEmpty
        }
    }

    Context "Reading null, when FillDefaults is true" {
        BeforeEach {
            $global:ADOptions = @{
                ErrorHandling = 3
                FillDefaults  = $true
            }

            Mock Write-Log-Abstract -Verifiable -ParameterFilter { $Throw -eq $false }
            Mock Write-Log-Abstract {}

            $result = Read-Field -Field $null -Default "Test"
        }

        It "Should not throw" {
            Should -InvokeVerifiable
        }

        It "Should return the default value" {
            $result | Should -Be "Test"
        }
    }

    Context "When field is not null" {
        BeforeEach {
            $global:ADOptions = @{
                ErrorHandling = 3
            }

            Mock Write-Log-Abstract -Verifiable -ParameterFilter { $Throw }
            Mock Write-Log-Abstract {}

            $result = Read-Field -Field "Test"
        }

        It "Should call Write-Log-Abstract" {
            Should -Not -InvokeVerifiable
        }

        It "Should return the field" {
            $result | Should -Be "Test"
        }
    }
}
