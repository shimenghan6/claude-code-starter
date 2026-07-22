---
name: github-publisher
description: |
  GitHub 项目管理与发布。自动同步、去硬编码、美化 README、打版本号、一键安装、推送。
  内置 readme-polisher 美化 + 版本号管理（v1.0/v1.1/...）。
  触发条件："发布到github", "整理项目", "推送到github", "准备开源",
  "publish to github", "github发布", "把xxx推github"
---

# GitHub 发布技能

## 首次初始化（最重要）

**任何发布操作前，必须先确保环境就绪：**

```
1. 检查 ~/github-repos/ 是否存在
   → 不存在则 mkdir ~/github-repos/，并创建根 README.md
2. 检查 ~/.claude/skills/ 是否存在
   → 不存在则提示用户"没有 skills 目录"
3. 检查 git 是否可用
   → 不可用则提示安装
```

## 核心目录

所有待发布项目统一在：`~/github-repos/`。每个子目录是一个独立 Git 仓库。

## 工作流程

### 1. 新增项目（含容错）

```
用户说："把 xxx 发布到 GitHub"

→ 1. 确保 ~/github-repos/ 存在（不在则 mkdir）
→ 2. 检查源文件从哪里来：
     - ~/.claude/skills/<name>/ 存在 → 从这里同步
     - 不存在 → 问用户"源文件在哪"
→ 3. 创建 ~/github-repos/<name>/
→ 4. 复制所有源文件（排除 account.json, credentials.json, *.log, __pycache__）
→ 5. 如果还没 git init → git init
→ 6. 创建 .gitignore（不存在则生成）
→ 7. 扫描所有文件，替换硬编码路径:
     - C:/Users/shish → 环境变量自动检测
     - C:\Users\shish → 跨平台兼容写法
→ 8. 如果没有 README.md → 生成最小模板
→ 9. ★ 调用 readme-polisher skill 美化 README（钩子+关键词+对比表）
→ 10. ★ 创建一键安装脚本（铁律，见下方"一键安装脚本要求"）
→ 11. ★ 打版本号: git tag v1.0 && git push origin v1.0
→ 12. 更新根 README.md 的项目列表
→ 13. 更新本技能的项目清单
```

### 2. 更新已有项目

```
用户说："更新 browser-control"

→ 1. 确认 ~/github-repos/<name>/ 已存在（不在则走"新增"流程）
→ 2. 确认 ~/.claude/skills/<name>/ 有更新源（不在则跳过同步步骤）
→ 3. 同步源文件（不覆盖 .git 目录，不覆盖用户手动改过的 README）
→ 4. 重新扫描硬编码路径
→ 5. 如果 README 有变更 → 调用 readme-polisher skill 美化
→ 6. ★ 版本号 +1: 查看当前 tag → bump → git tag vX.Y && git push origin vX.Y
```

### 3. 版本号管理（每次推送必做）

**每次 push 前，必须打版本号。** 格式: `v主.次`（如 v1.0, v1.1, v2.0）。

```bash
# 查看当前最新版本
git tag --sort=-v:refname | head -1

# 首次发布
git tag v1.0 && git push origin v1.0

# 更新发布（手动 bump，pre-push hook 会自动再 +1）
# 当前是 v1.0 → 手动打 v1.1 → push → hook 自动生成 v1.2
git tag v1.1 && git push origin v1.1
```

**版本号规则：**
- 新项目首次发布 → v1.0
- 小更新（修 bug、加文档）→ +0.1（v1.0 → v1.1）
- 大更新（新功能、架构变更）→ +1.0（v1.x → v2.0）
- 所有项目必须有至少一个 tag

**当前各项目最新版本：**

| 项目 | 版本 |
|------|:---:|
| claude-code-wechat | — |
| browser-control | v1.5 |
| github-research | — |
| github-skill-downloader | — |
| github-publisher | v1.5 |
| ai-installer | — |
| claude-code-sound-notifier | — |
| offline-packager | v1.0 |
| claude-code-starter | v1.9 |

### 4. README 美化（readme-polisher 集成）

**每次发布或更新 README 时，必须调用 readme-polisher skill。**

触发时机：
- 新增项目：步骤 9
- 更新项目：README 有变更时
- 用户说"美化 README"时

美化内容：
- 标题下加 `>` 钩子引用块（有画面感的场景描述）
- 加一行 `**技术关键词**` 粗体
- 加"谁需要这个"表格（3-4 行）
- 加 Before/After 对比表（工具/ starter 类项目）
- **原有一字不动**

