# Claude Code Starter - 自动演示录屏
# Run: Right click → Run with PowerShell

$FFMPEG = "C:\Users\shish\AppData\Local\Microsoft\WinGet\Packages\Gyan.FFmpeg_Microsoft.Winget.Source_8wekyb3d8bbwe\ffmpeg-8.1.1-full_build\bin\ffmpeg.exe"
$OUTPUT = "$env:USERPROFILE\Desktop\claude-demo.mkv"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  B站演示视频 - 自动录屏 (70秒)" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "录屏即将开始，请关闭无关窗口" -ForegroundColor Yellow
Write-Host "按 Enter 开始..." -ForegroundColor Green
Read-Host

# Minimize all windows
(New-Object -ComObject "Shell.Application").MinimizeAll()
Start-Sleep 2

Write-Host "● 录屏中... 70秒" -ForegroundColor Green

# Start FFmpeg as a SEPARATE process (not a job - so it survives)
$proc = Start-Process -FilePath $FFMPEG -ArgumentList @(
    "-f", "gdigrab", "-framerate", "30", "-video_size", "1920x1080",
    "-i", "desktop", "-t", "70",
    "-c:v", "libx264", "-preset", "ultrafast", "-crf", "18",
    "-pix_fmt", "yuv420p", $OUTPUT, "-y"
) -NoNewWindow -PassThru

# Scene 1: Terminal with Claude
Start-Process cmd -ArgumentList "/c", "cd /d C:\Users\shish && title AI助手 && cls && echo. && echo Claude Code + DeepSeek V4 && echo github.com/shimenghan6/claude-code-starter && echo. && echo 演示: 帮我写爬虫 && echo. && timeout /t 50 >nul"
Start-Sleep 5

# Scene 2: DeepSeek registration page
Start-Process "https://platform.deepseek.com"
Start-Sleep 15

# Scene 3: GitHub repo
Start-Process "https://github.com/shimenghan6/claude-code-starter"
Start-Sleep 45

# Wait for FFmpeg to complete (70 second total)
$proc.WaitForExit(120000)
$exitCode = $proc.ExitCode

Write-Host ""
if ($exitCode -eq 0) {
    Write-Host "录屏完成！文件: $OUTPUT" -ForegroundColor Green
} else {
    Write-Host "录屏异常 exit=$exitCode" -ForegroundColor Red
}

Write-Host "下一步: 剪映导入 → 字幕.srt → AI朗读 → 导出" -ForegroundColor Yellow
Read-Host "按 Enter 退出"
