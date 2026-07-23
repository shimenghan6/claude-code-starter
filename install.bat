@echo off
setlocal enabledelayedexpansion
chcp 65001 >nul 2>&1
title Claude Code 一键安装

echo.
echo   ========================================
echo       Claude Code 一键安装
echo       VS Code + DeepSeek + 4 个 Skill
echo   ========================================
echo.
echo   Skill 已打包在本地，无需 GitHub。
echo   需要网络：下载 Claude Code 和 npm 依赖。
echo.

:: 跟踪各组件安装状态
set OK_VSCODE=0
set OK_NODE=0
set OK_CLAUDE=0
set OK_DEEPSEEK=0
set OK_SKILLS=0
set OK_WECHAT=0
set SKILL_COUNT=0

:: ============================================================
:: 步骤 0：VS Code
:: ============================================================
echo [0/6] 检测 VS Code...
where code >nul 2>&1
if !errorlevel! neq 0 (
    echo   正在用 winget 安装 VS Code...
    call winget install Microsoft.VisualStudioCode --accept-package-agreements 2>nul
    if !errorlevel! equ 0 (
        echo   [完成] VS Code 已安装
        set OK_VSCODE=1
    ) else (
        echo   [重试] winget 失败，尝试直接下载...
        powershell -NoProfile -Command "Invoke-WebRequest -Uri 'https://code.visualstudio.com/sha/download?build=stable&os=win32-x64-user' -OutFile '%TEMP%\VSCodeSetup.exe'"
        if exist "%TEMP%\VSCodeSetup.exe" (
            start /wait "" "%TEMP%\VSCodeSetup.exe" /norestart
            del "%TEMP%\VSCodeSetup.exe" 2>nul
            echo   [完成] VS Code 已安装
            set OK_VSCODE=1
        ) else (
            echo   [警告] 自动安装失败，请手动安装：https://code.visualstudio.com
        )
    )
) else (
    echo   [完成] VS Code 已安装
    set OK_VSCODE=1
)

:: VS Code 扩展
where code >nul 2>&1
if !errorlevel! equ 0 (
    call code --install-extension anthropic.claude-code >nul 2>&1
    echo   [完成] Claude Code 扩展
)

echo.

:: ============================================================
:: 步骤 1：Node.js
:: ============================================================
echo [1/6] 检测 Node.js...
where node >nul 2>&1
if !errorlevel! neq 0 (
    echo   未找到 Node.js，正在用 winget 安装...
    call winget install OpenJS.NodeJS.LTS --accept-package-agreements 2>nul
    if !errorlevel! equ 0 (
        echo   [完成] Node.js LTS 已安装
        set "PATH=%PATH%;%ProgramFiles%\nodejs;%AppData%\npm"
    ) else (
        echo   [重试] winget 失败，尝试直接下载...
        powershell -NoProfile -Command "Invoke-WebRequest -Uri 'https://nodejs.org/dist/v22.14.0/node-v22.14.0-x64.msi' -OutFile '%TEMP%\nodejs.msi'"
        if exist "%TEMP%\nodejs.msi" (
            start /wait msiexec /i "%TEMP%\nodejs.msi" /norestart
            del "%TEMP%\nodejs.msi" 2>nul
            set "PATH=%PATH%;%ProgramFiles%\nodejs;%AppData%\npm"
            echo   [完成] Node.js 已安装
        ) else (
            echo   [警告] 无法自动安装 Node.js
            echo   [警告] 请手动下载：https://nodejs.org
            echo   [警告] Skill 会继续安装，但 Claude Code 需要 Node.js
        )
    )
)

:: 验证 node（新装后PATH未刷新自动搜索常见路径）
set NODE_FOUND=0
where node >nul 2>&1 && set NODE_FOUND=1
if !NODE_FOUND!==0 (
    for %%d in ("%ProgramFiles%\nodejs" "%LOCALAPPDATA%\Programs\nodejs" "%SystemDrive%\Program Files\nodejs") do (
        if exist "%%~d\node.exe" (
            set "PATH=!PATH!;%%~d"
            set NODE_FOUND=1
        )
    )
)
if !NODE_FOUND! equ 1 (
    for /f "tokens=*" %%i in ('node -v') do set NODE_VER=%%i
    echo   [完成] Node.js !NODE_VER!
    for /f "tokens=*" %%i in ('npm -v') do set NPM_VER=%%i
    echo   [完成] npm v!NPM_VER!
    set OK_NODE=1
) else (
    echo   [提示] Node.js 不可用，请重启终端后重试
    echo         常见路径：%ProgramFiles%\nodejs
)

echo.

