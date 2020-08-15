#Requires -RunAsAdministrator

# Get OS core configuration
function Get-OsCoreConfiguration(){
    Write-Output "Getting OS core configuration"
    systeminfo > .\systeminfo.txt
    Get-ComputerInfo > .\Get_ComputerInfo.txt
    Get-WmiObject Win32_OperatingSystem > .\OS_Version.txt
    Write-Output "OS Version:" >> .\OS_Version.txt
    (Get-WmiObject Win32_OperatingSystem).Caption >> .\OS_Version.txt
    Get-Service | Format-Table -AutoSize | Out-String -Width 4096 > .\Get_Service.txt
    Get-WMIObject Win32_QuickFixEngineering > .\PatchList.txt
    Write-Output "Done OS core configuration"
}

# Get Disk & Volume configuration
function Get-DiskAndVolumeConfiguration(){    
    Write-Output "Getting Disk & Volume configuration"
    Get-Volume > .\Get_Volume.txt
    Get-ChildItem C:\ -Recurse > .\Get_ChildItem_C_drive.txt
    Get-WmiObject -Class Win32_OSRecoveryConfiguration > .\MemDump.txt
    Write-Output "Done Disk & Volume configuration"
}

# Get EventLog
function Get-EventLog_func(){

    Write-Output "Getting EventLog"
    Get-EventLog Application | Export-CSV -Encoding Default .\Application_evt.csv
    wevtutil epl Application .\Application_evt.evtx
    Get-EventLog System | Export-CSV -Encoding Default .\System_evt.csv
    wevtutil epl System .\System_evt.evtx
    Write-Output "Done EventLog"
}

# Get user & group configuration
function Get-UserAndGroupConfiguration(){
    Write-Output "Getting user & group configuration"
    Get-LocalUser > .\Get_LocalUser.txt
    Get-LocalGroup > .\Get_LocalGroup.txt
    Write-Output "Done user & group configuration"
}


# Get localpolicy
function Get-localpolicyfunc(){
    Write-Output "Getting localpolicy"
    if($isServer){
        gpresult /H .\gpresult.html
    }else{
        gpresult /Z > .\gpresult.txt
    }
    secedit /export /cfg .\secedit.log
    Write-Output "Done localpolicy"
}


# Get network configuration
function Get-NetworkConfiguration(){
    Write-Output "Getting network configuration"
    ipconfig /all > .\ipconfig.txt
    route print > .\route_print.txt
    Get-ChildItem -LiteralPath 'HKLM:\SYSTEM\CurrentControlSet\Services\W32Time' -Recurse > .\Registry_W32Time.txt
    Write-Output "w32tm /query /status /verbose" > .\w32tm_query.txt
    w32tm /query /status /verbose >> .\w32tm_query.txt
    Write-Output "w32tm /query /peers /verbose" >> .\w32tm_query.txt
    w32tm /query /peers /verbose >> .\w32tm_query.txt
    Get-NetFirewallProfile > .\Get_NetFirewallProfile.txt

    # get hosts files
    $hostsPath = $tmpPath +"\hosts"
    if(!(Test-Path $hostsPath)){
        mkdir $hostsPath
    }
    Set-Location $hostsPath
    Copy-Item C:\Windows\System32\drivers\etc\* .
    Set-Location $tmpPath
    Write-Output "Done network configuration"
}

# Get network configuration
function Get-WindowsFeaturefunc(){
    Write-Output "Getting WindowsFeature"
    if($isServer){
        Get-WindowsFeature > .\Get_WindowsFeature.txt
    }else{
        Get-WindowsOptionalFeature -Online > .\Get_WindowsOptionalFeature.txt
    }
    Write-Output "Done WindowsFeature"
}

###############################################################
# 
# Windows OS common configuration main proccess
# 
###############################################################

Write-Output "###############################################################"
Write-Output ""
Write-Output "Start Get-SysConfig"
Write-Output ""
Write-Output "###############################################################"
# initial proccess
$isServer = $false
If((Get-WmiObject Win32_OperatingSystem).Caption.Contains("Server")){
    $isServer = $true 
}

$tmpPath = $PSScriptRoot+"\tmp"
if(!(Test-Path $tmpPath)){
    mkdir $tmpPath
}
Set-Location $tmpPath

Write-Output "###############################################################"
Write-Output ""
Write-Output "Start to get Windows OS common configuration"
Write-Output ""
Write-Output "###############################################################"

Get-OsCoreConfiguration
Get-DiskAndVolumeConfiguration
Get-EventLog_func
Get-UserAndGroupConfiguration
Get-localpolicyfunc
Get-NetworkConfiguration
Get-WindowsFeaturefunc

Write-Output "###############################################################"
Write-Output ""
Write-Output "End to get Windows OS common configuration"
Write-Output ""
Write-Output "###############################################################"
