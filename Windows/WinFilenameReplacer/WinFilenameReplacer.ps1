###############################################################
# 
# WinFilenameReplacer.ps1
# 
###############################################################

using namespace System.Windows.Forms
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
 
[Application]::EnableVisualStyles()
 
function GetFolderPath {
  param (
    [Parameter(ValueFromPipeline = $True)]
    [string]$Description = "フォルダを選択してください"
  )
  # show main window
  $currentProcess = [Diagnostics.Process]::GetCurrentProcess()
  $window = New-Object Windows.Forms.NativeWindow
  $window.AssignHandle($currentProcess.MainWindowHandle)

  $dialog = New-Object System.Windows.Forms.FolderBrowserDialog
  $dialog.Description = $Description
  $dialog.SelectedPath = (Get-Item $PWD).FullName
  
  # show dialog
  $ret = $dialog.ShowDialog($window)

  if ($ret -eq [System.Windows.Forms.DialogResult]::OK) {
    return $dialog.SelectedPath
  }
  else {
    return $null
  }
}

function ReplaceFileName {
  param (
    [Parameter(Mandatory = $True)][string]$pattern,
    [Parameter(Mandatory = $True)][string]$replace
  )
  Get-ChildItem | Rename-Item -NewName { $_.Name -replace $pattern, $replace }
}

##### FilePathUI
# LabelFilePath
$LabelFilePath = New-Object Label
$LabelFilePath.Location = New-Object Drawing.Point(20, 10)
$LabelFilePath.Size = New-Object Drawing.Size(80, 20)
$LabelFilePath.Text = "ファイルパス"
# TextBoxFilePath
$TextBoxFilePath = New-Object TextBox
$TextBoxFilePath.Location = New-Object Drawing.Point(20, 30)
$TextBoxFilePath.Size = New-Object Drawing.Size(300, 20)
# ButtonFilePath
$ButtonFilePath = New-Object Button
$ButtonFilePath.Location = New-Object Drawing.Point(320, 30)
$ButtonFilePath.Size = New-Object Drawing.Size(40, 20)
$ButtonFilePath.Text = "参照"
$ButtonFilePath.Add_Click{
  $TextBoxFilePath.Text = GetFolderPath
}

##### PatternUI
# LabelPattern
$LabelPattern = New-Object Label
$LabelPattern.Location = New-Object Drawing.Point(20, 60)
$LabelPattern.Size = New-Object Drawing.Size(80, 20)
$LabelPattern.Text = "検索文字列"
# TextBoxPattern
$TextBoxPattern = New-Object TextBox
$TextBoxPattern.Location = New-Object Drawing.Point(20, 80)
$TextBoxPattern.Size = New-Object Drawing.Size(300, 20)

##### ReplaceUI
# LabelReplace
$LabelReplace = New-Object Label
$LabelReplace.Location = New-Object Drawing.Point(20, 110)
$LabelReplace.Size = New-Object Drawing.Size(80, 20)
$LabelReplace.Text = "置換文字列"
# TextBoxReplace
$TextBoxReplace = New-Object TextBox
$TextBoxReplace.Location = New-Object Drawing.Point(20, 130)
$TextBoxReplace.Size = New-Object Drawing.Size(300, 20)
# ButtonReplace
$ButtonReplace = New-Object Button
$ButtonReplace.Text = "置換"
$ButtonReplace.Font = New-Object Drawing.Font("Meiryo UI", 10)
$ButtonReplace.Size = New-Object Drawing.Size(60, 20)
$ButtonReplace.Location = New-Object Drawing.Point(240, 160)

##### MainProcess
# ButtonReplace_Click
$ButtonReplace_Click = {
  if (![string]::IsNullOrEmpty($TextBoxFilePath.Text)) {
    if (Test-Path $TextBoxFilePath.Text) {
      Set-Location $TextBoxFilePath.Text
    }
    else {
      [System.Windows.Forms.MessageBox]::Show( "フォルダパスが正しくありません", "異常終了", "Ok", "Error" )
      return
    }
  }
  else {
    [System.Windows.Forms.MessageBox]::Show( "フォルダパスが正しくありません", "異常終了", "Ok", "Error" )
    return
  }
  try {
    ReplaceFileName $TextBoxPattern.text $TextBoxReplace.text -ErrorAction Stop
  }
  catch {
    if ([string]::IsNullOrEmpty($TextBoxPattern.text)) {
      [System.Windows.Forms.MessageBox]::Show( "検索文字列が空です", "異常終了", "Ok", "Error" )
      return
    }
    else {
      [System.Windows.Forms.MessageBox]::Show( "置換文字列が空です", "異常終了", "Ok", "Error" )
      return
    }
  }
  if ( $? ) {
    [System.Windows.Forms.MessageBox]::Show( "ファイルを置換しました", "正常終了", "Ok", "Information" )
  }
  else {
    [System.Windows.Forms.MessageBox]::Show( "ファイルの置換に失敗しました", "異常終了", "Ok", "Error" )
  }
}
$ButtonReplace.Add_Click($ButtonReplace_Click)

# Form
$Form = New-Object Form
$Form.Text = "WinFilenameReplacer"
$Form.Size = New-Object Drawing.Size(380, 250)
$Form.Controls.AddRange(@($LabelFilePath, $TextBoxFilePath, $ButtonFilePath, $LabelPattern, $TextBoxPattern, $LabelReplace, $TextBoxReplace, $ButtonReplace))
$Form.ShowDialog()
