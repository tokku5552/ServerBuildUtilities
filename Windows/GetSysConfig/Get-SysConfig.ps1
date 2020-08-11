Write-Output "Get Configuration Script start"
Get-WindowsFeature > .\Get_Windows_Feature.txt
Get-Volume > .\Get_Volume.txt
Get-Service | Format-Table -AutoSize | Out-String -Width 4096 > .\Get_Service.txt