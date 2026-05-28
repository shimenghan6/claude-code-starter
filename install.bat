@echo off
chcp 65001 >nul
title Claude Code Starter - 一键安装

echo.
echo  ╔══════════════════════════════════════════╗
echo  ║     Claude Code Starter                ║
echo  ║     Claude Code + DeepSeek + 技能包     ║
echo  ╚══════════════════════════════════════════╝
echo.

:: ── Step 0: Check prerequisites ──
echo [1/6] 检查环境...

where node >nul 2>&1
if %errorlevel% neq 0 (
    echo.
    echo  [X] 未检测到 Node.js
    echo  请先安装 Node.js: https://nodejs.org
    echo  下载 LTS 版本，一路下一步即可。
    echo  安装完成后重新运行本脚本。
    pause
    exit /b 1
)
echo  [√] Node.js 已安装

:: ── Step 1: Install Claude Code ──
echo.
echo [2/6] 安装 Claude Code...
call npm install -g @anthropic-ai/claude-code 2>nul
if %errorlevel% neq 0 (
    echo  [X] Claude Code 安装失败，请检查网络后重试
    pause
    exit /b 1
)
echo  [√] Claude Code 已安装

:: ── Step 2: Configure DeepSeek ──
echo.
echo [3/6] 配置 DeepSeek 模型...
echo.
echo  需要 DeepSeek API Key（注册送额度，每次调用几分钱）。
echo.
set /p HAS_KEY="  已经有 API Key 了？(y/n，默认 n): "
if /i "%HAS_KEY%"=="y" goto :paste_key

:: 没有 Key → 自动打开注册页
echo.
echo  正在打开 DeepSeek 注册页面...
echo  注册后在左侧 "API Keys" 创建 Key，复制粘贴回来。
start "" "https://platform.deepseek.com"
echo.
echo  ┌─────────────────────────────────────────┐
echo  │  注册步骤:                              │
echo  │  1. 浏览器中注册/登录 DeepSeek         │
echo  │  2. 点左侧 "API Keys"                  │
echo  │  3. 点 "创建 API Key"                  │
echo  │  4. 复制 key (sk-开头)                 │
echo  │  5. 回到这里粘贴                       │
echo  └─────────────────────────────────────────┘
echo.

:paste_key
set /p DEEPSEEK_KEY="  请粘贴你的 DeepSeek API Key (sk-开头，回车跳过): "

if "%DEEPSEEK_KEY%"=="" (
    echo.
    echo  [X] 未输入 Key，跳过模型配置。
    echo  之后可以手动编辑 ~/.claude/settings.json 添加。
) else (
    echo.
    echo  正在写入配置...

    set SETTINGS_DIR=%USERPROFILE%\.claude
    if not exist "%SETTINGS_DIR%" mkdir "%SETTINGS_DIR%"

    :: Generate settings.json with user's API key
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
    echo   },
    echo   "permissions": {
    echo     "allow": [
    echo       "Bash(npm *)",
    echo       "Bash(pip *)",
    echo       "Bash(curl *)",
    echo       "Bash(node *)",
    echo       "WebSearch",
    echo       "WebFetch(*)",
    echo       "Skill(*)"
    echo     ]
    echo   }
    echo }
    ) > "%SETTINGS_DIR%\settings.json"

    echo  [√] DeepSeek 配置完成
)

:: ── Step 4: Install skills ──
echo.
echo [4/6] 安装技能包...

set SKILLS_DIR=%USERPROFILE%\.claude\skills

:: browser-control
if not exist "%SKILLS_DIR%\browser-control" mkdir "%SKILLS_DIR%\browser-control"
curl -fsSL "https://raw.githubusercontent.com/shimenghan6/browser-control/master/SKILL.md" -o "%SKILLS_DIR%\browser-control\SKILL.md" 2>nul
if %errorlevel% equ 0 (echo  [√] browser-control) else (echo  [-] browser-control 下载失败，跳过)

:: github-research
if not exist "%SKILLS_DIR%\github-research" mkdir "%SKILLS_DIR%\github-research"
curl -fsSL "https://raw.githubusercontent.com/shimenghan6/github-research/master/SKILL.md" -o "%SKILLS_DIR%\github-research\SKILL.md" 2>nul
if %errorlevel% equ 0 (echo  [√] github-research) else (echo  [-] github-research 下载失败，跳过)

:: claude-code-sound-notifier
if not exist "%SKILLS_DIR%\claude-code-sound-notifier" mkdir "%SKILLS_DIR%\claude-code-sound-notifier"
curl -fsSL "https://raw.githubusercontent.com/shimenghan6/claude-code-sound-notifier/master/install.ps1" -o "%SKILLS_DIR%\claude-code-sound-notifier\install.ps1" 2>nul
if %errorlevel% equ 0 (
    echo  [√] claude-code-sound-notifier
) else (
    echo  [-] claude-code-sound-notifier 下载失败，跳过
)

:: ── Step 5: WeChat (optional) ──
echo.
echo [5/6] 微信接入...
echo.
echo  想要在微信里远程操控 Claude Code 吗？
echo  需要: iPhone + 微信最新版
echo.
set /p WECHAT="  接入微信? (y/n，默认 n): "
if /i "%WECHAT%"=="y" (
    echo.
    echo  正在安装微信接入组件...

    :: Install wechat deps
    call npm install -g claude-code-wechat-channel @weixin-claw/core 2>nul

    :: Download bridge + processor
    curl -fsSL "https://raw.githubusercontent.com/shimenghan6/claude-code-wechat/master/wechat-bridge.mjs" -o "%USERPROFILE%\.claude\wechat-bridge.mjs" 2>nul
    curl -fsSL "https://raw.githubusercontent.com/shimenghan6/claude-code-wechat/master/media-processor.py" -o "%USERPROFILE%\.claude\media-processor.py" 2>nul

    :: Create MCP config
    (
    echo {
    echo   "mcpServers": {
    echo     "wechat": {
    echo       "command": "npx",
    echo       "args": ["-y", "claude-code-wechat-channel", "start"]
    echo     }
    echo   }
    echo }
    ) > "%USERPROFILE%\.mcp.json"

    echo.
    echo  [√] 微信组件安装完成
    echo.
    echo  下一步：扫码连接微信
    echo    curl -s https://ilinkai.weixin.qq.com/ilink/bot/get_bot_qrcode?bot_type=3
    echo   手机打开链接授权 → 保存凭证到 ~/.claude/channels/wechat/account.json
    echo   启动桥接: node ~/.claude/wechat-bridge.mjs
    echo.
    echo  详细教程: https://github.com/shimenghan6/claude-code-wechat
) else (
    echo  跳过微信接入（之后可以随时安装: https://github.com/shimenghan6/claude-code-wechat）
)

:: ── Step 6: Done ──
echo.
echo [6/6] 完成！
echo.
echo  ╔══════════════════════════════════════════╗
echo  ║         安装完成！                      ║
echo  ║                                        ║
echo  ║  打开新终端，输入: claude               ║
echo  ║                                        ║
echo  ║  可以跟 Claude 说:                      ║
echo  ║    "帮我写一个 xxx"                     ║
echo  ║    "搜一下 xxx"                         ║
echo  ║    "查一下 GitHub 上的 xxx 项目"        ║
echo  ╚══════════════════════════════════════════╝
echo.
pause
