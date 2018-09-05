rem ****************************************************************
rem NAME:
rem           CleanWin10ForSysprepOrVMwareTemplate.bat
rem PURPOSE:
rem           This batch file cleans up a Windows 10 Image for Windows Sysprep or VMWare Template
rem DESCRIPTION:
rem           This batch script should be the last step before running Sysprep or creating VMWare Template.
rem FLAGS:
rem           -shutdown   This will shutdown the OS after cleanup. 
rem                       Shutdown flag is recommended when making a VM Template
rem                       Shutdown flag is not recommended before Sysprep.  The sysprep command should 
rem                       be called immediately after this script is finished (without a shutdown in between).
rem USAGE:
rem           CleanWin10ForSysprepOrVMwareTemplate.bat <-shutdown>
rem RESULTS:
rem           A windows 10 image ready for sysprep or a vmware template
rem DATE:
rem           20180121
rem AUTHOR:   
rem           Mike Stine
rem           https://github.com/mikestine
rem ****************************************************************

@ECHO OFF

rem ****************************************************************
rem Remove Window's "Built-In" apps that were added or updated through Windows Apps Store after the Win10 installation, 
rem Evoke powershell with "privilege escalation" (haha).
rem ****************************************************************

powershell -c "Get-AppxPackage -allusers | Remove-AppxPackage"

rem ****************************************************************
rem Stop and disable Windows update service
rem Necessary to remove certain files
rem ****************************************************************

sc stop wuauserv
sc config wuauserv start= disabled

rem ****************************************************************
rem Clears automatic update temporary storage
rem Windows update service must be stopped prior
rem ****************************************************************

del %windir%\SoftwareDistribution\Download\*.* /f /s /q

rem ****************************************************************
rem Delete Windows Install Files
rem ****************************************************************

del %windir%\$NT* /f /s /q /a:h

rem ****************************************************************
rem Delete Prefetch Files
rem Prefetch files are created when an app is installed and help the app start faster
rem ****************************************************************

del %windir%\Prefetch\*.* /f /s /q

rem ****************************************************************
rem Remove Temp Files
rem /S subdirs, /Q quiet, /F Force, /A: select by attribute A:archive H:Hidden R:Readonly S:System
rem ****************************************************************

del C:\Temp /S /Q /F
del C:\Temp /S /Q /A:H
for /D %%p in ("C:\Temp\*") do rmdir "%%p" /s /q
del %windir%\Temp /S /Q /F
del %windir%\Temp /S /Q /A:H
for /D %%p in ("C:\Windows\Temp\*") do rmdir "%%p" /s /q
del "%temp%" /S /Q /F
del "%temp%" /S /Q /A:H
for /D %%p in ("%temp%\*") do rmdir "%%p" /s /q

rem ****************************************************************
rem Remove Temporary Internet Data
rem ****************************************************************

del "%LocalAppData%\Microsoft\Windows\Temporary Internet Files\Low" /S /Q /F
del "%LocalAppData%\Microsoft\Windows\Temporary Internet Files\Low" /S /Q /A:H
for /D %%p in ("%LocalAppData%\Microsoft\Windows\Temporary Internet Files\Low\*") do rmdir "%%p" /s /q
del "%AppData%\Microsoft\Windows\Cookies\Low" /S /Q /F
del "%AppData%\Microsoft\Windows\Cookies\Low" /S /Q /A:H
for /D %%p in ("%AppData%\Microsoft\Windows\Cookies\Low\*") do rmdir "%%p" /s /q
del "%LocalAppData%\Microsoft\Windows\History\Low" /S /Q /F
del "%LocalAppData%\Microsoft\Windows\History\Low" /S /Q /A:H
for /D %%p in ("%LocalAppData%\Microsoft\Windows\History\Low\*") do rmdir "%%p" /s /q
del "%LocalAppData%\Temp\Low" /S /Q /F
del "%LocalAppData%\Temp\Low" /S /Q /A:H
for /D %%p in ("%LocalAppData%\Temp\Low\*") do rmdir "%%p" /s /q
del "%LocalAppData%\Microsoft\Windows\INetCache\IE" /S /Q /F
del "%LocalAppData%\Microsoft\Windows\INetCache\IE" /S /Q /A:H
for /D %%p in ("%LocalAppData%\Microsoft\Windows\INetCache\IE*") do rmdir "%%p" /s /q

rem ****************************************************************
rem Delete any existing shadow copies
rem Shadows Copies are snapshots of data of changed files overtime stored in shadow folders
rem ****************************************************************

vssadmin delete shadows /All /Quiet
vssadmin resize shadowstorage /for=c: /on=c: /maxsize=unbounded

rem ****************************************************************
rem Windows cleanup Manager
rem For this to work, you must create sagerun "1" prior to running this script
rem To create sagerun "1", run the following with admin privileges 
rem cleanmgr /sageset:1 
rem Then check all the boxes, and exit.  
rem ****************************************************************

%windir%\system32\cleanmgr /sagerun:1

rem ****************************************************************
rem Defragment the harddisk with fancy windows 10 defrag service
rem /U print progress, /V verbose
rem ****************************************************************

sc config defragsvc start= auto
net start defragsvc
defrag c: /U /V
net stop defragsvc
sc config defragsvc start= disabled

rem ****************************************************************
rem Clear all Event Logs in Event View
rem ****************************************************************

for /f %%a in ('wevtutil enum-logs') do wevtutil clear-log "%%a"

rem ****************************************************************
rem Removes dhcp obtained ip address and internet
rem ****************************************************************

ipconfig /release

rem ****************************************************************
rem Flush the local DNS cache
rem ****************************************************************

ipconfig /flushdns

rem ****************************************************************
rem Shutdown OS if "-shutdown" flag exists
rem ****************************************************************

if "%~1"=="-shutdown" shutdown /s /t 0

rem DONE 
