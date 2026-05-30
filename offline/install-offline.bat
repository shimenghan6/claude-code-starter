@echo off
chcp 65001 >nul
title Claude Code Starter - 离线安装

echo.
echo  ╔══════════════════════════════════════════╗
echo  ║     Claude Code Starter                ║
echo  ║     VS Code + DeepSeek + Skills        ║
echo  ╚══════════════════════════════════════════╝
echo.
echo  需要网络来下载 Claude Code 和依赖。
echo  Skills 和微信模块已打包在本地，无需 GitHub。
echo.

:: Step 0: VS Code
echo [0/7] VS Code...
where code >nul 2>&1
if %errorlevel% neq 0 (
    set /p INSTALL_VSC="  安装 VS Code? (y/n): "
    if /i "%INSTALL_VSC%"=="y" (
        winget install Microsoft.VisualStudioCode --accept-package-agreements 2>nul
        code --install-extension anthropic.claude-code 2>nul
        echo  [OK] VS Code installed
    )
) else (
    echo  [OK] VS Code found
    code --install-extension anthropic.claude-code 2>nul
)

:: Step 1: Node.js
echo [1/7] Checking Node.js...
where node >nul 2>&1
if %errorlevel% neq 0 (
    echo  [ERROR] Node.js not found. Please install from https://nodejs.org
    echo  下载 LTS version, install, then re-run this script.
    pause
    exit /b 1
)
echo  [OK] Node.js

:: Step 2: Claude Code
echo [2/7] Installing Claude Code...
call npm install -g @anthropic-ai/claude-code 2>nul
echo  [OK] Claude Code

:: Step 3: DeepSeek
echo [3/7] DeepSeek API Key...
echo.
echo  Need DeepSeek API Key (registration gives free credits).
set /p HAS_KEY="  Already have API Key? (y/n, default n): "
if /i not "%HAS_KEY%"=="y" (
    echo  Opening DeepSeek registration page...
    start "" "https://platform.deepseek.com"
    echo.
    echo  Registration steps:
    echo  1. Register/login at platform.deepseek.com
    echo  2. Click "API Keys" on left
    echo  3. Create new key, copy it
    echo  4. Paste here
)

:paste_key
set /p DEEPSEEK_KEY="  Paste DeepSeek API Key (sk-xxx, Enter to skip): "
if "%DEEPSEEK_KEY%"=="" (
    echo  Skipped. Edit ~/.claude/settings.json later.
) else (
    if not exist "%USERPROFILE%\.claude" mkdir "%USERPROFILE%\.claude"
    (
    echo {
    echo   "env": {
    echo     "ANTHROPIC_BASE_URL": "https://api.deepseek.com/anthropic",
    echo     "ANTHROPIC_AUTH_TOKEN": "%DEEPSEEK_KEY%",
    echo     "ANTHROPIC_MODEL": "deepseek-v4-pro[1m]",
    echo     "ANTHROPIC_DEFAULT_OPUS_MODEL": "deepseek-v4-pro[1m]",
    echo     "ANTHROPIC_DEFAULT_SONNET_MODEL": "deepseek-v4-pro[1m]",
    echo     "ANTHROPIC_DEFAULT_HAIKU_MODEL": "deepseek-v4-flash[1m]",
    echo     "CLAUDE_CODE_EFFORT_LEVEL": "max"
    echo   }
    echo }
    ) > "%USERPROFILE%\.claude\settings.json"
    echo  [OK] DeepSeek configured
)

:: Step 4: Skills (FROM LOCAL - NO GITHUB NEEDED)
echo [4/7] Installing skills (local copy, no GitHub)...
set SKILLS_DIR=%USERPROFILE%\.claude\skills

if exist "%~dp0skills\browser-control\SKILL.md" (
    mkdir "%SKILLS_DIR%\browser-control" 2>nul
    copy "%~dp0skills\browser-control\SKILL.md" "%SKILLS_DIR%\browser-control\SKILL.md" >nul
    echo  [OK] browser-control
) else (
    echo  [-] browser-control not in package
)

if exist "%~dp0skills\github-research\SKILL.md" (
    mkdir "%SKILLS_DIR%\github-research" 2>nul
    copy "%~dp0skills\github-research\SKILL.md" "%SKILLS_DIR%\github-research\SKILL.md" >nul
    echo  [OK] github-research
)

if exist "%~dp0skills\sound-notifier\SKILL.md" (
    mkdir "%SKILLS_DIR%\claude-code-sound-notifier" 2>nul
    copy "%~dp0skills\sound-notifier\SKILL.md" "%SKILLS_DIR%\claude-code-sound-notifier\SKILL.md" >nul
    echo  [OK] sound-notifier
)

:: Step 5: WeChat (optional, FROM LOCAL)
echo [5/7] WeChat access...
set /p WECHAT="  Install WeChat remote control? (y/n, default n): "
if /i "%WECHAT%"=="y" (
    if exist "%~dp0wechat\wechat-bridge.mjs" (
        copy "%~dp0wechat\wechat-bridge.mjs" "%USERPROFILE%\.claude\wechat-bridge.mjs" >nul
        copy "%~dp0wechat\media-processor.py" "%USERPROFILE%\.claude\media-processor.py" >nul 2>nul
        copy "%~dp0wechat\cloud_vision.py" "%USERPROFILE%\.claude\cloud_vision.py" >nul 2>nul
        call npm install -g claude-code-wechat-channel @weixin-claw/core 2>nul
        echo  [OK] WeChat bridge installed
        echo  Next: scan QR code to connect
        echo  See https://github.com/shimenghan6/claude-code-wechat for details
    ) else (
        echo  [-] WeChat module not found in package
    )
) else (
    echo  Skipped
)

:: Step 6: Done
echo [7/7] Done!
echo.
echo  ╔══════════════════════════════════════════╗
echo  ║          Installation Complete!         ║
echo  ║                                        ║
echo  ║  Open VS Code, Ctrl+` to terminal,     ║
echo  ║  type: claude                          ║
echo  ║                                        ║
echo  ║  Try saying:                           ║
echo  ║    "help me write a Python scraper"    ║
echo  ║    "search React 19 features"          ║
echo  ║    "check out project xxx on GitHub"   ║
echo  ╚══════════════════════════════════════════╝
echo.
pause
