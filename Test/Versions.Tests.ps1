Import-Module .\VisualStudioCode.psm1

function createVersion([string]$versionString) {
    if ($versionString -eq "") {
        return $null
    } else {
        return New-Object System.Version $versionString
    }
}

Context "Versions"  {
    It "check version returns <Expected>; pkgver=<PackageVersion>; minver=<MinVersion>; maxver=<MaxVersion>; reqver=<RequiredVersion>" -TestCases @( 
        # Both min and max version specified
        @{ PackageVersion = "3.0.0"; MinVersion = "1.0.0"; MaxVersion = "8.0.0"; RequiredVersion = ""; Expected = $true }
        @{ PackageVersion = "1.0.0"; MinVersion = "1.0.0"; MaxVersion = "8.0.0"; RequiredVersion = ""; Expected = $true }
        @{ PackageVersion = "8.0.0"; MinVersion = "1.0.0"; MaxVersion = "8.0.0"; RequiredVersion = ""; Expected = $true }
        @{ PackageVersion = "1.0.0"; MinVersion = "2.0.0"; MaxVersion = "8.0.0"; RequiredVersion = ""; Expected = $false }
        @{ PackageVersion = "9.5.0"; MinVersion = "2.0.0"; MaxVersion = "8.0.0"; RequiredVersion = ""; Expected = $false }

        # Only min version specified
        @{ PackageVersion = "3.0.0"; MinVersion = "2.0.0"; MaxVersion = ""; RequiredVersion = ""; Expected = $true }
        @{ PackageVersion = "3.0.0"; MinVersion = "3.0.0"; MaxVersion = ""; RequiredVersion = ""; Expected = $true }
        @{ PackageVersion = "3.0.0"; MinVersion = "5.0.0"; MaxVersion = ""; RequiredVersion = ""; Expected = $false }

        # Only max version specified
        @{ PackageVersion = "4.0.0"; MinVersion = ""; MaxVersion = "7.0.0"; RequiredVersion = ""; Expected = $true }
        @{ PackageVersion = "7.0.0"; MinVersion = ""; MaxVersion = "7.0.0"; RequiredVersion = ""; Expected = $true }
        @{ PackageVersion = "9.0.0"; MinVersion = ""; MaxVersion = "7.0.0"; RequiredVersion = ""; Expected = $false }

        # Required version specified
        @{ PackageVersion = "9.5.0"; MinVersion = ""; MaxVersion = ""; RequiredVersion = "9.5.0"; Expected = $true }
        @{ PackageVersion = "3.5.0"; MinVersion = ""; MaxVersion = ""; RequiredVersion = "9.5.0"; Expected = $false }

        # No version boundaries specified
        @{ PackageVersion = "3.5.0"; MinVersion = ""; MaxVersion = ""; RequiredVersion = ""; Expected = $true }
    ) {
        param($PackageVersion, $MinVersion, $MaxVersion, $RequiredVersion, $Expected)

        checkVersion (createVersion $PackageVersion) `
                     (createVersion $MinVersion) `
                     (createVersion $MaxVersion) `
                     (createVersion $RequiredVersion) | Should -be $Expected
    }
}