### 5. ★ 强制输出检查清单（铁律：未全勾不得结束）

**每一次发布操作结束时，必须在回复中逐项输出此清单。** 这是防止漏步骤的唯一外部强制机制。原理：AI 注意力在执行多步后衰减，子步骤（readme-polisher、install脚本、tag）容易被跳过。输出清单强制每步被回顾。

```
═══════════════════════════════════════
        发布完成检查清单
═══════════════════════════════════════
□ 1. ~/github-repos/ 目录存在
□ 2. 项目目录存在且文件已同步
□ 3. .git 已初始化
□ 4. .gitignore 包含 node_modules/、__pycache__/、*.log
□ 5. 无硬编码用户路径（搜索 C:/Users/、/home/）
□ 6. README.md 存在且包含安装方式、使用说明、依赖
□ 7. ★ readme-polisher 已调用并美化 README（钩子+关键词+对比表）
□ 8. ★ 一键安装脚本已创建（install.ps1 / install.sh）
□ 9. ★ 版本号已打（git tag vX.Y）
□ 10. account.json、credentials.json 不在仓库中
□ 11. 没有 node_modules/ 目录
□ 12. git push origin master --tags 已执行成功
═══════════════════════════════════════
```

**如果任一带 ★ 项为 ☐ → 立即补做，不得跳过。**
**必须每项都 □ → 才能说"发布完成"。**

### 6. 推送到 GitHub（含版本管理）

```bash
cd ~/github-repos/<项目名>
git add -A
git commit -m "<提交信息>"
git push origin master --tags  # pre-push hook 自动 bump 版本号
```

### 7. 生成离线安装包（可选，需明确请求）

**仅当用户说"打包离线版"/"生成安装包"/"打包ZIP"时执行。不允许自动生成。**

```bash
powershell -File ~/github-repos/claude-code-starter/offline/package.ps1
```

ZIP → 桌面 `ClaudeCode离线安装包.zip`

### 6. 用户手动推送到 GitHub

如果自动化走不通，用户自己在 GitHub 建仓库后：

```bash
cd ~/github-repos/<项目名>
git add -A
git commit -m "<提交信息>"
git remote add origin <repo-url>
git push -u origin master --tags
```

## 项目清单（当前）

| 项目 | 目录 | 状态 |
|------|------|------|
| claude-code-wechat | `~/github-repos/claude-code-wechat/` | 已推送 |
| browser-control | `~/github-repos/browser-control/` | 已推送 |
| github-research | `~/github-repos/github-research/` | 已推送 |
| github-skill-downloader | `~/github-repos/github-skill-downloader/` | 已推送 |
| github-publisher | `~/github-repos/github-publisher/` | 已推送 |
| ai-installer | `~/github-repos/ai-installer/` | 已推送 |
| claude-code-sound-notifier | `~/github-repos/claude-code-sound-notifier/` | 已推送 |
| offline-packager | `~/github-repos/offline-packager/` | 已推送 |

## 推送实战踩坑记录（6 个致命坑）

以下是首次批量推送 6 个项目时遇到的完整踩坑记录。

### 坑 1：`gh auth login --web` 设备认证反复超时

**现象**：`gh auth login --web` 弹出设备码后，浏览器或终端无法完成认证，`gh auth status` 始终显示未登录。

**根因**：企业/地区网络限制，GitHub REST API（`github.com/login/device`）被防火墙阻断。HTTPS 请求到 GitHub API 的路径不通。

**尝试过的方案**：
| 方案 | 结果 |
|------|------|
| `gh auth login --web` 设备码 | 超时，`ConnectTimeout` |
| `gh auth login --git-protocol ssh` | 同样需要设备认证，一样的超时 |
| Personal Access Token | 用户未创建，需额外步骤 |

**最终解决**：放弃 HTTPS 设备认证，改用 SSH 协议。生成 ed25519 密钥 → 用户粘贴到 GitHub Settings → `git push git@github.com` 绕过 API。

**教训**：优先检测网络状况。如果 `curl github.com` 能通但 `gh` 不能，直接用 SSH。

---

### 坑 2：RSA SSH 密钥 "Server accepts key" 但最终 Permission denied

**现象**：`ssh -vT git@github.com` 显示 `Server accepts key`，但最后 `Permission denied (publickey)`。

**根因**：GitHub 对某些 RSA 密钥的签名算法支持有限。`ssh-rsa` 在新版 OpenSSH 中可能不被 GitHub 接受。

