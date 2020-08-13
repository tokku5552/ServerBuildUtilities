#Requires -RunAsAdministrator
# get configuration script
Write-Output "Get Configuration Script start"

# initial proccess
$isServer = $false
If((Get-WmiObject Win32_OperatingSystem).Caption.Contains("Server")){
    $isServer = $true 
}

# make and change tmp directory 
$tmpPath = $PSScriptRoot+"\tmp"
if(!(Test-Path $tmpPath)){
    mkdir $tmpPath
}
Set-Location $tmpPath

# common cmdlet proccess
systeminfo > .\systeminfo.txt
Get-ComputerInfo > .\Get_ComputerInfo.txt
Get-WmiObject Win32_OperatingSystem > .\OS_Version.txt
Write-Output "OS Version:" >> .\OS_Version.txt
(Get-WmiObject Win32_OperatingSystem).Caption >> .\OS_Version.txt
Get-Volume > .\Get_Volume.txt
Get-Service | Format-Table -AutoSize | Out-String -Width 4096 > .\Get_Service.txt
#Get-ChildItem -LiteralPath 'HKLM:\' -Recurse > .\Registry_HKLM.txt
#Get-ChildItem -LiteralPath 'HKCU:\' -Recurse > .\Registry_HKCU.txt
Get-WmiObject -Class Win32_OSRecoveryConfiguration > .\MemDump.txt
Get-EventLog Application | Export-CSV -Encoding Default .\Application_evt.csv
wevtutil epl Application .\Application_evt.evtx
Get-EventLog System | Export-CSV -Encoding Default .\System_evt.csv
wevtutil epl System .\System_evt.evtx
Get-ChildItem C:\ -Recurse > .\Get_ChildItem_C_drive.txt

Get-LocalUser > .\Get_LocalUser.txt
Get-LocalGroup > .\Get_LocalGroup.txt

ipconfig /all > .\ipconfig.txt
route print > .\route_print.txt
Get-WMIObject Win32_QuickFixEngineering > .\PatchList.txt
Write-Output "w32tm /query /status /verbose" > .\w32tm_query.txt
w32tm /query /status /verbose >> .\w32tm_query.txt
Write-Output "w32tm /query /peers /verbose" >> .\w32tm_query.txt
w32tm /query /peers /verbose >> .\w32tm_query.txt
Get-NetFirewallProfile > .\Get_NetFirewallProfile.txt


$hostsPath = $tmpPath +"\hosts"
if(!(Test-Path $hostsPath)){
    mkdir $hostsPath
}
Set-Location $hostsPath
Copy-Item C:\Windows\System32\drivers\etc\* .
Set-Location $tmpPath

if($isServer){
    Get-WindowsFeature > .\Get_WindowsFeature.txt
}else{
    Get-WindowsOptionalFeature -Online > .\Get_WindowsOptionalFeature.txt
}

if($isServer){
    gpresult /H .\gpresult.html
}else{
    gpresult /Z > .\gpresult.txt
}
secedit /export /cfg .\secedit.log

