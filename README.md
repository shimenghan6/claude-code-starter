# Claude Code Starter

> 小白也能 3 分钟装好 Claude Code + DeepSeek 模型 + 常用技能包。**零门槛、全中文、双击即用。**

装上之后你就有了一个能用微信遥控的 AI 编程助手——写代码、搜网页、读文件、操控浏览器，全在微信里完成。

## 一键安装（Windows）

1. 下载 `install.bat` → 双击
2. 按提示输入 DeepSeek API Key（没有的话脚本帮你打开注册页）
3. 等待安装完成
4. 打开终端输入 `claude` 即可使用

## 安装了什么

| 组件 | 是什么 | 有什么用 |
|------|--------|---------|
| Claude Code | Anthropic 官方 CLI | AI 编程助手 |
| DeepSeek V4 | 模型后端 | 便宜、快、上下文 100 万 token |
| browser-control | 浏览器操控 skill | 说句话就能搜索网页、打开网站 |
| github-research | 项目调研 skill | 一句话调研 GitHub 开源项目 |
| claude-code-sound-notifier | 声音提示 skill | 任务完成叮咚提醒 |
| 微信接入 (可选) | 远程操控 Claude Code | 微信里发消息操控电脑 |

## 需要什么

| 你需要 | 免费吗 |
|--------|:---:|
| Node.js >= 18 | 免费 |
| DeepSeek API Key | 注册送额度，每次调用几分钱 |
| 微信 iOS (可选) | 免费 |
| Windows / macOS / Linux | 都支持 |

## 常见问题

**Q: DeepSeek API Key 怎么弄？**

A: 安装脚本会自动打开 https://platform.deepseek.com → 注册 → 左侧"API Keys" → 创建新 Key → 复制粘贴回终端。

**Q: 要花钱吗？**

A: DeepSeek V4 输入 1RMB/百万 token，输出 2RMB/百万 token。个人日常用一个月几块钱。

**Q: 微信接入怎么用？**

A: 安装时选"是"，会自动配置。装完后扫码，在微信 ClawBot 里就能跟 Claude Code 对话。需要 iPhone + 微信最新版。

**Q: 能换其他模型吗？**

A: 能。编辑 `~/.claude/settings.json` 的 `env` 字段，改 `ANTHROPIC_BASE_URL` 和 `ANTHROPIC_MODEL` 即可。

## License

MIT
