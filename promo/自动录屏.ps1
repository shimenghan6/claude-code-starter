# Claude Code Starter - 自动演示录屏
# 用法: 右键 → 使用 PowerShell 运行

$FFMPEG = "C:\Users\shish\AppData\Local\Microsoft\WinGet\Packages\Gyan.FFmpeg_Microsoft.Winget.Source_8wekyb3d8bbwe\ffmpeg-8.1.1-full_build\bin\ffmpeg.exe"
$OUTPUT = "$env:USERPROFILE\Desktop\claude-demo.mp4"
$DESKTOP = [Environment]::GetFolderPath("Desktop")

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  B站演示视频 - 自动录屏" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "录屏即将开始，请确保："
Write-Host " 1. 桌面整洁（关闭无关窗口）"
Write-Host " 2. 浏览器已安装 Chrome/Edge"
Write-Host " 3. Claude Code 已配置好"
Write-Host ""
Write-Host "按 Enter 开始录屏..." -ForegroundColor Green
Read-Host

# Minimize all windows
$shell = New-Object -ComObject "Shell.Application"
$shell.MinimizeAll()

Start-Sleep -Seconds 1

# Start FFmpeg recording in background
Write-Host "● 录屏开始！70 秒倒计时..." -ForegroundColor Green
$ffmpegJob = Start-Job -ScriptBlock {
    param($ffmpeg, $output)
    & $ffmpeg -f gdigrab -framerate 30 -video_size 1920x1080 -i desktop -t 70 `
        -c:v libx264 -preset ultrafast -crf 18 -pix_fmt yuv420p `
        -movflags +faststart $output -y 2>$null
} -ArgumentList $FFMPEG, $OUTPUT

# ── Scene 1: Open terminal & show Claude Code ──
Write-Host "  [0-15s] 场景1: 终端 & Claude Code"
Start-Process "cmd" -ArgumentList "/k cd /d C:\Users\shish && title AI编程助手 && cls && echo. && echo   Claude Code + DeepSeek V4 && echo   模型: deepseek-v4-pro && echo   上下文: 1,000,000 token && echo. && echo   ^> claude && echo   ^> 帮我写一个Python爬虫 && echo. && timeout /t 12 >nul && claude -p '用20行Python写一个网页标题爬虫' 2>&1 && echo. && echo   === 演示完成 === && echo   github.com/shimenghan6/claude-code-starter && pause"

Start-Sleep -Seconds 15

# ── Scene 2: Show DeepSeek registration ──
Write-Host "  [15-25s] 场景2: DeepSeek 注册页"
Start-Process "https://platform.deepseek.com"
Start-Sleep -Seconds 10

# ── Scene 3: Back to terminal - show more output ──
Write-Host "  [25-45s] 场景3: Claude 写代码"
Start-Sleep -Seconds 20

# ── Scene 4: Show GitHub repo ──
Write-Host "  [45-60s] 场景4: GitHub 项目页"
Start-Process "https://github.com/shimenghan6/claude-code-starter"
Start-Sleep -Seconds 15

# ── Scene 5: Final card ──
Write-Host "  [60-70s] 结尾"
Start-Sleep -Seconds 10

# Wait for recording to finish
Wait-Job $ffmpegJob | Out-Null
Receive-Job $ffmpegJob | Out-Null

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "  ● 录屏完成！" -ForegroundColor Green
Write-Host "  文件: $OUTPUT" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "下一步: 打开剪映 → 导入视频 → 拖入 字幕.srt → AI 朗读 → 导出" -ForegroundColor Yellow

# Open the output folder
Invoke-Item (Split-Path $OUTPUT)
