@echo off
chcp 65001 >nul
title 打包离线安装包

set PACKAGE_DIR=%~dp0
set STAGING=%TEMP%\claude-code-starter-package
set OUTPUT=%USERPROFILE%\Desktop\ClaudeCode一键安装包.zip

echo ============================================
echo  打包 Claude Code Starter 离线安装包
echo ============================================
echo.

:: Clean staging
if exist "%STAGING%" rmdir /s /q "%STAGING%"
mkdir "%STAGING%"

echo [1/5] 复制安装脚本...
copy "%PACKAGE_DIR%install-offline.bat" "%STAGING%\双击安装.bat" >nul
copy "%PACKAGE_DIR%..\settings.template.json" "%STAGING%\settings-template.json" >nul

echo [2/5] 复制 skill...
:: browser-control
mkdir "%STAGING%\skills\browser-control"
copy "%USERPROFILE%\.claude\skills\browser-control\SKILL.md" "%STAGING%\skills\browser-control\SKILL.md" >nul 2>&1
if not exist "%STAGING%\skills\browser-control\SKILL.md" (
    echo   [-] browser-control 本地未找到，从 GitHub 下载...
    curl -fsSL "https://raw.githubusercontent.com/shimenghan6/browser-control/master/SKILL.md" -o "%STAGING%\skills\browser-control\SKILL.md" 2>nul
)

:: github-research
mkdir "%STAGING%\skills\github-research"
copy "%USERPROFILE%\.claude\skills\github-research\SKILL.md" "%STAGING%\skills\github-research\SKILL.md" >nul 2>&1
if not exist "%STAGING%\skills\github-research\SKILL.md" (
    echo   [-] github-research 本地未找到，从 GitHub 下载...
    curl -fsSL "https://raw.githubusercontent.com/shimenghan6/github-research/master/SKILL.md" -o "%STAGING%\skills\github-research\SKILL.md" 2>nul
)

:: sound-notifier
mkdir "%STAGING%\skills\sound-notifier"
copy "%USERPROFILE%\.claude\skills\claude-code-sound-notifier\SKILL.md" "%STAGING%\skills\sound-notifier\SKILL.md" >nul 2>&1
if not exist "%STAGING%\skills\sound-notifier\SKILL.md" (
    echo   [-] sound-notifier 本地未找到，从 GitHub 下载...
    curl -fsSL "https://raw.githubusercontent.com/shimenghan6/claude-code-sound-notifier/master/install.ps1" -o "%STAGING%\skills\sound-notifier\install.ps1" 2>nul
)

echo [3/5] 复制微信模块（最新版本）...
copy "%USERPROFILE%\.claude\wechat-bridge.mjs" "%STAGING%\wechat\wechat-bridge.mjs" >nul 2>&1
copy "%USERPROFILE%\.claude\media-processor.py" "%STAGING%\wechat\media-processor.py" >nul 2>&1
copy "%USERPROFILE%\.claude\cloud_vision.py" "%STAGING%\wechat\cloud_vision.py" >nul 2>&1

echo [4/5] 生成使用说明...
(
echo Claude Code Starter - 一键安装包
echo.
echo 【怎么用】
echo 1. 双击"双击安装.bat"
echo 2. 按提示粘贴 DeepSeek API Key
echo 3. 完成！
echo.
echo 【需要什么】
echo - Windows 10/11
echo - 网络（安装过程需要下载 Claude Code）
echo - DeepSeek API Key（去 platform.deepseek.com 注册即可）
echo.
echo 【装了什么】
echo - VS Code + Claude Code 扩展
echo - Claude Code CLI（AI 编程助手）
echo - DeepSeek V4 Pro 模型配置
echo - 3个 skill（浏览器操控 / GitHub调研 / 声音提示）
echo - 微信接入模块（可选）
echo.
echo 【开源地址】
echo https://github.com/shimenghan6/claude-code-starter
echo.
echo 【需要远程协助？】
echo 加微信：你的微信号
echo 基础安装 88 / 进阶版 168 / 尊享版 298
) > "%STAGING%\说明.txt"

echo [5/5] 打包 ZIP...
powershell -Command "Compress-Archive -Path '%STAGING%\*' -DestinationPath '%OUTPUT%' -Force"

echo.
echo ============================================
echo  打包完成！
echo  文件: %OUTPUT%
echo ============================================
echo.
echo  把这个 ZIP 发给用户，解压后双击"双击安装.bat"即可。
echo.
pause
