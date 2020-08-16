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

Windows��OS�ݒ���擾�c�[���B

# Description

Windows 10 ����� Windows Server 2016�̈ȉ��̐ݒ��񂪎擾�ł��܂��B
�Ehosts�i�f�B���N�g���j
  C:\Windows\System32\drivers\etc\ �Ɋi�[����Ă���t�@�C�����擾���܂��B

�EOS_Version.txt
  OS�̃o�[�W���������擾���܂��B

�Esysteminfo.txt
  systeminfo�R�}���h�̌��ʂ��擾���܂��B

�EPatchList.txt
  �K�p����Ă���p�b�`�̃��X�g���擾���܂��B

�EApplication_evt.csv
�EApplication_evt.evtx
�ESystem_evt.csv
�ESystem_evt.evtx
�@Application�ASystem�̃C�x���g���O���擾���܂��B

�EGet_Volume.txt
  �{�����[�������擾���܂��B

�EGet_ChildItem_<DriveLetter>_drive.txt
  ���݂���h���C�u�̃f�B���N�g�������擾���܂��B

�EGet_ComputerInfo.txt
  Get-ComputerInfo �R�}���h�̌��ʂ��擾���܂��B

�EGet_LocalGroup.txt
�EGet_LocalUser.txt
  ���[�J�����[�U�A���[�J���O���[�v�����擾���܂��B

�EGet_NetFirewallProfile.txt
  �t�@�C�A�E�H�[���̐ݒ�����擾���܂��B

�EGet_Service.txt
  �T�[�r�X�ꗗ���擾���܂��B

�EGet_WindowsOptionalFeature.txt
�EGet_WindowsFeature.txt
  �N���C�A���gOS�ł����Get-WindowsOptionalFeature
  �T�[�oOS�ł����Get-WindowsFeature�̌��ʂ��擾���܂��B

�Egpresult.txt
�Esecedit.log
  �O���[�v�|���V�[�̌��ʃZ�b�g�A����уZ�L�����e�B�|���V�[���擾���܂��B

�Eipconfig.txt
  ipconfig /all �̌��ʂ��擾���܂��B

�Eroute_print.txt
  route print �̌��ʂ��擾���܂��B

�EMemDump.txt
  ���z�������̐ݒ�����擾���܂��B

�Ew32tm_query.txt
�ERegistry_W32Time.txt
  NTP�̐ݒ���Ǝ��s�󋵂��擾���܂��B


# Requiremnent

OS �W����PowerShell�A����і����ǉ�����RSAT�ɕt����module���K�v�ł��B
�������̏��擾�͌��o�[�W�����ł͖��Ή��ł�
�E����m�F�ς�OS
Windows 10 Pro
Windows Server 2016
Windows Server 2019

# Usage

Get-SysConfig�t�H���_���h���C�u
run.bat���Ǘ��Ҍ����Ŏ��s���܂��B
Get-SysConfig.ps1�����݂���t�H���_�̔z���ɁA<�R���s���[�^��>_<����>.zip��
��������܂��B
����������������R�}���h�v�����v�g���Enter�������ĕ��Ă��������B