**解决**：用 `ssh-keygen -t ed25519` 生成 ed25519 密钥，在 `~/.ssh/config` 中配置：
```
Host github.com
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519_github
    IdentitiesOnly yes
```

**教训**：首选 ed25519 密钥，兼容性最好。RSA 即使 GitHub 接受也可能在特定客户端失效。

---

### 坑 3：agent-browser 连不上用户已有的浏览器窗口

**现象**：用户 Edge/Chrome 已登录 GitHub，但 `agent-browser --auto-connect` 失败，所有 CDP 端口（9222/9223/9229）无响应。

**根因**：Chrome/Edge 必须以 `--remote-debugging-port=9222` 参数启动才会开启 CDP 监听端口。用户正常打开的浏览器没有这个端口。用 `--profile` 指定用户目录也不生效，因为浏览器锁定了 profile。

**尝试过的方案**：
| 方案 | 结果 |
|------|------|
| `agent-browser --auto-connect` | 端口不通 |
| `agent-browser --cdp 9222` | 端口不通 |
| `netstat` 扫描常见端口 | 全部关闭 |
| `--profile "Default"` | 新浏览器没有 cookie |

**最终解决**：`taskkill //F //IM msedge.exe` 杀掉所有 Edge 进程 → `msedge.exe --remote-debugging-port=9222 "https://github.com/new"` 重启 → 用户重新登录 → `agent-browser --cdp 9222` 成功连接。

**教训**：
- 浏览器自动化必须预先计划 CDP 端口。日常使用的浏览器无法被外部工具操控。
- **用户已经登录的窗口不能直接用**——这是 agent-browser 最大的 UX 坑。必须杀进程重启带调试端口，用户要重新登录一遍。
- 如果 GitHub 等需要登录态的网站操作，优先走 SSH/API 而不是浏览器操控。

**解决步骤**：
```bash
taskkill //F //IM msedge.exe
msedge.exe --remote-debugging-port=9222 "https://github.com/new"
# 用户在新窗口中重新登录
agent-browser --cdp 9222 open "https://github.com/new"
```

---

### 坑 4：agent-browser `snapshot` 在 GitHub SPA 页面返回空

**现象**：`agent-browser snapshot -i` 在 `github.com/new` 返回 `(no interactive elements)`，无法使用 `click @eXX` 方式操作。

**根因**：GitHub 是 React SPA，DOM 全部由 JavaScript 动态渲染。无障碍树可能未及时更新，或 GitHub 使用了 shadow DOM / web component 导致快照为空。

**解决**：完全放弃 snapshot + ref 路径，改用 `agent-browser eval` 直接执行 JavaScript：
```js
agent-browser eval "document.getElementById('repository-name-input')..."
```

**教训**：现代 SPA 网站（React/Vue）不要依赖 snapshot。优先用 eval 直接查 DOM。

---

### 坑 5：`eval` 内 `setTimeout` 不生效

**现象**：用 eval 填表后 `setTimeout(() => btn.click(), 800)` 不触发，eval 返回成功但按钮未点击。循环建 6 个仓库时全部失败。

**根因**：`agent-browser eval` 同步返回 eval 语句的返回值后，页面脚本立即退出或被回收。`setTimeout` 的异步回调还来不及执行就被取消了。

**第一次尝试（失败）**：
```js
// eval 返回 'submitted' 但 setTimeout 从未触发
inp.value = 'repo-name';
setTimeout(() => { btn.click(); }, 800);
return 'submitted';
```

**最终解决**：拆成两步 eval：
1. 第一次 eval：填表 → 返回结果
2. `sleep 2` 等待 React 验证表单
3. 第二次 eval：查找按钮 → 点击

```bash
# Step 1: fill
agent-browser eval "...nativeInputValueSetter.call(inp, '$repo')..."

# Wait
sleep 2

# Step 2: click
agent-browser eval "...btn.click()..."
```

**教训**：eval 中不要用 setTimeout/async 做延迟操作。拆成两个 eval + shell sleep。

---

### 坑 6：React 表单输入值设置不生效

**现象**：直接 `document.getElementById('repository-name-input').value = 'xxx'` 填表后，创建按钮仍是灰色禁用状态。

**根因**：React 劫持了原生 `<input>` 的 setter，用 `HTMLElement.prototype` 的 setter 覆盖了赋值行为。直接赋值 `input.value` 不会触发 React 的状态更新，创建按钮检测不到输入变化。

