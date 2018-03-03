Import-Module .\VisualStudioCode.psm1 -Force
$mn = "VisualStudioCode"

Describe "Find-Package" {
    It "finds package" {
        Mock -ModuleName $mn -CommandName Invoke-RestMethod `
            -ParameterFilter {
                $Uri -eq "https://marketplace.visualstudio.com/_apis/public/gallery/extensionquery" -and $Method -eq "Post"
            } `
            -MockWith { "
{
  `"results`": [
    {
      `"extensions`": [
        {
          `"extensionName`": `"ext1`",
          `"versions`": [ { `"version`": `"1.3.0`" } ]
        },
        {
            `"extensionName`": `"ext2`",
            `"versions`": [ { `"version`": `"6.5.12`" } ]
        }
      ]
    }
  ]
}" | ConvertFrom-Json        } -Verifiable

        Mock -ModuleName $mn -CommandName Write-Output -MockWith {} 
        Mock -ModuleName $mn -CommandName "New-SoftwareID" -MockWith {
            @{
                FastPackageReference = $fastPackageReference;
                Name = $fastPackageReference;
                Version = New-Object System.Version $pkgVersion; 
                versionScheme  = "MultiPartNumeric";
            }
        }

        Find-Package "ext"
        Assert-VerifiableMock
        Assert-MockCalled -ModuleName $mn Write-Output -Times 2
    }
}
