@echo off
setlocal enabledelayedexpansion
title Steam Identity Nuker
color 0c

echo ===================================================
echo              STEAM IDENTITY NUKER
echo ===================================================
echo [!] WARNING: This will completely wipe your Steam
echo     login data, local configs, and identity.
echo ===================================================
echo.

:: ด่านที่ 1: ถามยืนยันก่อนเริ่มกระบวนการทั้งหมด
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
:: ด่านที่ 2: ถามยืนยันก่อนลบ Workshop
set /p clear_workshop="[?] Do you want to wipe Workshop Content to free up space? (Y/N): "
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

echo [*] Clearing Windows AppData and Temp...
rmdir /s /q "%LocalAppData%\Steam" >nul 2>&1
rmdir /s /q "%LocalAppData%\Valve" >nul 2>&1
del /f /q /s "%TEMP%\*steam*" >nul 2>&1

echo ===================================================
echo [SUCCESS] Steam identity and cache have been completely wiped.
echo [!] Ready for a fresh start.
pause