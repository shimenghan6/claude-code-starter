---
name: claude-code-sound-notifier
description: |
  给 Claude Code 加提示音：任务完成 + 权限审批都有声音提醒。Windows/macOS/Linux 三平台支持。
  触发条件："加提示音", "声音提醒", "任务完成通知", "sound notifier",
  "加个叮咚", "权限提示音", "装个声音提示"
---

# Claude Code Sound Notifier

任务完成叮咚，需要审批也叮咚。不再死盯屏幕。

## 一键安装

### Windows
```powershell
powershell -ExecutionPolicy Bypass -File install.ps1
```

### macOS / Linux
```bash
bash install.sh
```

## 效果

| 触发 | Hook | 声音 |
|------|------|------|
| 需要授权 | `PermissionRequest` | 通知音 |
| 任务完成 | `Stop` | 完成音 |

## 5 个踩坑

1. **VSCode 中 Notification hook 不触发** → 改用 PermissionRequest
2. **System.Console.Beep 不响** → 用 Media.SoundPlayer 播放 WAV
3. **SystemSounds 被系统静音** → 直接播放 WAV 文件
4. **改 settings.json 不生效** → 必须开新对话/重启
5. **Play() 异步可能被跳过** → 用 PlaySync()
