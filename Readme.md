# ModuleBuildToolsTemp

Builder tools for the ModuleBuild project

## Description

Builder tools for the ModuleBuild project

## Introduction

This module is used by ModuleBuild during its build process.

## Installation

Powershell Gallery (PS 5.0, Preferred method)
`install-module ModuleBuildToolsTemp`

Manual Installation
`iex (New-Object Net.WebClient).DownloadString("https://www.github.com/justin-p/ModuleBuildToolsTemp/raw/master/Install.ps1")`

Or clone this repository to your local machine, extract, go to the .\releases\ModuleBuildToolsTemp directory
and import the module to your session to test, but not install this module.

## Contribute

Please feel free to contribute by opening new issues or providing pull requests.
For the best development experience, open this project as a folder in Visual
Studio Code and ensure that the PowerShell extension is installed.

* [Visual Studio Code](https://code.visualstudio.com/)
* [PowerShell Extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode.PowerShell)

This module is tested with the PowerShell testing framework Pester. To run all tests, just start the included build scrip with the test param `.\Build.ps1 -test`.

## Other Information

**Author:** Justin Perdok

**Website:** https://www.github.com/justin-p/ModuleBuildToolsTemp
