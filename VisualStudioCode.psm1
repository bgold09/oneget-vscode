$script:ProviderName = "VisualStudioCode"

function Get-PackageProviderName { 
    return $script:ProviderName
}

function Initialize-Provider { 
    Write-Debug -Message "Initializing $($script:ProviderName)"
    $script:RegisteredPackageSources = @()
}

function Resolve-PackageSource { 
    $SourceName = $request.PackageSources
	if (-not $SourceName) {
		return $script:RegisteredPackageSources
    }

    $SourceName | ForEach-Object {
		if ($request.IsCanceled) {
            return
        }

		$PackageSource = $script:RegisteredPackageSources | Where-Object Name -like $_
		if (-not $PackageSource) {
			$msg = "Package source matching the name $_ not registered"
			Write-Error -Message $msg -ErrorId PackageSourceNotFound -Category InvalidOperation -TargetObject $_
		} else {
            $PackageSource
        }
    }
} 

function Add-PackageSource {
    [CmdletBinding()]
    param
    (
        [string]$Name,
        [string]$Location,
        [bool]$Trusted
    ) 

    if ($Location -ne "https://marketplace.visualstudio.com/_apis/public/gallery") {
        Write-Error "Locations other than the official gallery are not supported."
        throw
    }

    $PSBoundParameters.Registered = $true
    $PackageSource = New-PackageSource @PSBoundParameters
	$script:RegisteredPackageSources += $PackageSource
    Write-Output $PackageSource
}

function Find-Package { 
    param(
      [string] $name,      
      [string] $requiredVersion,  
      [string] $minimumVersion,     
      [string] $maximumVersion
    )

    Write-Debug $request
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

    Write-Debug "pkg sources = $($request.PackageSources)"

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
        $packageVersion = New-Object System.Version ("$pv")

        if (checkVersion $packageVersion $minVer $maxVer $requiredVer) {
            $swidTag = New-SoftwareID $packageName $packageVersion
            Write-Output -InputObject $swidTag
        }
    }
}

function New-SoftwareID(
    [string]$pkgName,
    [System.Version]$pkgVersion
) {
    $swidObject = @{
        FastPackageReference = $pkgName;
        Name = $pkgName;
        Version = $pkgVersion; 
        versionScheme  = "MultiPartNumeric";
        Source = "Visual Studio Marketplace";
    }
    return New-SoftwareIdentity @swidObject
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
    Invoke-Expression -Command "code $args"
}