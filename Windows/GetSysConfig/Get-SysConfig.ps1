#Requires -RunAsAdministrator
###############################################################
# 
# Get-SysConfig.ps1
# 
###############################################################

# variable declaration
$tmpPath = $PSScriptRoot + "\tmp"
$isServer = $false

# function declaration
$functions = {
    # Get OS core configuration
    function funcOsCoreConfiguration() {
        systeminfo > .\systeminfo.txt
        Get-ComputerInfo > .\Get_ComputerInfo.txt
        Get-WmiObject Win32_OperatingSystem > .\OS_Version.txt
        Write-Output "OS Version:" >> .\OS_Version.txt
        (Get-WmiObject Win32_OperatingSystem).Caption >> .\OS_Version.txt
        Get-Service | Format-Table -AutoSize | Out-String -Width 4096 > .\Get_Service.txt
        Get-WMIObject Win32_QuickFixEngineering > .\PatchList.txt
        Get-WmiObject -Class Win32_OSRecoveryConfiguration > .\MemDump.txt
        Write-Output "Getting OS core configuration Completed"
    }

    # Get Disk & Volume configuration
    function funcDiskAndVolumeConfiguration() {    
        Get-Volume > .\Get_Volume.txt
        $ErrorActionPreference = "silentlycontinue"
        Get-ChildItem C:\ -Recurse > .\Get_ChildItem_C_drive.txt
        $ErrorActionPreference = "continue"
        Write-Output "Getting Disk & Volume configuration Completed"
    }

    # Get Volume configuration
    function funcVolumeConfiguration() {    
        Get-Volume > .\Get_Volume.txt
        Write-Output "Getting Volume configuration Completed"
    }

    # Get Drive file list
    function funcDriveConfiguration() {
        Param(
            [parameter(Mandatory = $true)][String]$drive
        )    
        $path = $drive + ":\"
        $outPath = ".\Get_ChildItem_" + $drive + "_drive.txt"
        $ErrorActionPreference = "silentlycontinue"
        Get-ChildItem $path -Recurse > $outPath
        $ErrorActionPreference = "continue"
        $outMsg = "Getting " + $drive + "configuration completed"
        Write-Output $outMsg
    }
    # Get EventLog
    function funcEventLog() {
        Get-EventLog Application | Export-CSV -Encoding Default .\Application_evt.csv
        wevtutil epl Application .\Application_evt.evtx
        Get-EventLog System | Export-CSV -Encoding Default .\System_evt.csv
        wevtutil epl System .\System_evt.evtx
        Write-Output "Getting EventLog Completed"
    }

    # Get user & group configuration
    function funcUserAndGroupConfiguration() {
        Get-LocalUser > .\Get_LocalUser.txt
        Get-LocalGroup > .\Get_LocalGroup.txt
        Write-Output "Getting user & group configuration Completed"
    }


    # Get localpolicy
    function funcLocalpolicy() {
        Param(
            [parameter(Mandatory = $true)][Boolean]$isServer
        )
        if ($isServer) {
            gpresult /H .\gpresult.html | Out-Null
        }
        else {
            gpresult /Z > .\gpresult.txt | Out-Null
        }
        secedit /export /cfg .\secedit.log | Out-Null
        Write-Output "Getting Localpolicy Completed"
    }

    # Get network configuration
    function funcNetworkConfiguration() {
        Param(
            [parameter(mandatory = $true)][String]$tmpPath
        )
        ipconfig /all > .\ipconfig.txt
        route print > .\route_print.txt
        Get-ChildItem -LiteralPath 'HKLM:\SYSTEM\CurrentControlSet\Services\W32Time' -Recurse > .\Registry_W32Time.txt
        Write-Output "w32tm /query /status /verbose" > .\w32tm_query.txt
        w32tm /query /status /verbose >> .\w32tm_query.txt
        Write-Output "w32tm /query /peers /verbose" >> .\w32tm_query.txt
        w32tm /query /peers /verbose >> .\w32tm_query.txt
        Get-NetFirewallProfile > .\Get_NetFirewallProfile.txt

        # get hosts files
        $hostsPath = $tmpPath + "\hosts"
        if (!(Test-Path $hostsPath)) {
            mkdir $hostsPath | Out-Null
        }
        Set-Location $hostsPath | Out-Null
        Copy-Item C:\Windows\System32\drivers\etc\* .
        Write-Output "Getting network configuration Completed"
    }

    # Get network configuration
    function funcWindowsFeature() {
        Param(
            [parameter(Mandatory = $true)][Boolean]$isServer
        )
        if ($isServer) {
            Get-WindowsFeature > .\Get_WindowsFeature.txt
        }
        else {
            Get-WindowsOptionalFeature -Online > .\Get_WindowsOptionalFeature.txt
        }
        Write-Output "Getting WindowsFeature Competed"
    }

    function funcFolderRename() {
        Param(
            [parameter(Mandatory = $true)][String]$targetPath,
            [parameter(Mandatory = $true)][String]$targetDirName,
            [parameter(Mandatory = $true)][String]$afterDirName
        )
        if (Test-Path $targetPath) {
            Set-Location $targetPath
            Set-Location ..
            if ((Test-Path $targetDirName) -and !(Test-Path $afterDirName)) {
                Rename-Item $targetDirName $afterDirName
            }
            else {
                Write-Output "$targetDirName is notexist or $afterDirName is already exist"
            }
        }
        else {
            Write-Output "$targetPath is notexist"
        }

    }

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
If ((Get-WmiObject Win32_OperatingSystem).Caption.Contains("Server")) {
    $isServer = $true 
}
Write-Output "isServer: $isServer"

if (!(Test-Path $tmpPath)) {
    mkdir $tmpPath | Out-Null
    Write-Output "makedirÅF$tmpPath"
}
Set-Location $tmpPath | Out-Null

Write-Output "###############################################################"
Write-Output ""
Write-Output "Start to get Windows OS common configuration"
Write-Output ""
Write-Output "###############################################################"

# get each drive infomation
(Get-Volume | Where-Object { $_.DriveLetter -match "^[A-Z]" } ).DriveLetter | ForEach-Object {
    $outMsg = "Start job " + $_ + " drive List"
    Write-Output $outMsg
    Start-Job -InitializationScript $functions -ScriptBlock {
        Param(
            $drive
        )
        Set-Location $using:tmpPath
        funcDriveConfiguration $drive
    } -ArgumentList $_ | Out-Null    
}

Write-Output "Start job Volume Configuration"
Start-Job -InitializationScript $functions -ScriptBlock {
    Set-Location $using:tmpPath
    funcVolumeConfiguration
} | Out-Null

Write-Output "Start job OsCoreConfiguration"
Start-Job -InitializationScript $functions -ScriptBlock {
    Set-Location $using:tmpPath
    funcOsCoreConfiguration 
} | Out-Null  

Write-Output "Start job EventLog"
Start-Job -InitializationScript $functions -ScriptBlock {
    Set-Location $using:tmpPath
    funcEventLog
} | Out-Null

Write-Output "Start job UserAndGroupConfiguration"
Start-Job -InitializationScript $functions -ScriptBlock {
    Set-Location $using:tmpPath
    funcUserAndGroupConfiguration
} | Out-Null

Write-Output "Start job Localpolicy"
Start-Job -InitializationScript $functions -ScriptBlock {
    Set-Location $using:tmpPath
    funcLocalpolicy $using:isServer
} | Out-Null

Write-Output "Start job NetworkConfiguration"
Start-Job -InitializationScript $functions -ScriptBlock {
    Set-Location $using:tmpPath
    funcNetworkConfiguration $using:tmpPath
} | Out-Null

Write-Output "Start job WindowsFeature"
Start-Job -InitializationScript $functions -ScriptBlock {
    Set-Location $using:tmpPath
    funcWindowsFeature $using:isServer
} | Out-Null

# Job Monitoring
while ((Get-job -State Running).Count -gt 0) {
    Get-Job -State Completed | Receive-Job
    Start-Sleep 1
}

Get-Job | Wait-Job | Receive-Job

Write-Output "###############################################################"
Write-Output ""
Write-Output "End to get Windows OS common configuration"
Write-Output ""
Write-Output "###############################################################"

# zip archive prossecc
$afterDirName = (hostname) + "_" + (Get-Date -Format "yyyyMMdd_HHmmss")

Write-Output "Start job FolderRename"
$jobRename = Start-Job -InitializationScript $functions -ScriptBlock {
    funcFolderRename $using:tmpPath "tmp" $using:afterDirName
} 

Wait-Job $jobRename | Receive-Job
Write-Output "End job FolderRename"
Write-Output "Start zip archive compress"
$basePath = $PSScriptRoot + "\" + $afterDirName
$destinationPath = $PSScriptRoot + "/" + $afterDirName + ".zip"
Compress-Archive -Path $basePath -DestinationPath $destinationPath
Remove-Item $basePath -Recurse
Write-Output "End zip archive compress"
Write-Output ""
Write-Output "zip file:" + $destinationPath
Write-Output ""
Write-Output "###############################################################"
Write-Output ""
Write-Output "End to get Windows OS common configuration"
Write-Output ""
Write-Output "###############################################################"
