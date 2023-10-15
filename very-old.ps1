## testing :)
# Params
param(
	[Parameter()]
	[string]
	$hostSelect
)

$allHostsArray = Get-Content $home\.ssh\config | Select-String "Host "
$itemCount = $allHostsArray.count - 3
$listOfDivideValues = 1,9,13,17,18,21,23
$listOfAllowed = @()
$currentDateTime = Get-Date

Write-Host
Write-Host "======== My Servers ======== $currentDateTime ========"

foreach ($elemNr in 0..$itemCount) {
	$listOfAllowed += $elemNr
	$menuItem = $allHostsArray[$elemNr] -replace "Host", $elemNr
	if ($elemNr.tostring().Length -lt 2) {$menuItem = ' ' + $menuItem}
	Write-Host $menuItem
	if ($elemNr -in $listOfDivideValues) {write-Host}
}

Write-Host
if ($hostSelect -eq "") {
	$selection = Read-Host "Please make a selection"
} else {
	$selection = $hostSelect
}

# Write-Host $listOfAllowed
# Write-Host $selection, '<---'

if (($selection -notin $listOfAllowed) -or ($selection -eq '')) {
	write-Host 'Not allowed host, we will quit. Bye.'
	exit 1
}

$targetHost = ($allHostsArray[$selection] -split ' ')[1]
$targetHostNote = $allHostsArray[$selection]
#$targetHost_4 = ($allHostsArray[$selection - 1] -split ' ')[4]

Write-Host "Connecting to:", $targetHostNote
Write-Host

ssh $targetHost
