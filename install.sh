#!/bin/bash
set -e

echo ""
echo " ╔══════════════════════════════════════════╗"
echo " ║     Claude Code Starter                ║"
echo " ║     Claude Code + DeepSeek + 技能包     ║"
echo " ╚══════════════════════════════════════════╝"
echo ""

# Step 0: Check prerequisites
echo "[1/6] 检查环境..."

if ! command -v node &>/dev/null; then
    echo " [X] 未检测到 Node.js"
    echo " 请先安装: https://nodejs.org"
    exit 1
fi
echo " [√] Node.js 已安装"

# Step 1: Install Claude Code
echo "[2/6] 安装 Claude Code..."
npm install -g @anthropic-ai/claude-code
echo " [√] Claude Code 已安装"

# Step 2: Configure DeepSeek
echo "[3/6] 配置 DeepSeek 模型..."
echo " 需要 DeepSeek API Key（注册送额度，每次调用几分钱）。"
read -p " 已经有 API Key 了？(y/n，默认 n): " HAS_KEY

if [ "$HAS_KEY" != "y" ]; then
    echo " 正在打开 DeepSeek 注册页面..."
    if [[ "$OSTYPE" == "darwin"* ]]; then
        open "https://platform.deepseek.com"
    else
        xdg-open "https://platform.deepseek.com" 2>/dev/null || echo " 请手动打开: https://platform.deepseek.com"
    fi
    echo ""
    echo " ┌─────────────────────────────────────────┐"
    echo " │  注册步骤:                              │"
    echo " │  1. 浏览器中注册/登录 DeepSeek         │"
    echo " │  2. 点左侧 "API Keys"                  │"
    echo " │  3. 点 "创建 API Key"                  │"
    echo " │  4. 复制 key (sk-开头)                 │"
    echo " │  5. 回到这里粘贴                       │"
    echo " └─────────────────────────────────────────┘"
    echo ""
fi
read -p " 请粘贴你的 DeepSeek API Key (sk-开头，回车跳过): " DEEPSEEK_KEY

SETTINGS_DIR="$HOME/.claude"
mkdir -p "$SETTINGS_DIR"

if [ -n "$DEEPSEEK_KEY" ]; then
    cat > "$SETTINGS_DIR/settings.json" << EOF
{
  "env": {
    "ANTHROPIC_BASE_URL": "https://api.deepseek.com/anthropic",
    "ANTHROPIC_AUTH_TOKEN": "${DEEPSEEK_KEY}",
    "ANTHROPIC_MODEL": "deepseek-v4-pro[1m]",
    "ANTHROPIC_DEFAULT_OPUS_MODEL": "deepseek-v4-pro[1m]",
    "ANTHROPIC_DEFAULT_SONNET_MODEL": "deepseek-v4-pro[1m]",
    "ANTHROPIC_DEFAULT_HAIKU_MODEL": "deepseek-v4-flash[1m]",
    "CLAUDE_CODE_EFFORT_LEVEL": "max"
  },
  "permissions": {
    "allow": [
      "Bash(npm *)",
      "Bash(pip *)",
      "Bash(curl *)",
      "Bash(node *)",
      "WebSearch",
      "WebFetch(*)",
      "Skill(*)"
    ]
  }
}
EOF
    echo " [√] DeepSeek 配置完成"
else
    echo " 跳过。之后手动编辑 ~/.claude/settings.json"
fi

# Step 4: Install skills
echo "[4/6] 安装技能包..."
echo ""
echo " 可选技能:"
echo "   1. 浏览器操控 - 说'搜一下xxx'自动操控浏览器"
echo "   2. GitHub 调研 - 说'查一下xxx项目'自动对比分析"
echo "   3. 声音提示   - 任务完成叮咚提醒"
echo "   4. 全部安装"
echo "   回车跳过"
echo ""
read -p " 请选择 (1/2/3/4，回车跳过): " SKILL_CHOICE

SKILLS_DIR="$HOME/.claude/skills"
mkdir -p "$SKILLS_DIR"

if [ "$SKILL_CHOICE" = "1" ] || [ "$SKILL_CHOICE" = "4" ]; then
    mkdir -p "$SKILLS_DIR/browser-control"
    curl -fsSL "https://raw.githubusercontent.com/shimenghan6/browser-control/master/SKILL.md" -o "$SKILLS_DIR/browser-control/SKILL.md" 2>/dev/null && echo " [√] browser-control - 浏览器操控" || echo " [-] browser-control 下载失败"
fi

if [ "$SKILL_CHOICE" = "2" ] || [ "$SKILL_CHOICE" = "4" ]; then
    mkdir -p "$SKILLS_DIR/github-research"
    curl -fsSL "https://raw.githubusercontent.com/shimenghan6/github-research/master/SKILL.md" -o "$SKILLS_DIR/github-research/SKILL.md" 2>/dev/null && echo " [√] github-research - GitHub调研" || echo " [-] github-research 下载失败"
fi

if [ "$SKILL_CHOICE" = "3" ] || [ "$SKILL_CHOICE" = "4" ]; then
    mkdir -p "$SKILLS_DIR/claude-code-sound-notifier"
    curl -fsSL "https://raw.githubusercontent.com/shimenghan6/claude-code-sound-notifier/master/install.sh" -o "$SKILLS_DIR/claude-code-sound-notifier/install.sh" 2>/dev/null && echo " [√] claude-code-sound-notifier - 声音提示" || echo " [-] 声音提示 下载失败"
fi

[ -z "$SKILL_CHOICE" ] && echo " 跳过技能安装（之后可随时安装: https://github.com/shimenghan6）"

# Step 5: WeChat (optional)
echo "[5/6] 微信接入..."
read -p " 接入微信远程操控? (y/n，默认 n): " WECHAT

if [ "$WECHAT" = "y" ]; then
    echo " 正在安装微信接入组件..."
    npm install -g claude-code-wechat-channel @weixin-claw/core 2>/dev/null
    curl -fsSL "https://raw.githubusercontent.com/shimenghan6/claude-code-wechat/master/wechat-bridge.mjs" -o "$HOME/.claude/wechat-bridge.mjs"
    curl -fsSL "https://raw.githubusercontent.com/shimenghan6/claude-code-wechat/master/media-processor.py" -o "$HOME/.claude/media-processor.py"
    
    cat > "$HOME/.mcp.json" << EOF
{
  "mcpServers": {
    "wechat": {
      "command": "npx",
      "args": ["-y", "claude-code-wechat-channel", "start"]
    }
  }
}
EOF
    echo " [√] 微信组件安装完成"
    echo " 下一步: curl -s https://ilinkai.weixin.qq.com/ilink/bot/get_bot_qrcode?bot_type=3"
else
    echo " 跳过微信接入（之后可随时安装: https://github.com/shimenghan6/claude-code-wechat）"
fi

# Step 6: Done
echo ""
echo "[6/6] 完成！"
echo ""
echo " ╔══════════════════════════════════════════╗"
echo " ║         安装完成！                      ║"
echo " ║   打开终端，输入: claude                ║"
echo " ╚══════════════════════════════════════════╝"
