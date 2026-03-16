@echo off
setlocal enabledelayedexpansion
title Steam Identity Nuker ^& Windows Deep Cleaner
color 0c

:: ===================================================
:: ด่านที่ 0: ตรวจสอบและขอสิทธิ์ Administrator อัตโนมัติ
:: ===================================================
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [*] Requesting Administrative Privileges...
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)
:: เปลี่ยน Directory กลับมาที่ตำแหน่งที่รันสคริปต์ (เผื่อกรณี Run as Admin แล้ว Path เพี้ยน)
cd /d "%~dp0"

echo ===================================================
echo     STEAM IDENTITY NUKER ^& WINDOWS DEEP CLEANER
echo ===================================================
echo [!] WARNING: This will completely wipe your Steam
echo     login data, local configs, and identity.
echo     It can also deep clean your Windows junk files.
echo ===================================================
echo.

:: ===================================================
:: ด่านที่ 1: ถามยืนยันก่อนเริ่มกระบวนการทั้งหมด
:: ===================================================
set /p confirm_start="[?] Are you ready to proceed? (Y/N): "

if /i not "!confirm_start!"=="Y" (
    echo.
    echo [*] Operation cancelled. Your files are safe.
    pause
    exit /b
)

echo.
echo [!] Closing Steam...
taskkill /f /im steam.exe >nul 2>&1
taskkill /f /im steamwebhelper.exe >nul 2>&1
timeout /t 2 /nobreak >nul

:: ดึง Path ของ Steam
for /f "tokens=2*" %%a in ('reg query "HKCU\Software\Valve\Steam" /v "SteamPath" 2^>nul') do set "steampath=%%b"
set "steampath=!steampath:/=\!"
if not defined steampath (
    echo [!] Error: Steam path not found in Registry.
    pause
    exit /b
)

echo [*] Detected Steam Path: "!steampath!"
echo.
echo ===================================================
echo [*] Starting Identity Nuke Process...
echo ===================================================

echo [*] Deleting Registry Keys...
reg delete "HKCU\Software\Valve\Steam" /v "AutoLoginUser" /f >nul 2>&1
reg delete "HKCU\Software\Valve\Steam" /v "RememberPassword" /f >nul 2>&1
reg delete "HKCU\Software\Valve\Steam\Users" /f >nul 2>&1
reg delete "HKCU\Software\Valve\Steam\ActiveProcess" /f >nul 2>&1

echo [*] Deleting Sentry Files (SSFN)...
del /f /q /s "!steampath!\ssfn*" >nul 2>&1

echo [*] Deleting Configs and Login History...
del /f /q "!steampath!\config\loginusers.vdf" >nul 2>&1
del /f /q "!steampath!\config\config.vdf" >nul 2>&1
rmdir /s /q "!steampath!\config\htmlcache" >nul 2>&1

echo [*] Clearing User Data...
rmdir /s /q "!steampath!\userdata" >nul 2>&1
mkdir "!steampath!\userdata" >nul 2>&1

echo [*] Clearing Steam Caches and Logs...
rmdir /s /q "!steampath!\appcache" >nul 2>&1
rmdir /s /q "!steampath!\logs" >nul 2>&1
rmdir /s /q "!steampath!\dumps" >nul 2>&1
rmdir /s /q "!steampath!\depotcache" >nul 2>&1

echo.
:: ===================================================
:: ด่านที่ 2: ลบ Workshop
:: ===================================================
set /p clear_workshop="[?] Do you want to wipe Steam Workshop Content? (Y/N): "
if /i "!clear_workshop!"=="Y" (
    echo [*] Wiping Steam Workshop Content and Cache...
    rmdir /s /q "!steampath!\steamapps\workshop\content" >nul 2>&1
    rmdir /s /q "!steampath!\steamapps\workshop\downloads" >nul 2>&1
    rmdir /s /q "!steampath!\steamapps\workshop\temp" >nul 2>&1
    del /f /q "!steampath!\steamapps\workshop\appworkshop_*.acf" >nul 2>&1
    
    :: สร้างโฟลเดอร์กลับมาเพื่อป้องกัน Steam เอ๋อ
    mkdir "!steampath!\steamapps\workshop\content" >nul 2>&1
    mkdir "!steampath!\steamapps\workshop\downloads" >nul 2>&1
    echo [OK] Workshop content has been deleted.
) else (
    echo [*] Skipping Workshop deletion.
)
echo.

:: ===================================================
:: ด่านที่ 3: ลบขยะใน %TEMP% และ AppData ของ Steam
:: ===================================================
set /p clear_temp="[?] Do you want to wipe ALL junk files in Windows Temp & Steam AppData? (Y/N): "
if /i "!clear_temp!"=="Y" (
    echo [*] Clearing Windows AppData for Steam...
    rmdir /s /q "%LocalAppData%\Steam" >nul 2>&1
    rmdir /s /q "%LocalAppData%\Valve" >nul 2>&1

    echo [*] Wiping all files and folders in User Temp...
    del /s /f /q "%TEMP%\*.*" >nul 2>&1
    for /d %%p in ("%TEMP%\*") do rmdir "%%p" /s /q >nul 2>&1
    
    echo [OK] User Temp and AppData have been cleaned.
) else (
    echo [*] Skipping User Temp cleanup.
)
echo.

:: ===================================================
:: ด่านที่ 4: ลบขยะฝังลึกระดับ Windows (Deep Clean)
:: ===================================================
set /p deep_clean="[?] Do you want to deep clean Windows junk (System Temp, Prefetch, Update Cache)? (Y/N): "
if /i "!deep_clean!"=="Y" (
    echo [*] Emptying Recycle Bin...
    rd /s /q %systemdrive%\$Recycle.bin >nul 2>&1

    echo [*] Clearing System Temp folders...
    del /s /f /q "%WINDIR%\Temp\*.*" >nul 2>&1
    for /d %%p in ("%WINDIR%\Temp\*") do rmdir "%%p" /s /q >nul 2>&1

    echo [*] Clearing Windows Prefetch...
    del /s /f /q "%WINDIR%\Prefetch\*.*" >nul 2>&1

    echo [*] Clearing Windows Update Cache...
    net stop wuauserv >nul 2>&1
    del /s /f /q "%WINDIR%\SoftwareDistribution\Download\*.*" >nul 2>&1
    for /d %%p in ("%WINDIR%\SoftwareDistribution\Download\*") do rmdir "%%p" /s /q >nul 2>&1
    net start wuauserv >nul 2>&1

    echo [*] Clearing Crash Dumps and Error Reports...
    del /s /f /q "%LocalAppData%\CrashDumps\*.*" >nul 2>&1
    del /s /f /q "%ProgramData%\Microsoft\Windows\WER\ReportArchive\*.*" >nul 2>&1

    echo [*] Flushing DNS Cache...
    ipconfig /flushdns >nul 2>&1

    echo [OK] Windows deep clean complete.
) else (
    echo [*] Skipping Windows deep clean.
)
echo.

echo ===================================================
echo [SUCCESS] Operation Completed Successfully!
echo [!] Your system is ready for a fresh start.
pause