**解决**：用原生 Property Descriptor 强制设置：
```js
const nativeInputValueSetter = Object.getOwnPropertyDescriptor(
  window.HTMLInputElement.prototype, 'value'
).set;
nativeInputValueSetter.call(inp, 'repo-name');
inp.dispatchEvent(new Event('input', {bubbles: true}));
inp.dispatchEvent(new Event('change', {bubbles: true}));
```

**教训**：React/Vue 等框架接管了表单元素的 value 属性。操作这类页面时，必须用原生 setter + 手动触发事件来模拟用户输入。

---


### 最终成功的推送流程

```
1. ssh-keygen -t ed25519 → 用户粘贴公钥到 GitHub Settings
2. taskkill 所有 Edge → 重启 msedge --remote-debugging-port=9222
3. 用户在 Edge 中登录 GitHub
4. agent-browser --cdp 9222 连接现有 Edge
5. 用 nativeInputValueSetter 填表 → 两步 eval 创建仓库
6. 循环 6 次建完所有 repos
7. git remote add git@github.com → git push -u origin master
8. 6 个仓库全部推送成功
```

### 推送前网络诊断清单

```
□ curl -s https://github.com → HTTP 200? 能通则可能走 HTTPS
□ ssh -T git@github.com → Hi xxx! 出现则 SSH 通
□ gh auth status → 已登录则优先用 gh
□ 三者都不通 → 排查代理/VPN/防火墙
```

### 浏览器自动化诊断清单

```
□ Edge/Chrome 是否以 --remote-debugging-port=9222 启动？
□ curl http://127.0.0.1:9222/json/version → 有 JSON 返回则 CDP 通
□ agent-browser --cdp 9222 open "URL" → 成功则继续
□ 页面是 SPA？ → 放弃 snapshot，直接用 eval
□ 表单是 React？ → 用 nativeInputValueSetter + dispatchEvent
□ setTimeout 无效？ → 拆分 eval + shell sleep
```



### 坑8: gh CLI不可用时的备用方案(PAT+API)

gh CLI未安装或网络不通时,用Personal Access Token+REST API创建仓库,SSH推送.

1. 用户创建classic PAT: github.com/settings/tokens -> new -> classic -> 勾选repo
2. Python创建仓库:
`import requests; r=requests.post("https://api.github.com/user/repos",json={"name":"repo-name"},headers={"Authorization":"Bearer <token>"},timeout=15)`
3. git remote add git@github.com -> git push -u origin main

验证token权限: r.headers.get("X-OAuth-Scopes") 应包含repo.

### 坑9: 跳过 github-publisher skill 手动操作（2026-05-30 教训）

**现象**：用户说"把 offline-packager 发布到 GitHub"，直接开始手动操作：读文件→改 README→写 install 脚本→手动连浏览器。没调用 github-publisher skill，也没调用 browser-control skill。

**后果**：
- 重复劳动：github-publisher skill 里已有完整发布流程+踩坑记录，全部被跳过
- 用户批评估："为什么不会自动用发布管理器skill呢？"
- 浪费大量时间在已解决的问题上（React表单、CDP连接等）
- 用 MCP chrome-devtools 而不是 browser-control skill，开新浏览器窗口

**根因**：没有执行自动路由规则——匹配到"发布到 GitHub"场景时没有自动触发 github-publisher skill。

**解决（铁律）**：

```
任何发布 GitHub 操作 → 自动调用 github-publisher skill（不是可选项，是必须）
需要浏览器创建仓库 → github-publisher 内部调用 browser-control skill（不直接操作浏览器）
```

**铁律已写入 memory**：`auto-use-skills.md` — 场景匹配时必须自动调用对应 skill。

---

### 坑10: agent-browser --cdp 在已有窗口时会新开标签页（2026-05-30 教训）

**现象**：用户 Edge 已开 CDP 端口 9222，`agent-browser --cdp 9222 open "URL"` 能连上，但会新开一个标签页。用户连续批评估"不要新开窗口"、"在已开的窗口执行"。

**根因**：agent-browser 不支持指定已有标签页——`open` 命令总是创建新标签页。即使 CDP 连接的是用户浏览器，用户体验仍然是"被操控开新页"。

**解决：Python + CDP WebSocket 直连已有标签页**（零新窗口）：

