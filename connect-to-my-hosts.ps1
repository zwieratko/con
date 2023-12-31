<#
.SYNOPSIS
Simple OpenSSH connection manager.

.DESCRIPTION
Help to establish SSH connection to target host.
Display all available SSH host from config file if called without parameters.

.PARAMETER sshHostSelect
-s | -ssh
First positional parameter.
Specifies the required host number from OpenSSH client config file.
For example: "2", "-s 2", "-ssh 2", "-sshHost 2", "-sshHostSelect 2"

.PARAMETER version
-v
Display the actuall version of the con program.
Additional parameters are ignored.

.PARAMETER helpMe
-h | -help
Display this help information for the con program.
Additional parameters are ignored.

.EXAMPLE
PS> con

PS> con 3

.NOTES
Author: Radovan Snirc
Version: 0.0.3
Date: 2023-10-24
#>

# Params
param(
    [Parameter()]
    [string]
    $sshHostSelect,

    [Parameter()]
    [switch]
    $version,

    [Parameter()]
    [switch]
    $helpMe
)

# Variables
$DefaultForeground = (Get-Host).UI.RawUI.ForegroundColor
$DefaultBackground = (Get-Host).UI.RawUI.BackgroundColor
$sshConfigFile = "$home\.ssh\config"
if (-Not (Test-Path $sshConfigFile -PathType Leaf)) {
    #throw "OpenSSH client config file does not exist"
    Write-Host "OpenSSH client config file does not exist, we have to quit. Bye."
    exit 1
} else {
    <# Action when all if and elseif conditions are false #>
    $allHostsArray = Get-Content $sshConfigFile | Select-String "Host "
    $allHostsArrayWithDivider = Get-Content $sshConfigFile | Select-String "Host " -Context 1,0
    $itemCount = $allHostsArray.count - 3
}
$dividerString = "##div"
#$listOfDivideValues = 1,9,13,17,18,21,23
$currentDateTime = Get-Date

function getVersion {
    param (
        $OptionalParameters
    )
    Write-Host "con - console OpenSSH connection manager"
    Write-Host "Version: 0.0.3"
    Exit
}

function getHelp {
    param (
        $OptionalParameters
    )
    $usageText = @"

The con - console OpenSSH connection manager.

Helps you make an SSH connection to a target host.

Show all available SSH hosts from the config file if called without parameters.

The expected location for the OpenSSH client configuration file is, of course, "~/.ssh/config".
The default delimiter for listing hosts is set to string: "##div".
Feel free to change this if you like.

Usage:
    con
    con <int>
    con [-s <int>]
    con [-v | -h]

"@
    $optionsText = @"
Options:
    [ -s | -ssh | -sshHost | -sshHostSelect ] <int>
        First positional parameter.
        Specifies the required host number from OpenSSH client config file.
        For example: "2", "-s 2", "-ssh 2", "-sshHost 2", "-sshHostSelect 2"

    [ -v | -version ]
        Display the actuall version of the cal program.
        Additional parameters are ignored.

    [ -h | -help | -helpMe ]
        Display this help information for the cal program.
        Additional parameters are ignored.

"@
    $authorsText = @"
The con program and manual were written by Radovan Snirc <snircradovan@gmail.com>

"@
    Write-Host $usageText
    Write-Host $optionsText
    Write-Host $authorsText
    Exit
}

function getAllHosts {
    param (
        $OptionalParameters
    )
    Write-Host
    Write-Host "======== My Servers ======== $currentDateTime ========"
    foreach ($elemNr in 0..$itemCount) {
        $menuItem = $allHostsArray[$elemNr] -replace "Host", $elemNr
        if ($allHostsArrayWithDivider[$elemNr] -like "  $dividerString*") {
            Write-Host
        }
        if ($elemNr.tostring().Length -lt 2) {$menuItem = ' ' + $menuItem}
        Write-Host $menuItem
        #if ($elemNr -in $listOfDivideValues) {write-Host}
    }

    Write-Host
    $selection = Read-Host "Please make a selection"

    return $selection
}

function testSelection {
    param (
        $selectedHost
    )
    $listOfAllowed = @()
    foreach ($elemNr in 0..$itemCount) {
        $listOfAllowed += $elemNr
    }
    $debugMessage = "listOfAllowed=" + ($listOfAllowed)
    Write-Debug $debugMessage

    if ($selectedHost -eq "") {
        $selection = getAllHosts
    } else {
        $selection = $selectedHost
    }
    $debugMessage = "selection:" + ($selection)
    Write-Debug $debugMessage

    if (($selection -notin $listOfAllowed) -or ($selection -eq '')) {
        write-Host "-> $selection <- Not allowed host, we have to quit. Bye."
        exit 1
    }
    return $selection
}

function getNewConnection {
    param (
        $OptionalParameters
    )
    $targetHost = ($allHostsArray[$selection] -split ' ')[1]
    $targetHostNote = $allHostsArray[$selection]
    #$targetHost_4 = ($allHostsArray[$selection - 1] -split ' ')[4]

    Write-Host "Connecting to:", $targetHostNote, "....."
    Write-Host

    ssh $targetHost
    $Host.UI.RawUI.BackgroundColor = $DefaultBackground
    $Host.UI.RawUI.ForegroundColor = $DefaultForeground
    Write-Host "Bye-bye."
}

# Main
switch ($PSBoundParameters.Keys) {
    'version' {
        getVersion
    }
    'helpMe' {
        getHelp
    }
}

$selection = testSelection $sshHostSelect

getNewConnection
