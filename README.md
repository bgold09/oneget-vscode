# PowerShell PackageManagement provider for Visual Studio Code

A [PowerShell PackageManagement](https://github.com/OneGet/oneget/) provider for [Visual Studio Code](https://code.visualstudio.com/).

## Build Status

|Branch        |Windows|Linux / OSX|
|:------------:|:-----:|:---------:|
|**develop**   | [![Build status](https://ci.appveyor.com/api/projects/status/gl77c5noigvo2n7h/branch/develop?svg=true)](https://ci.appveyor.com/project/bgold09/oneget-vscode/branch/develop) | [![Build Status](https://travis-ci.org/bgold09/oneget-vscode.svg?branch=develop)](https://travis-ci.org/bgold09/oneget-vscode) |
|**master**    | [![Build status](https://ci.appveyor.com/api/projects/status/gl77c5noigvo2n7h/branch/master?svg=true)](https://ci.appveyor.com/project/bgold09/oneget-vscode/branch/master)   | [![Build Status](https://travis-ci.org/bgold09/oneget-vscode.svg?branch=master)](https://travis-ci.org/bgold09/oneget-vscode)  |

## Installation

```powershell
Import-PackageProvider .\VisualStudioCode.psm1

Register-PackageSource -ProviderName VisualStudioCode `
    -Location "https://marketplace.visualstudio.com/_apis/public/gallery" `
    -Name "VisualStudioMarketplace" -Trusted
```

## Thanks and Acknowledgements

  * [akamac](https://github.com/akamac) for the [GitLab provider](https://github.com/akamac/GitLabProvider)
  * [Doug Finke](https://github.com/dfinke) for
    [PSMatcher](https://github.com/dfinke/PSMatcher), from which I borrowed
    Travis and AppVeyor configurations