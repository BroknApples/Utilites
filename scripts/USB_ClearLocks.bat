:: ============================================================================
:: Copyright (c) 2026 Brokn_Apples
:: All rights reserved.
::
:: Description:
::     This script clears any locks preventing a USB-drive from being ejected.
:: Usage:
::     Run from command prompt: ./USB_ClearLocks.bat
::     OR double-click file
:: ============================================================================


@echo off
setlocal enabledelayedexpansion

:: 1. Handle Admin Elevation
net session >nul 2>&1
if %errorLevel% neq 0 (
    powershell -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b
)

set "usb_drive=%~d0"

:: 2. Identify locking processes (Strictly ignore Explorer)
echo Scanning %usb_drive% for active locks...
set "proc_list="
for /f "delims=" %%i in ('powershell -NoProfile -Command ^
    "$drive = '%usb_drive%\'; Get-Process | Where-Object { ($_.Modules.FileName -like \"$drive*\") -and ($_.Name -ne 'explorer') } | Select-Object -ExpandProperty Name -Unique ^| Out-String"') do (
    set "proc_list=%%i"
)

:: 3. Show Warning Box if other processes are found
if not "%proc_list%"=="" (
    :: Create a simpler VBScript that won't trigger 'Object Required' errors
    echo MsgBox "The following apps are using your USB and will be closed:" ^& vbCrLf ^& "%proc_list%" ^& vbCrLf ^& "Explorer will be ignored.", 48, "USB Force Eject" > "%temp%\msg.vbs"
    wscript "%temp%\msg.vbs"
    del "%temp%\msg.vbs"
)

:: 4. Create the Worker Script on your local C: drive
set "temp_script=%temp%\usb_final_fix.bat"
(
echo @echo off
echo echo Releasing handles on %usb_drive%...

:: Kill identified processes (ignoring Explorer)
if not "%proc_list%"=="" (
    for %%p in (%proc_list%) do (
        taskkill /f /im %%p.exe /t 2^>nul
    )
)

:: 5. The "Nuclear" Dismount (Essential for UAS devices)
:: This forces the drive to 'reboot' its connection
echo echo select volume %usb_drive:~0,1% ^> "%temp%\dp.txt"
echo echo offline disk ^>^> "%temp%\dp.txt"
echo echo online disk ^>^> "%temp%\dp.txt"
echo diskpart /s "%temp%\dp.txt" ^>nul

echo echo.
echo echo SUCCESS: %usb_drive% handles released.
echo echo You can now safely remove the drive.
echo timeout /t 3 ^>nul
echo del "%temp%\dp.txt"
echo start /b "" cmd /c del "%%~f0" ^& exit
) > "%temp_script%"

:: 6. Launch the worker and close the USB file instantly
start "" "%temp_script%"
exit
