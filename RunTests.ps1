if ($null -eq (Get-Module -ListAvailable pester)) {
    Install-Module -Name Pester -Repository PSGallery -Force
}

$testResultsFile = ".\TestsResults.xml"
$res = Invoke-Pester -OutputFormat NUnitXml -OutputFile $testResultsFile -PassThru
if ($env:APPVEYOR -eq "True") {
    (New-Object 'System.Net.WebClient').UploadFile("https://ci.appveyor.com/api/testresults/nunit/$($env:APPVEYOR_JOB_ID)", (Resolve-Path $testResultsFile))
    if ($res.FailedCount -gt 0) { 
        throw "$($res.FailedCount) tests failed."
    }
}