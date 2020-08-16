#######################################################################
# 
# Get-SysConfig.ps1
#
# Version : 0.1.0
#                                          Copyright (c) 2020 tokku5552
#                     https://github.com/tokku5552/ServerBuildUtilities
#
#######################################################################

# Overview

WindowsのOS設定情報取得ツール。

# Description

Windows 10 および Windows Server 2016の以下の設定情報が取得できます。
・hosts（ディレクトリ）
  C:\Windows\System32\drivers\etc\ に格納されているファイルを取得します。

・OS_Version.txt
  OSのバージョン情報を取得します。

・systeminfo.txt
  systeminfoコマンドの結果を取得します。

・PatchList.txt
  適用されているパッチのリストを取得します。

・Application_evt.csv
・Application_evt.evtx
・System_evt.csv
・System_evt.evtx
　Application、Systemのイベントログを取得します。

・Get_Volume.txt
  ボリューム情報を取得します。

・Get_ChildItem_<DriveLetter>_drive.txt
  存在するドライブのディレクトリ情報を取得します。

・Get_ComputerInfo.txt
  Get-ComputerInfo コマンドの結果を取得します。

・Get_LocalGroup.txt
・Get_LocalUser.txt
  ローカルユーザ、ローカルグループ情報を取得します。

・Get_NetFirewallProfile.txt
  ファイアウォールの設定情報を取得します。

・Get_Service.txt
  サービス一覧を取得します。

・Get_WindowsOptionalFeature.txt
・Get_WindowsFeature.txt
  クライアントOSであればGet-WindowsOptionalFeature
  サーバOSであればGet-WindowsFeatureの結果を取得します。

・gpresult.txt
・secedit.log
  グループポリシーの結果セット、およびセキュリティポリシーを取得します。

・ipconfig.txt
  ipconfig /all の結果を取得します。

・route_print.txt
  route print の結果を取得します。

・MemDump.txt
  仮想メモリの設定情報を取得します。

・w32tm_query.txt
・Registry_W32Time.txt
  NTPの設定情報と実行状況を取得します。


# Requiremnent

OS 標準のPowerShell、および役割追加時のRSATに付属のmoduleが必要です。
※役割の情報取得は現バージョンでは未対応です
・動作確認済みOS
Windows 10 Pro
Windows Server 2016
Windows Server 2019

# Usage

Get-SysConfigフォルダをドライブ
run.batを管理者権限で実行します。
Get-SysConfig.ps1が存在するフォルダの配下に、<コンピュータ名>_<日時>.zipが
生成されます。
生成が完了したらコマンドプロンプト上でEnterを押して閉じてください。