```python
import asyncio, json, urllib.request, websockets

async def cdp_on_existing_tab(url_match):
    """在用户已打开的标签页上执行操作，不新开任何窗口"""
    resp = urllib.request.urlopen('http://127.0.0.1:9222/json')
    pages = json.loads(resp.read())
    
    # 找到用户已在浏览的目标标签页
    target = next((p for p in pages if url_match in p.get('url', '')), None)
    if not target:
        raise Exception('目标标签页未找到')
    
    ws_url = target['webSocketDebuggerUrl']
    
    async with websockets.connect(ws_url) as ws:
        await ws.send(json.dumps({'id': 1, 'method': 'Runtime.enable'}))
        await ws.recv()  # 等待就绪
        
        # 在已有标签页执行任何 JS（填表、点击、读取等）
        await ws.send(json.dumps({
            'id': 2, 'method': 'Runtime.evaluate',
            'params': {'expression': 'document.title', 'returnByValue': True}
        }))
        result = await ws.recv()
        print(result)

asyncio.run(cdp_on_existing_tab('github.com/new'))
```

**关键优势**：
- 不新开窗口/标签页，用户看到的标签页就是操作目标
- 直接操控用户已登录的页面（无需重新登录）
- 不需要 PAT token，不需要 gh CLI
- 用 Python 内置 `websockets` 库（pip install websockets）

**判断是否能直连已有窗口**：
```bash
curl -s http://127.0.0.1:9222/json/version  # 有 JSON 返回 → CDP 端口已开 → 可用此方案
```

### 创建 GitHub 仓库 —— 最终推荐方案（按优先级）

| 优先级 | 方案 | 适用条件 |
|--------|------|---------|
| 1 | Python + CDP WebSocket 操控已有标签页 | 用户 Edge 已开 CDP 端口，且已登录 GitHub |
| 2 | PAT + REST API + SSH push | 无 CDP 端口但有 PAT token |
| 3 | agent-browser --cdp | 上面两个都不可用（但会新开标签页） |

## 硬编码路径替换规则

| 原始 | 替换为 |
|------|--------|
| `C:/Users/shish/AppData/Roaming/npm/node_modules` | `execSync("npm root -g")` |
| `C:\\Users\\shish\\...\\python.exe` | `getPython()` 自动检测 |
| `C:/Users/shish/.claude/` | `resolve(homedir(), ".claude")` |

## .gitignore 模板

```
node_modules/
__pycache__/
*.pyc
*.log
.env
account.json
credentials.json
```

## 一键安装脚本要求（铁律）

**每个即将推送 GitHub 的项目，必须提供一键安装方式。** 不允许用户手动复制粘贴多步操作。

### 脚本文件命名

| 场景 | 文件名 | 说明 |
|------|--------|------|
| Windows 专属 | `install.ps1` | PowerShell 脚本，右键运行 |
| macOS/Linux | `install.sh` | bash 脚本，curl pipe |
| 跨平台 Python | `install.py` | Python 脚本，适用于复杂安装 |
| Node.js / npm 包 | 在 `package.json` 中配 `bin` | `npm install -g` 即可 |

### 脚本必须做到

1. **自动检测环境**：用户路径、Python 版本、系统类型等
2. **不影响已有配置**：如果是 JSON 合并，追加不覆盖
3. **有试跑反馈**：装完后立即验证，告诉用户成功还是失败
4. **不丢异常**：文件不存在、依赖缺失等情况要有中文提示

### README 安装栏格式

```markdown
## 一键安装

### Windows
```powershell
powershell -ExecutionPolicy Bypass -Command "irm https://raw.githubusercontent.com/<用户名>/<项目>/main/install.ps1 | iex"
```

### macOS / Linux
```bash
curl -fsSL https://raw.githubusercontent.com/<用户名>/<项目>/main/install.sh | bash
```
```

### 各类型项目的安装脚本模板

#### 1. Skill 类（复制到 ~/.claude/skills/）

```
安装流程：curl 下载 SKILL.md → 放到 ~/.claude/skills/<name>/ → 提示重启 Claude Code
```

#### 2. 配置类（合并到 settings.json）

```
安装流程：读现有 settings.json → 追加 hook/permission → 写回 → 提示开新对话
```

#### 3. Python 工具类

```
安装流程：pip install → 验证 CLI 可用 → 提示使用方式
```

#### 4. Node.js 工具类

```
安装流程：npm install -g → 验证命令可用 → 提示使用方式
```

## README.md 最小模板

```markdown
# 项目名

一句话描述。

## 安装

## 使用

## 依赖

## License

MIT
```
