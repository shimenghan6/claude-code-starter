@echo off
chcp 65001 >nul
title B站演示视频 - 一键录屏

set FFMPEG=C:\Users\shish\AppData\Local\Microsoft\WinGet\Packages\Gyan.FFmpeg_Microsoft.Winget.Source_8wekyb3d8bbwe\ffmpeg-8.1.1-full_build\bin\ffmpeg.exe
set OUTPUT=%USERPROFILE%\Desktop\claude-demo.mp4

cls
echo.
echo   ╔══════════════════════════════════════════╗
echo   ║     B站 演示视频 - 一键录屏             ║
echo   ║     3分钟拥有 AI 编程助手               ║
echo   ╚══════════════════════════════════════════╝
echo.
echo   保存到: %OUTPUT%
echo   时长: 70秒 | 1080p 30fps
echo.
echo   录屏开始后, 请按以下步骤操作:
echo.
echo   ┌─ 0-10秒 ────────────────────────────┐
echo   │ 打开终端 → 输入 claude → 展示界面    │
echo   ├─ 10-20秒 ───────────────────────────┤
echo   │ 展示 DeepSeek 注册页 (浏览器已打开)  │
echo   ├─ 20-45秒 ───────────────────────────┤
echo   │ 输入: 帮我写一个Python爬虫            │
echo   │ Claude 开始输出代码                   │
echo   ├─ 45-60秒 ───────────────────────────┤
echo   │ 输入: 搜一下杭州天气                  │
echo   │ 浏览器自动搜索                        │
echo   ├─ 60-70秒 ───────────────────────────┤
echo   │ 展示 GitHub 页面 + Star 按钮          │
echo   └──────────────────────────────────────┘
echo.
echo   按任意键开始录屏...
pause >nul

cls
echo.
echo   ● 录屏中... 70 秒
echo.
echo   请按上述步骤操作!
echo.

:: 录屏 70 秒
"%FFMPEG%" -f gdigrab -framerate 30 -video_size 1920x1080 -i desktop -t 70 -c:v libx264 -preset ultrafast -crf 18 -pix_fmt yuv420p -movflags +faststart "%OUTPUT%" -y 2>nul

echo.
echo   ==========================================
echo   ● 录屏完成！
echo.
echo   文件位置: %OUTPUT%
echo.
echo   下一步:
echo   1. 打开剪映 → 导入此视频
echo   2. 拖入 promo\字幕.srt
echo   3. 文本朗读 → 粘贴 promo\配音文本.txt
echo   4. 导出 → 上传 B站
echo   ==========================================
echo.
pause
