@echo off
cd /d "%~dp0"
title Mitsubishi Serial Sniffer Tool
powershell -ExecutionPolicy Bypass -NoProfile -File "Mitsu_Sniffer_GUI.ps1"
if %ERRORLEVEL% NEQ 0 (
    echo.
    echo Co loi khi khoi chay giao dien. Nhan phim bat ky de xem loi...
    pause
)
