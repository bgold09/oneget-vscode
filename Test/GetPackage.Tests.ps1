Import-Module .\VisualStudioCode.psm1
$mn = "VisualStudioCode"

Describe "Get-Package" {
    It "does not output when no extensions are installed" {
        Mock -ModuleName $mn -Verifiable -CommandName Invoke-Expression {} -ParameterFilter { $Command -eq "code --list-extensions --show-versions" }
        Mock -ModuleName $mn -CommandName Write-Output {} 
        Get-InstalledPackage 
        Assert-VerifiableMock
        Assert-MockCalled -ModuleName $mn Write-Output -Times 0
    }

    It "outputs for single installed extension" {
        Mock -ModuleName $mn -CommandName Invoke-Expression { @( "p1@4.3.8" ) } -ParameterFilter { $Command -eq "code --list-extensions --show-versions" }
        Mock -ModuleName $mn -CommandName Write-Output { } 
        Mock -ModuleName $mn -CommandName "New-SoftwareID" -ParameterFilter { $pkgName -eq "p1" } -MockWith {
            @{
                FastPackageReference = "p1";
                Name = "p1";
                Version = New-Object System.Version "4.3.8"; 
                versionScheme  = "MultiPartNumeric";
            }
        }

        Get-InstalledPackage

        Assert-MockCalled -ModuleName $mn Write-Output -Times 1
    }
}