:: ============================================================
:: 步骤 2：Claude Code（需要 Node.js）
:: ============================================================
echo [2/6] 安装 Claude Code...
if !OK_NODE! equ 1 (
    echo   正在用 npm 安装 v2.1.160（锁定版本，兼容 DeepSeek），需要联网，约 1-2 分钟...
    call npm install -g @anthropic-ai/claude-code@2.1.160 >nul 2>&1
    if !errorlevel! neq 0 (
        echo   [重试] 首次失败，换 --force 重试...
        call npm install -g @anthropic-ai/claude-code@2.1.160 --force >nul 2>&1
    )
    where claude >nul 2>&1
    if !errorlevel! equ 0 (
        for /f "tokens=*" %%i in ('claude --version 2^>^&1') do set CLAUDE_VER=%%i
        echo   [完成] Claude Code !CLAUDE_VER!
        set OK_CLAUDE=1
    ) else (
        echo   [警告] claude 不在 PATH 中，请重启终端后重试
        echo         npm 全局目录：
        call npm root -g
    )
) else (
    echo   [跳过] Node.js 未安装，请先装 Node.js 再重试
)

echo.

:: ============================================================
:: 步骤 3：DeepSeek API Key
:: ============================================================
echo [3/6] 配置 DeepSeek API Key...
echo.

if exist "%USERPROFILE%\.claude\settings.json" (
    echo   已有 settings.json，保留不动
    set OK_DEEPSEEK=1
    goto :skip_deepseek
)

echo   DeepSeek 新用户有免费额度。
echo   注册地址: platform.deepseek.com
echo   注册后进入 API Keys 页面，创建 Key，复制 sk- 开头的密钥
echo.

set DEEPSEEK_KEY=
set /p DEEPSEEK_KEY="   在此粘贴 API Key（sk-xxx，回车跳过）："
if "!DEEPSEEK_KEY!"=="" (
    echo   [跳过] 之后可手动创建 %%USERPROFILE%%\.claude\settings.json
) else (
    if not exist "%USERPROFILE%\.claude" mkdir "%USERPROFILE%\.claude"
    (
    echo {
    echo   "env": {
    echo     "ANTHROPIC_BASE_URL": "https://api.deepseek.com/anthropic",
    echo     "ANTHROPIC_AUTH_TOKEN": "!DEEPSEEK_KEY!",
    echo     "ANTHROPIC_MODEL": "deepseek-v4-pro[1m]",
    echo     "ANTHROPIC_DEFAULT_OPUS_MODEL": "deepseek-v4-pro[1m]",
    echo     "ANTHROPIC_DEFAULT_SONNET_MODEL": "deepseek-v4-pro[1m]",
    echo     "ANTHROPIC_DEFAULT_HAIKU_MODEL": "deepseek-v4-flash[1m]",
    echo     "CLAUDE_CODE_EFFORT_LEVEL": "max",
    echo     "CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC": "1",
    echo     "API_TIMEOUT_MS": "600000"
    echo   }
    echo }
    ) > "%USERPROFILE%\.claude\settings.json"
    echo   [完成] 配置已写入
    set OK_DEEPSEEK=1
)

:skip_deepseek
echo.

:: ============================================================
:: 步骤 4：Skill（本地复制，无需联网）
:: ============================================================
echo [4/6] 安装 Skill（本地文件，秒装）...
set "SKILLS_DIR=%USERPROFILE%\.claude\skills"

if exist "%~dp0skills\browser-control\SKILL.md" (
    mkdir "!SKILLS_DIR!\browser-control" 2>nul
    copy /y "%~dp0skills\browser-control\SKILL.md" "!SKILLS_DIR!\browser-control\SKILL.md" >nul
    echo   [完成] browser-control — 浏览器操控
    set /a SKILL_COUNT+=1
) else (echo   [-]  browser-control 不在此套餐中)

if exist "%~dp0skills\github-research\SKILL.md" (
    mkdir "!SKILLS_DIR!\github-research" 2>nul
    copy /y "%~dp0skills\github-research\SKILL.md" "!SKILLS_DIR!\github-research\SKILL.md" >nul
    echo   [完成] github-research — GitHub 项目调研
    set /a SKILL_COUNT+=1
) else (echo   [-]  github-research 不在此套餐中)

if exist "%~dp0skills\sound-notifier\SKILL.md" (
    mkdir "!SKILLS_DIR!\claude-code-sound-notifier" 2>nul
    copy /y "%~dp0skills\sound-notifier\SKILL.md" "!SKILLS_DIR!\claude-code-sound-notifier\SKILL.md" >nul
    echo   [完成] sound-notifier — 任务完成提示音
    set /a SKILL_COUNT+=1
) else (echo   [-]  sound-notifier 不在此套餐中)

if exist "%~dp0skills\github-publisher\SKILL.md" (
    mkdir "!SKILLS_DIR!\github-publisher" 2>nul
    copy /y "%~dp0skills\github-publisher\SKILL.md" "!SKILLS_DIR!\github-publisher\SKILL.md" >nul
    echo   [完成] github-publisher — GitHub 发布管理
    set /a SKILL_COUNT+=1
) else (echo   [-]  github-publisher 不在此套餐中)

