# Claude Code Starter

> 一行命令，装好 Claude Code + DeepSeek V4 + 常用技能栈。支持微信远程操控、浏览器自动化、GitHub 项目调研。

```
install.bat → 3 分钟 → 终端输入 claude → AI 编程助手就绪
              ├─ 模型: DeepSeek V4 Pro (1M context window)
              ├─ 协议: Anthropic Messages API 兼容
              ├─ 工具: Bash / Read / Write / Edit / WebSearch / WebFetch
              └─ 扩展: 微信桥接 / 浏览器操控 / OCR / Whisper / FFmpeg
```

---

## 技术栈

| 层级 | 组件 | 说明 |
|------|------|------|
| Runtime | Claude Code v2.1+ | Anthropic 官方 AI 编程 CLI |
| Model | DeepSeek V4 Pro | 1M context, $1.74/M input tokens |
| Protocol | Anthropic Messages API | 兼容 OpenAI / DeepSeek / 自定义端点 |
| Skills | MCP + Channel + Hooks | 可扩展的技能系统 |
| Bridge | iLink Bot API | 微信 ClawBot 官方协议 |

---

## 快速安装

### Windows
```powershell
curl -fsSL https://raw.githubusercontent.com/shimenghan6/claude-code-starter/master/install.bat -o install.bat && install.bat
```

### macOS / Linux
```bash
curl -fsSL https://raw.githubusercontent.com/shimenghan6/claude-code-starter/master/install.sh | bash
```

安装过程按提示选择：

| 步骤 | 内容 | 说明 |
|------|------|------|
| 1 | Node.js 检测 | >= 18，无则提示安装 |
| 2 | `npm install -g @anthropic-ai/claude-code` | Claude Code CLI |
| 3 | DeepSeek API Key | 自动弹出 platform.deepseek.com 引导注册 |
| 4 | Skills (可选) | browser-control / github-research / sound-notifier |
| 5 | 微信接入 (可选) | iLink Bot API + CDN AES decryption |
| 6 | 完成 | `claude` 启动 |

---

## 内置 Skills

| Skill | 能力 | 触发词 |
|-------|------|--------|
| browser-control | 浏览器操控，四层 fallback | "搜一下""打开网站" |
| github-research | GitHub 项目调研，对比矩阵 | "查一下 xxx 项目""对比" |
| claude-code-sound-notifier | PermissionRequest + Stop hooks | 自动，无需触发 |

## 微信接入 (可选)

勾选后自动部署 [claude-code-wechat](https://github.com/shimenghan6/claude-code-wechat)：

- **协议**: 微信 ClawBot iLink Bot API (`ilinkai.weixin.qq.com`)
- **会话保持**: `claude -p --resume <UUID>` 持久 session
- **多媒体**: PaddleOCR + Whisper + FFmpeg + 腾讯云 TIIA
- **安全**: 消息队列串行处理，防并发 session 冲突

---

## 常见问题

**Q: DeepSeek API Key 在哪获取？**

安装脚本自动弹出 `platform.deepseek.com` → 注册 → API Keys → 创建 → 粘贴。新用户注册送额度。

**Q: 和直接用 ChatGPT / Claude.ai 有什么区别？**

ChatGPT 是聊天界面，Claude Code 是能操控本地文件系统的 AI Agent——它调用 Bash 执行命令、Read/Write 读写文件、WebSearch 搜索网页、通过 MCP 扩展任意工具。

**Q: 能用其他模型吗？**

可以。编辑 `~/.claude/settings.json` 的 `ANTHROPIC_BASE_URL` 指向任何 Anthropic 兼容端点（OpenAI、Groq、Ollama 本地模型等）。

**Q: 微信接入需要什么条件？**

iOS + 微信最新版（ClawBot 插件）。Android 暂不支持腾讯官方 iLink 协议。

---

## License

MIT
