$script:ProviderName = "VisualStudioCode"

function Get-PackageProviderName { 
    return $script:ProviderName
}

function Initialize-Provider { 
    Write-Debug -Message "initializing $($script:ProviderName)"
}

function Install-Package
{ 
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $fastPackageReference
    )

    Write-Debug "fastref = $fastPackageReference"

    Invoke-VSCode --install-extension $fastPackageReference
}


function Get-InstalledPackage
{ 
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [string]
        $Name,

        [Parameter()]
        [string]
        $RequiredVersion,

        [Parameter()]
        [string]
        $MinimumVersion,

        [Parameter()]
        [string]
        $MaximumVersion
    )

    $minVer = $null
    if ($MinimumVersion -ne "") {
        $minVer = New-Object System.Version ("$MinimumVersion")
    }

    $maxVer = $null
    if ($MaximumVersion -ne "") {
        $maxVer = New-Object System.Version ("$MaximumVersion")
    }

    $requiredVer = $null
    if ($RequiredVersion -ne "") {
        $requiredVer = New-Object System.Version ("$RequiredVersion")
    }

    $packages = Invoke-VSCode --list-extensions --show-versions
    foreach ($codePackage in $packages) {
        $split = $codePackage.Split("@")
        $packageName = $split[0]
        $pv = $split[1]
        Write-Debug "pv = $pv"
        $packageVersion = New-Object System.Version ("$pv")
        Write-Debug "packageversion = $packageVersion"

        if (checkVersion $packageVersion $minVer $maxVer $requiredVer) {
            Write-Debug "Adding $packageName"
            $swidObject = @{
                FastPackageReference = $packageName;
                Name = $packageName;
                Version = $packageVersion; 
                versionScheme  = "MultiPartNumeric";
                summary = "Summary of your package provider";
                Source = "source";
            }
            $swidTag = New-SoftwareIdentity @swidObject
            Write-Output -InputObject $swidTag
        }
    }
}

function checkVersion(
    [System.Version]$packageVersion, 
    [System.Version]$minVer,
    [System.Version]$maxVer,
    [System.Version]$requiredVer) {

    if ($requiredVer -ne $null) {
        return ($packageVersion.Equals($requiredVer))
    }

    if ($minVer -eq $null -and $maxVer -eq $null) {
        return $true        
    }

    if ($minVer -ne $null -and $maxVer -ne $null ){
        return ($packageVersion.CompareTo($minVer) -ge 0 -and $packageVersion.CompareTo($maxVer) -le 0)
    }

    if ($minVer -ne $null) {
        return ($minVer.CompareTo($packageVersion) -le 0)
    }

    if ($maxVer -ne $null) {
        return ($maxVer.CompareTo($packageVersion) -ge 0)
    }

    return $false
}

function Invoke-VSCode {
    code $args
}