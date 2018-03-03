Import-Module .\VisualStudioCode.psm1

$mn = "VisualStudioCode"

Describe "Get-Package" {
    It "empty" {
        Mock -ModuleName $mn -Verifiable -CommandName Invoke-Expression { } -ParameterFilter { $Command -eq "code --list-extensions --show-versions" }
        Mock -ModuleName $mn -CommandName Write-Output { } 
        Get-InstalledPackage 
        Assert-VerifiableMock
        Assert-MockCalled -ModuleName $mn Write-Output -Times 0
    }
}
