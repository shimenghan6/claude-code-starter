---
name: github-research
description: |
  GitHub项目调研与对比分析工具。一键获取项目信息、功能描述、Install方法、Star趋势、
  多项目横向对比、选型建议。触发条件："查一下github上的xxx", "对比一下xxx和xxx",
  "这个项目怎么样","帮我看看这个github项目","有没有类似的工具","推荐几个xxx的skill",
  "github项目调研","看一下xxx开源项目"
---

# GitHub 项目调研技能

## 核心流程（三步走）

```
1. 搜索发现 → 2. 获取详情 → 3. 对比输出
```

---

## 第一步：搜索发现

### 如果用户给了明确项目名
直接用 curl 调 GitHub API 获取 README：

```bash
curl -sL --connect-timeout 10 "https://raw.githubusercontent.com/{owner}/{repo}/main/README.md"
```

### 如果用户要"找类似项目"或"推荐最火的"
使用 WebSearch 搜索，关键词模板：

```
github claude code {topic} skill stars 2026 site:github.com
github {topic} tool popular stars comparison
```

搜索结果的 title 和 URL 直接提取项目名、描述、star数。

---

## 第二步：获取详情

### 方案A：用 curl 直接拉 README（最快）

```bash
# 获取README
curl -sL --connect-timeout 10 "https://raw.githubusercontent.com/{owner}/{repo}/main/README.md" | head -100

# 获取SKILL.md（Claude Code技能专用）
curl -sL --connect-timeout 10 "https://raw.githubusercontent.com/{owner}/{repo}/main/SKILL.md" | head -50

# 获取目录结构（了解文件组织）
curl -sL --connect-timeout 10 "https://api.github.com/repos/{owner}/{repo}/contents?ref=main" | grep '"name"' | head -30
```

### 方案B：用 WebFetch 获取网页内容

当 curl 不通时（如域名被企业安全策略拦截），用 WebFetch 工具获取 README。

### 方案C：用 WebSearch 补充信息

当直接获取源代码失败时，搜索文章/博客对该项目的介绍和评价。

---

## 第三步：对比输出

### 单项目调研格式
```markdown
## 项目名 (Stars) — 一句话概括

| 维度 | 内容 |
|------|------|
| Stars | xxx |
| 语言/框架 | xxx |
| 安装方式 | 一行命令 |
| 核心能力 | 列3-5个 |
| 适用场景 | 什么时候用 |
| 局限 | 什么时候不合适 |
```

### 多项目对比格式
```markdown
## 排行（按Stars）
| # | 项目 | Stars | 核心理念 |
|---|------|:---:|------|

## 功能对比
| 维度 | 项目A | 项目B | 项目C |
|------|:---:|:---:|:---:|

## 选型建议
| 你的场景 | 推荐 |
|------|:---:|
```

---

## 获取Star数的标准方法

```bash
# GitHub API 获取repo基本信息（含stars）
curl -sL --connect-timeout 10 "https://api.github.com/repos/{owner}/{repo}" | grep -E '"stargazers_count"|"description"|"language"' | head -5
```

---

## 磁盘缓存（避免重复查询）

调研结果写入 `~/.claude/github-cache/{owner}-{repo}.md`：
```bash
mkdir -p ~/.claude/github-cache
# 缓存README
curl -sL "https://raw.githubusercontent.com/{owner}/{repo}/main/README.md" > ~/.claude/github-cache/{owner}-{repo}.md
```

下次查询先检查缓存是否存在且未过期（24h内），命中则直接读取。

---

## 多项目并行调研

对于"推荐几个xxx工具"类问题，并行执行：
1. WebSearch → 获取候选列表（项目名 + stars + 描述）
2. 对Top 3-5个项目并行 curl 获取 README 详情
3. 汇总 → 按 stars 排序 → 对比矩阵 → 选型建议

---

## 示例：调研 browser 相关 Claude Code 技能

**Step 1: 搜索**
```
WebSearch: "claude code browser skill automation stars github 2026"
```

**Step 2: 并行获取Top项目详情**
```
curl api.github.com/repos/vercel-labs/agent-browser | grep stars
curl raw.githubusercontent.com/vercel-labs/agent-browser/main/README.md
curl api.github.com/repos/browserbase/skills | grep stars
curl raw.githubusercontent.com/browserbase/skills/main/README.md
```

**Step 3: 输出对比矩阵**
```
| 维度 | agent-browser | browserbase/skills |
|------|:---:|:---:|
| Stars | 12.2K | 2.2K |
| 定位 | CLI工具 | 12技能套件 |
| ...
```
