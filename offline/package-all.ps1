# Generate 3 offline packages based on pricing tiers
# Output: Desktop/cc文档生成/

$DESKTOP = [Environment]::GetFolderPath("Desktop")
$OUTDIR = "$DESKTOP\cc文档生成"
New-Item -ItemType Directory -Path $OUTDIR -Force | Out-Null

$CLAUDE = "$env:USERPROFILE\.claude"
$REPO = "$env:USERPROFILE\github-repos\claude-code-starter"
$TEMP = "$env:TEMP\claude-package"

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  Generate 3 offline packages" -ForegroundColor Cyan
Write-Host "  Output: $OUTDIR" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan

function Create-Package {
    param($name, $desc, $skills, $wechat, $filename)

    $staging = "$TEMP\$name"
    if (Test-Path $staging) { Remove-Item $staging -Recurse -Force }
    New-Item -ItemType Directory -Path $staging -Force | Out-Null

    Copy-Item "$REPO\offline\install-offline.bat" "$staging\double-click-install.bat"
    Copy-Item "$REPO\settings.template.json" "$staging\settings-template.json"

    $skillDest = "$staging\skills"
    New-Item -ItemType Directory -Path $skillDest -Force | Out-Null
    foreach ($skill in $skills) {
        $skillDir = "$skillDest\$skill"
        New-Item -ItemType Directory -Path $skillDir -Force | Out-Null
        $actualSkill = if ($skill -eq "sound-notifier") { "claude-code-sound-notifier" } else { $skill }
        $src = "$CLAUDE\skills\$actualSkill\SKILL.md"
        if (Test-Path $src) {
            Copy-Item $src $skillDir
            Write-Host "    [OK] $skill" -ForegroundColor Gray
        } else {
            Write-Host "    [WARN] $skill SKILL.md not found at $src" -ForegroundColor Yellow
        }
    }

    if ($wechat) {
        $w = "$staging\wechat"
        New-Item -ItemType Directory -Path $w -Force | Out-Null
        $wechatFiles = @('wechat-bridge.mjs','media-processor.py','cloud_vision.py')
        foreach ($f in $wechatFiles) {
            $p = "$CLAUDE\$f"
            if (Test-Path $p) { Copy-Item $p $w }
        }
    }

    $price = "298"
    if ($desc -match "Basic") { $price = "88" }
    elseif ($desc -match "Advanced") { $price = "168" }
    $extraText = if ($wechat) { " + WeChat remote + image/voice/video recognition" } else { "" }
    $skillText = ($skills -join ", ") + $extraText

    $readmeContent = @"
$name $desc

[What's included]
$skillText

[How to use]
Unzip and double-click "double-click-install.bat"

[Open Source]
https://github.com/shimenghan6/claude-code-starter

[Remote Installation]
$price RMB, WeChat remote assistance
ToDesk remote, 3 minutes setup
"@
    $readmeContent | Out-File "$staging\readme.txt" -Encoding UTF8

    $output = "$OUTDIR\$filename"
    Compress-Archive -Path "$staging\*" -DestinationPath $output -Force
    Write-Host "  [OK] $filename" -ForegroundColor Green
}

if (Test-Path $TEMP) { Remove-Item $TEMP -Recurse -Force }

# Package 1: Basic (88) - 2 core skills
Create-Package "Basic" "Basic Edition" @("browser-control","github-research") $false "Basic-88-ClaudeCode.zip"

# Package 2: Advanced (168) - 4 skills
Create-Package "Advanced" "Advanced Edition - Best Value" @("browser-control","github-research","sound-notifier","github-publisher") $false "Advanced-168-ClaudeCode-AllSkills.zip"

# Package 3: Premium (298) - 4 skills + WeChat
Create-Package "Premium" "Premium Edition - with WeChat" @("browser-control","github-research","sound-notifier","github-publisher") $true "Premium-298-WithWeChat.zip"

if (Test-Path $TEMP) { Remove-Item $TEMP -Recurse -Force }

Write-Host ""
Write-Host "============================================" -ForegroundColor Green
Write-Host "  3 packages generated in Desktop/cc文档生成" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Green
Get-ChildItem $OUTDIR -Filter "*.zip" | ForEach-Object {
    Write-Host "  $($_.Name) ($([math]::Round($_.Length/1KB,1)) KB)" -ForegroundColor White
}
