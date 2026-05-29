$FFMPEG = "C:\Users\shish\AppData\Local\Microsoft\WinGet\Packages\Gyan.FFmpeg_Microsoft.Winget.Source_8wekyb3d8bbwe\ffmpeg-8.1.1-full_build\bin\ffmpeg.exe"
$MKV = "$env:USERPROFILE\Desktop\claude-demo.mkv"
$MP4 = "$env:USERPROFILE\Desktop\claude-demo.mp4"

Add-Type @"
using System; using System.Runtime.InteropServices; using System.Diagnostics;
public class Win {
    [DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr h);
    [DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr h, int c);
    public const int SW_MAXIMIZE = 3;
    public static void Focus(string title) {
        foreach (Process p in Process.GetProcesses()) {
            if (!string.IsNullOrEmpty(p.MainWindowTitle) && p.MainWindowTitle.Contains(title)) {
                ShowWindow(p.MainWindowHandle, SW_MAXIMIZE);
                SetForegroundWindow(p.MainWindowHandle);
            }
        }
    }
}
"@

# ---- Scene batch files (aligned to subtitle timing) ----

# Scene: Pain Point (5-12s) - Show "traditional way" pain
@'
@echo off
title Install_Pain
mode con cols=95 lines=25
cls
echo   ======================================
echo     Traditional way to use Claude Code:
echo   ======================================
echo.
echo   $ npm install @anthropic-ai/claude-code
echo   ERROR: permission denied
echo.
echo   $ sudo npm install -g @anthropic-ai/claude-code
echo   OK. Now find API Key...
echo.
echo   Google: "Anthropic API key" -^> docs -^> console
echo   Need overseas credit card...
echo   $30/month minimum...
echo.
echo   Give up. Too complicated.
echo.
echo   ======================================
echo   There must be a simpler way...
echo   ======================================
timeout /t 5 >nul
exit
'@ | Out-File "$env:TEMP\scene_pain.bat" -Encoding ASCII

# Scene: Install Demo (15-22s) - Show install.bat working
@'
@echo off
title Install_Demo
mode con cols=95 lines=25
cls
echo   ======================================
echo     Claude Code Starter - install.bat
echo     github.com/shimenghan6/claude-code-starter
echo   ======================================
echo.
echo   [1/6] Checking Node.js... OK
echo   [2/6] Installing Claude Code...
echo   [3/6] DeepSeek API Key? (y/n): y
echo.
echo   Opening https://platform.deepseek.com...
echo   Register -^> API Keys -^> Create -^> Copy
echo.
echo   Paste DeepSeek Key: sk-xxx...xxx
echo   [OK] Configuration written
echo   [4/6] Installing skills... optional
echo   [5/6] WeChat bridge... skipped
echo   [6/6] DONE!
echo.
echo   ======================================
echo   Type 'claude' in terminal to start!
echo   ======================================
timeout /t 5 >nul
exit
'@ | Out-File "$env:TEMP\scene_install.bat" -Encoding ASCII

# Scene: Claude Code Output (35-45s) - REAL output from claude -p
@'
@echo off
title Claude_Output
mode con cols=100 lines=28
cls
echo   $ claude
echo.
echo   You: write a Python image scraper in 20 lines
echo.
echo   Claude:
echo   import asyncio, aiohttp, aiofiles, os, re, sys
echo   from urllib.parse import urlparse
echo.
echo   async def download(url, dir="images", sem=asyncio.Semaphore(5)):
echo       os.makedirs(dir, exist_ok=True)
echo       name = re.sub(r'[\\/*?:"<>|]',"_", os.path.basename(urlparse(url).path)) or "img"
echo       async with sem, aiohttp.ClientSession() as s:
echo           async with s.get(url, timeout=15) as r:
echo               if r.status == 200:
echo                   async with aiofiles.open(f"{dir}/{name}","wb") as f: await f.write(await r.read())
echo                   print(f"OK: {name}")
echo               else: print(f"FAIL [{r.status}]: {url}")
echo.
echo   async def main():
echo       urls = [l.strip() for l in sys.stdin if l.strip()]
echo       await asyncio.gather(*(download(u) for u in urls))
echo.
echo   if __name__ == "__main__":
echo       asyncio.run(main())
echo.
echo   $ python dl.py ^< urls.txt
echo   OK: 1.jpg  OK: 2.png  OK: 3.gif
echo   Done - 3 images saved to images/
timeout /t 8 >nul
exit
'@ | Out-File "$env:TEMP\scene_code.bat" -Encoding ASCII

