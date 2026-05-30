# Generate 3 offline packages based on pricing tiers
# Output: Desktop/cc文档生成/

$DESKTOP = [Environment]::GetFolderPath("Desktop")
$OUTDIR = "$DESKTOP\cc文档生成"
New-Item -ItemType Directory -Path $OUTDIR -Force | Out-Null

$CLAUDE = "$env:USERPROFILE\.claude"
$REPO = "$env:USERPROFILE\github-repos\claude-code-starter"
$TEMP = "$env:TEMP\claude-package"

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  生成 3 个离线安装包" -ForegroundColor Cyan
Write-Host "  输出: $OUTDIR" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan

# Function to create a package
function Create-Package {
    param($name, $desc, $skills, $wechat, $filename)

    $staging = "$TEMP\$name"
    if (Test-Path $staging) { Remove-Item $staging -Recurse -Force }
    New-Item -ItemType Directory -Path $staging -Force | Out-Null

    # Copy core installer
    Copy-Item "$REPO\offline\install-offline.bat" "$staging\双击安装.bat"

    # Copy settings template
    Copy-Item "$REPO\settings.template.json" "$staging\settings-template.json"

    # Copy selected skills
    $skillDest = "$staging\skills"
    New-Item -ItemType Directory -Path $skillDest -Force | Out-Null
    foreach ($skill in $skills) {
        $skillDir = "$skillDest\$skill"
        New-Item -ItemType Directory -Path $skillDir -Force | Out-Null
        $src = "$CLAUDE\skills\$skill\SKILL.md"
        if (Test-Path $src) { Copy-Item $src $skillDir }
    }

    # Copy WeChat module if premium
    if ($wechat) {
        $w = "$staging\wechat"
        New-Item -ItemType Directory -Path $w -Force | Out-Null
        foreach ($f in @('wechat-bridge.mjs','media-processor.py','cloud_vision.py')) {
            $p = "$CLAUDE\$f"
            if (Test-Path $p) { Copy-Item $p $w }
        }
    }

    # Create README for this tier
    $price = if ($desc -match "基础") {"88"} elseif ($desc -match "进阶") {"168"} else {"298"}
    $extra = if ($wechat) {"+ 微信远程接入 + 图片语音视频识别"} else {""}
    $lines = @(
        "$name $desc",
        "",
        "【装了什么】",
        ($skills -join ", ") + " " + $extra,
        "",
        "【怎么用】",
        '解压后双击 "双击安装.bat" 即可',
        "",
        "【开源地址】",
        "https://github.com/shimenghan6/claude-code-starter",
        "",
        "【远程安装】",
        "$price 元，加微信远程帮你装",
        "ToDesk 远程连接，3分钟搞定"
    )
    $lines -join "`r`n" | Out-File "$staging\说明.txt" -Encoding UTF8

    # Create ZIP
    $output = "$OUTDIR\$filename"
    Compress-Archive -Path "$staging\*" -DestinationPath $output -Force
    Write-Host "  [OK] $filename" -ForegroundColor Green
}

# Clean temp
if (Test-Path $TEMP) { Remove-Item $TEMP -Recurse -Force }

# Package 1: Basic (88)
Create-Package "基础版" "基础版" @("browser-control","github-research","sound-notifier") $false "基础版-88元-ClaudeCode安装包.zip"

# Package 2: Advanced (168)
Create-Package "进阶版" "进阶版 · 最推荐" @("browser-control","github-research","sound-notifier") $false "进阶版-168元-ClaudeCode全skill安装包.zip"

# Package 3: Premium (298)
Create-Package "尊享版" "尊享版 · 含微信" @("browser-control","github-research","sound-notifier") $true "尊享版-298元-含微信安装包.zip"

# Cleanup
if (Test-Path $TEMP) { Remove-Item $TEMP -Recurse -Force }

Write-Host ""
Write-Host "============================================" -ForegroundColor Green
Write-Host "  3 个安装包已生成到桌面 cc文档生成 文件夹" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Green
Get-ChildItem $OUTDIR -Filter "*.zip" | ForEach-Object {
    Write-Host "  $($_.Name) ($([math]::Round($_.Length/1KB,1)) KB)" -ForegroundColor White
}