if !SKILL_COUNT! gtr 0 set OK_SKILLS=1

echo.

:: ============================================================
:: 步骤 5：微信桥接（可选）
:: ============================================================
echo [5/6] 微信远程控制（可选）...
if exist "%~dp0wechat\wechat-bridge.mjs" (
    set WECHAT=n
    set /p WECHAT="   是否安装微信桥接？(y/n，默认 n)："
    if /i "!WECHAT!"=="y" (
        copy /y "%~dp0wechat\wechat-bridge.mjs" "%USERPROFILE%\.claude\wechat-bridge.mjs" >nul
        if exist "%~dp0wechat\media-processor.py" copy /y "%~dp0wechat\media-processor.py" "%USERPROFILE%\.claude\media-processor.py" >nul 2>nul
        if exist "%~dp0wechat\cloud_vision.py" copy /y "%~dp0wechat\cloud_vision.py" "%USERPROFILE%\.claude\cloud_vision.py" >nul 2>nul
        echo   [完成] 微信文件已安装
        if !OK_NODE! equ 1 (
            echo   正在安装微信 npm 依赖...
            call npm install -g claude-code-wechat-channel @weixin-claw/core >nul 2>&1
        )
        set OK_WECHAT=1
    ) else (
        echo   [跳过]
    )
) else (
    echo   [-]  微信模块不在此套餐中
    echo        需要尊享版（298元）
)

echo.

:: ============================================================
:: 步骤 6：完成 + Skill 使用指南
:: ============================================================
echo [6/6] 安装完成！
echo.
echo   ========================================
echo     安装总结
echo   ========================================
echo     VS Code：     !OK_VSCODE! （1=已装 0=未装）
echo     Node.js：     !OK_NODE! （1=已装 0=未装）
echo     Claude Code： !OK_CLAUDE! （1=已装 0=未装）
echo     DeepSeek：    !OK_DEEPSEEK! （1=已配 0=跳过）
echo     Skill：       !SKILL_COUNT! 个已安装
echo     WeChat：      !OK_WECHAT! （1=已装 0=跳过）
echo   ========================================
echo.

:: ---- Skill 使用指南 ----
echo   ========================================
echo     Skill 使用方法
echo   ========================================
echo.
echo   启动 Claude Code 后（终端输入 claude），试说：
echo.

if exist "!SKILLS_DIR!\browser-control\SKILL.md" (
    echo   [browser-control] 浏览器操控
    echo     说："打开浏览器搜索 xxx"
    echo     说："打开百度搜龙珠"
    echo     说："给这个页面截个图"
    echo.
)
if exist "!SKILLS_DIR!\github-research\SKILL.md" (
    echo   [github-research] GitHub 项目调研
    echo     说："搜一下 GitHub 上的 xxx 工具"
    echo     说："对比一下 xxx 和 yyy"
    echo     说："帮我找最好的 Python OCR 库"
    echo.
)
if exist "!SKILLS_DIR!\claude-code-sound-notifier\SKILL.md" (
    echo   [sound-notifier] 任务完成提示音
    echo     Claude 干完活自动叮咚一声
    echo     说："打开声音提醒"
    echo.
)
if exist "!SKILLS_DIR!\github-publisher\SKILL.md" (
    echo   [github-publisher] GitHub 发布管理
    echo     说："把这个项目发布到 GitHub"
    echo     说："把我的 skill 推送到 GitHub"
    echo     自动创建仓库、README、一键安装脚本
    echo.
)
if "!OK_WECHAT!"=="1" (
    echo   [微信桥接] 微信远程控制 Claude Code
    echo     扫码绑定后，发微信消息就能遥控电脑
    echo     详见：https://github.com/shimenghan6/claude-code-wechat
    echo.
)

echo   ========================================
echo.
if !OK_NODE! equ 0 (
    echo   *** 重要：需要安装 Node.js！***
    echo   下载地址：https://nodejs.org （选 LTS 版本）
    echo   安装 Node.js 后，重新运行此脚本即可
    echo.
)
if !OK_CLAUDE! equ 0 (
    echo   *** Claude Code 尚未安装 ***
    echo   Node.js 就绪后重新运行此脚本
    echo   或手动执行：npm install -g @anthropic-ai/claude-code@2.1.160
    echo.
)
if !OK_DEEPSEEK! equ 0 (
    echo   *** DeepSeek API Key 未配置 ***
    echo   手动创建文件：%%USERPROFILE%%\.claude\settings.json
    echo   模板见同目录下的 settings.template.json
    echo.
)

echo   所有文件已安装到：%%USERPROFILE%%\.claude\
echo.

endlocal
pause
