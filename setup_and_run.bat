@echo off
title File Hash Verification - Setup & Launch
color 0A

echo.
echo ============================================
echo   Decentralized File Hash Verification
echo   One-Click Setup Script
echo ============================================
echo.

:: ─── Check Node.js ─────────────────────────────
where node >nul 2>nul
if %ERRORLEVEL% neq 0 (
    color 0C
    echo [ERROR] Node.js is not installed!
    echo Download it from: https://nodejs.org
    echo.
    pause
    exit /b 1
)
echo [OK] Node.js found: 
node --version

:: ─── Install dependencies ──────────────────────
echo.
echo [1/4] Installing dependencies...
cd /d "%~dp0"
call npm install
if %ERRORLEVEL% neq 0 (
    color 0C
    echo [ERROR] npm install failed!
    pause
    exit /b 1
)
echo [OK] Dependencies installed.

:: ─── Start Ganache in background ───────────────
echo.
echo [2/4] Starting local blockchain (Ganache) on port 7545...
start "Ganache" /min cmd /c "npx ganache --port 7545 --quiet"

:: Wait for Ganache to boot up
echo Waiting for Ganache to start...
timeout /t 5 /nobreak >nul

:: Quick check - try to connect to port 7545
powershell -Command "try { $c = New-Object System.Net.Sockets.TcpClient('127.0.0.1', 7545); $c.Close(); Write-Host '[OK] Ganache is running on port 7545' } catch { Write-Host '[WARN] Ganache may still be starting...' }"

:: ─── Compile & Deploy ──────────────────────────
echo.
echo [3/4] Compiling and deploying smart contract...
npx truffle compile
if %ERRORLEVEL% neq 0 (
    color 0C
    echo [ERROR] Compilation failed!
    pause
    exit /b 1
)

:: Deploy and capture the contract address
echo.
echo Deploying to Ganache...
npx truffle migrate --network development > deploy_output.txt 2>&1
type deploy_output.txt

:: Extract contract address from deploy output
echo.
for /f "tokens=3 delims=> " %%a in ('findstr /C:"contract address:" deploy_output.txt') do (
    set CONTRACT_ADDR=%%a
)

if not defined CONTRACT_ADDR (
    color 0C
    echo [ERROR] Could not extract contract address from deployment output.
    echo Please check deploy_output.txt and update frontend\index.html manually.
    pause
    exit /b 1
)

echo.
echo [OK] Contract deployed at: %CONTRACT_ADDR%

:: ─── Patch frontend with contract address ──────
echo.
echo [4/4] Updating frontend with contract address...
powershell -Command "(Get-Content 'frontend\index.html') -replace 'PASTE_YOUR_CONTRACT_ADDRESS_HERE', '%CONTRACT_ADDR%' | Set-Content 'frontend\index.html'"
powershell -Command "(Get-Content 'frontend\index.html') -replace '0x[a-fA-F0-9]{40}', '%CONTRACT_ADDR%' | Set-Content 'frontend\index.html'"
echo [OK] Frontend updated.

:: ─── Clean up ──────────────────────────────────
del deploy_output.txt >nul 2>nul

:: ─── Open in browser ───────────────────────────
echo.
echo ============================================
echo   ALL DONE! Opening frontend in browser...
echo ============================================
echo.
echo   Contract Address: %CONTRACT_ADDR%
echo   Ganache RPC:      http://127.0.0.1:7545
echo.
echo   IMPORTANT: Connect MetaMask to Ganache
echo   Network RPC:  http://127.0.0.1:7545
echo   Chain ID:     1337
echo.
echo   DO NOT close this window - Ganache is
echo   running in the background.
echo ============================================
echo.

start "" "frontend\index.html"

pause
