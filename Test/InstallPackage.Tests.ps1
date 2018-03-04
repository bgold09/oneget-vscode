Import-Module .\VisualStudioCode.psm1
$mn = "VisualStudioCode"

Describe "Install-Package" {
    It "installs package" {
        $expectedPkgName = "hello"
        $expectedVersion = "6.4.10"
        Mock -ModuleName $mn -Verifiable -CommandName Invoke-VSCode { @( "", "", "Extension 'hello' v6.4.10 was successfully installed!" ) }
        Mock -ModuleName $mn -CommandName "New-SoftwareID" -MockWith {
            @{
                FastPackageReference = $fastPackageReference;
                Name = $fastPackageReference;
                Version = New-Object System.Version $pkgVersion; 
                versionScheme  = "MultiPartNumeric";
            }
        }

        $result = Install-Package -fastPackageReference $expectedPkgName

        $result.FastPackageReference | Should -be $expectedPkgName
        $result.Name | Should -be $expectedPkgName
        $result.Version.ToString() | Should -be $expectedVersion
        Assert-VerifiableMock
    }
}