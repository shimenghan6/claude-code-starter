# 别再手动配 Claude Code 了！一个 bat 双击，3 分钟拥有 AI 编程助手（小白专用）

> 支持 DeepSeek V4 · 微信远程操控 · 浏览器自动化 · 零门槛

---

你有没有这种经历——

想看别人说的"Claude Code 很好用"，打开 GitHub → `npm install` → 报错 → 找 API Key → 不知道去哪弄 → 找配置教程 → JSON 写错了 → 放弃了。

**我今天写了一个工具，把上面所有步骤变成：双击 + 粘贴 Key + 回车。**

---

## 它能干什么

装上之后，打开终端输 `claude`，然后：

```
你: "帮我用 Python 写一个批量下载图片的脚本"
Claude: 打开编辑器，写完代码，告诉你怎么运行

你: "搜一下 React 19 有哪些新特性"
Claude: 自动打开浏览器 → 百度搜索 → 点第一个结果 → 读完告诉你

你: "我微信发你的图片里有什么"
Claude: OCR 识字 → 场景识别 → 微信回复你 "这是一张包含 xxx 的图片"
```

**而且这些只需要一行命令就能装好。**

---

## 3 分钟安装

### 第一步：双击 install.bat

从 GitHub 下载 `install.bat`，**双击运行**。

脚本会自动检测你有没有 Node.js。没有的话会提示你下载。

### 第二步：粘贴 DeepSeek API Key

脚本会问"你有 DeepSeek Key 吗？"

- 没有 → **自动弹出浏览器**打开 `platform.deepseek.com`
- 注册（手机号就行）→ 左侧点 "API Keys" → 创建 → 复制
- 回到终端粘贴

注册送额度，日常用一个月几块钱。

### 第三步：选装技能（可选）

```
可选技能:
  1. 浏览器操控 - 说"搜一下xxx"自动操控浏览器
  2. GitHub 调研 - 说"查一下xxx项目"自动对比分析
  3. 声音提示   - 任务完成叮咚提醒
  4. 全部安装
  回车跳过
```

### 第四步：要不要微信遥控？（可选）

选了 `y`，装好之后在微信里就能操控你的 Claude Code。上班路上发消息让它写代码，开会时发消息让它跑测试。

### 完成

```
╔══════════════════════════════════════════╗
║         安装完成！                      ║
║   打开终端，输入: claude               ║
╚══════════════════════════════════════════╝
```

---

## 为什么用 DeepSeek 而不是 Claude 官方 API

| | Claude 官方 | DeepSeek |
|---|:---:|:---:|
| 价格 | $15/M tokens | $1.74/M tokens |
| 注册 | 需要海外信用卡 | 手机号就行 |
| 国内访问 | 需要 VPN | 直连 |
| 上下文 | 200K | **100 万 token** |

同样是 Anthropic Messages API 协议，Claude Code 不需要改任何东西就能用 DeepSeek。

---

## 技术栈（给想看原理的人）

```
Claude Code (Anthropic CLI)
    │
    ├─ ANTHROPIC_BASE_URL → https://api.deepseek.com/anthropic
    ├─ Model → deepseek-v4-pro (1M context)
    │
    ├─ Skills (MCP + Channel + Hooks)
    │   ├── browser-control (agent-browser + CDP)
    │   ├── github-research (GitHub REST API)
    │   └── claude-code-sound-notifier (PermissionRequest hook)
    │
    └─ WeChat Bridge (可选)
        ├── iLink Bot API (微信 ClawBot)
        ├── CDN AES-128-ECB 解密
        └── PaddleOCR + Whisper + FFmpeg
```

---

## GitHub 地址

**[https://github.com/shimenghan6/claude-code-starter](https://github.com/shimenghan6/claude-code-starter)**

如果这个工具帮你省了半小时配环境的时间，点个 Star ⭐ 就是最大的鼓励。

有问题提 Issue，我看到就会回复。

---

## 相关项目

| 项目 | 说明 |
|------|------|
| [claude-code-wechat](https://github.com/shimenghan6/claude-code-wechat) | 微信远程操控 Claude Code，支持图片/语音/视频 |
| [browser-control](https://github.com/shimenghan6/browser-control) | 浏览器四层备选操控，自动切换方案 |
| [claude-code-sound-notifier](https://github.com/shimenghan6/claude-code-sound-notifier) | 任务完成叮咚提醒 |

---

*第一次写推广文，如果觉得有用帮忙点个赞，让更多人看到。*
