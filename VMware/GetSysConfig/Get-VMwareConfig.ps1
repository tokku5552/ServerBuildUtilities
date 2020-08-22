#Requires -RunAsAdministrator
###############################################################
# 
# Get-VMwareConfig.ps1
# 
###############################################################

# variable declaration
$tmpPath = $PSScriptRoot + "\tmp"
$isServer = $false
# TODO config
$USER = ""
$PASS = ""

# function declaration
$functions = {
    # Create Session
    function createSession() {
        Param(
            [Parameter(Mandatory = $true)][String]$vCenter,
            [Parameter(Mandatory = $true)][String]$USER,
            [Parameter(Mandatory = $true)][String]$PASS
        )
        $secpasswd = ConvertTo-SecureString $PASS -AsPlainText -Force
        $cred = New-Onject System.Management.Automation.PSCredential($USER, $secpasswd)
        $uri = "https://" + $vCenter + "/rest/com/vmware/cis/session"
        $headers = @{ "Accept" = "application/json" }
        $res = Invoke-WebRequest -Method Post -Headers $headers -Uri $uri -Credential $cred
        return ($res.Content | ConvertFrom-Json).value
    }

    # Get OS core configuration
    function funGetVM() {
        Param(
            [Parameter(Mandatory = $true)][String]$vCenter,
            [Parameter(Mandatory = $true)][String]$token
        )
        $headers = @{ "Accept" = "application/json" ; "vmware-api-session-id" = $token }
        $Uri = "https://" + $vCenter + "/rest/vcenter/vm"         
        $res = Invoke-WebRequest -Headers $headers -Uri $Uri
        return ($res.Content | ConvertFrom-Json).value
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
$jobSession = Start-Job -InitializationScript $functions -ScriptBlock {
    createSession $using:vCenter $using:USER $using:PASS
} 
$token = Wait-Job $jobSession | Receive-Job

if (!(Test-Path $tmpPath)) {
    mkdir $tmpPath | Out-Null
    Write-Output "makedir: $tmpPath"
}
Set-Location $tmpPath | Out-Null

Write-Output "###############################################################"
Write-Output ""
Write-Output "Start to get Windows OS common configuration"
Write-Output ""
Write-Output "###############################################################"

# get each drive infomation

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
$destinationPath = $PSScriptRoot + "\" + $afterDirName + ".zip"
Compress-Archive -Path $basePath -DestinationPath $destinationPath
Remove-Item $basePath -Recurse
Write-Output "End zip archive compress"
Write-Output ""
Write-Output "zip file:" + $destinationPath
Write-Output ""
Write-Output "###############################################################"
Write-Output ""
Write-Output "End Get-SysConfig"
Write-Output ""
Write-Output "###############################################################"