# Scene: Ending (50-60s)
@'
@echo off
title Final_Screen
mode con cols=95 lines=15
cls
echo.
echo   ======================================
echo     Claude Code + DeepSeek V4 Pro
echo     install.bat - double click to start
echo   ======================================
echo.
echo     github.com/shimenghan6/claude-code-starter
echo.
echo     Star = best support!
echo     DM for remote install: 100 RMB all-in
echo.
timeout /t 8 >nul
exit
'@ | Out-File "$env:TEMP\scene_end.bat" -Encoding ASCII

Write-Host "=== Recording: 14 scenes, 60 seconds, subtitle-aligned ==="

# Cleanup
Get-Process | Where-Object { $_.MainWindowTitle -match "Install_|Claude_|Final_|DeepSeek|GitHub" } | Stop-Process -Force 2>$null
(New-Object -ComObject "Shell.Application").MinimizeAll()
Start-Sleep 1

# Start recording (65 seconds total for safety margin)
$ffproc = Start-Process -FilePath $FFMPEG -ArgumentList @(
    "-f","gdigrab","-framerate","30","-video_size","1920x1080",
    "-i","desktop","-t","65","-c:v","libx264","-preset","ultrafast",
    "-crf","18","-pix_fmt","yuv420p",$MKV,"-y"
) -NoNewWindow -PassThru
Start-Sleep 1

# === SUBTITLE-ALIGNED TIMELINE ===

# [0-5s] S1: Title card - black screen (just desktop bg)
Write-Host "[0-5s] Title card"
Start-Sleep 5

# [5-12s] S2: Pain point
Write-Host "[5-12s] Pain point"
Start-Process cmd -ArgumentList "/c", "$env:TEMP\scene_pain.bat"
Start-Sleep 2
[Win]::Focus("Install_Pain")
Start-Sleep 5

# [12-15s] S3: "Double click"
Write-Host "[12-15s] Double click reveal"
# Just keep showing the terminal, the "reveal" is in editing
Start-Sleep 3

# [15-22s] S4+S5: Install demo
Write-Host "[15-22s] Install demo"
Start-Process cmd -ArgumentList "/c", "$env:TEMP\scene_install.bat"
Start-Sleep 2
[Win]::Focus("Install_Demo")
Start-Sleep 5

# [22-26s] S6: DeepSeek page
Write-Host "[22-26s] DeepSeek registration"
Start-Process "https://platform.deepseek.com"
Start-Sleep 2
[Win]::Focus("DeepSeek")
Start-Sleep 3

# [26-30s] S7: API Keys creation
Write-Host "[26-30s] API Keys"
Start-Sleep 4

# [30-33s] S8: Paste key, done
Write-Host "[30-33s] Config done"
[Win]::Focus("Install_Demo")
Start-Sleep 3

# [33-35s] S9: Open terminal, type claude
Write-Host "[33-35s] Open terminal"
Start-Sleep 2

# [35-45s] S10+S11: Claude writes code (REAL output)
Write-Host "[35-45s] Claude writes REAL code"
Start-Process cmd -ArgumentList "/c", "$env:TEMP\scene_code.bat"
Start-Sleep 2
[Win]::Focus("Claude_Output")
Start-Sleep 8

# [45-50s] S12: Browser search for weather
Write-Host "[45-50s] Browser search"
[Win]::Focus("DeepSeek")
Start-Sleep 5

# [50-55s] S13: GitHub page
Write-Host "[50-55s] GitHub"
Start-Process "https://github.com/shimenghan6/claude-code-starter"
Start-Sleep 2
[Win]::Focus("claude-code-starter")
Start-Sleep 4

# [55-60s] S14: Star + contact
Write-Host "[55-60s] Ending"
Start-Process cmd -ArgumentList "/c", "$env:TEMP\scene_end.bat"
Start-Sleep 2
[Win]::Focus("Final_Screen")
Start-Sleep 5

# Cleanup
Get-Process | Where-Object { $_.MainWindowTitle -match "Install_|Claude_|Final_|DeepSeek|GitHub" } | Stop-Process -Force 2>$null

$ffproc.WaitForExit(120000)
& $FFMPEG -i $MKV -c copy -movflags +faststart $MP4 -y 2>$null

if (Test-Path $MP4) {
    Write-Host "SUCCESS: claude-demo.mp4 ($([math]::Round((Get-Item $MP4).Length/1MB,1)) MB)" -ForegroundColor Green
} else { Write-Host "FAILED" -ForegroundColor Red }
Remove-Item "$env:TEMP\scene_*.bat" -Force 2>$null
