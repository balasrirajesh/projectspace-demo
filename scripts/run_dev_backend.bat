@echo off
REM Quick WebRTC Server Setup Helper
REM Shows server IP and starts the signaling server

cls
echo.
echo =====================================
echo      WebRTC Server Setup Helper
echo =====================================
echo.

REM Get IP Address
echo Detecting your server IP address...
echo.

for /f "tokens=2 delims=: " %%a in ('ipconfig ^| findstr /C:"IPv4 Address" ^| findstr /V "169.254"') do (
    set "SERVER_IP=%%a"
)

if defined SERVER_IP (
    echo ✓ SERVER IP DETECTED: %SERVER_IP%
) else (
    echo ✗ Could not detect IP. Please check manually with: ipconfig
    set "SERVER_IP=YOUR_IP_HERE"
)

echo.
echo Port: 3000
echo.
echo =================================
echo SETUP INSTRUCTIONS:
echo =================================
echo.
echo 1. Configure each device:
echo    - Open App Settings ^> Server Settings
echo    - Enter this IP: %SERVER_IP%
echo    - Port: 3000
echo    - Test connection
echo    - Save
echo.
echo 2. Ensure all devices on same WiFi
echo.
echo 3. Restart app after saving IP
echo.
echo =================================
echo.
echo Starting WebRTC Signaling Server...
echo.
echo Server will run on: http://%SERVER_IP%:3000
echo.
echo Press ENTER to start server, or CTRL+C to cancel.
pause

cd /d "%~dp0signaling_server"
echo Starting npm server...
npm start
