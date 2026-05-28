#!/usr/bin/env python3
"""
Generate B站 demo video for claude-code-starter.
Creates a 55-second video with title cards, terminal capture, and transitions.
"""
import os, sys, subprocess, textwrap, time
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont

PROMO_DIR = Path(__file__).parent
OUTPUT = str(PROMO_DIR / "demo_generated.mp4")
FONT_PATH = "C:/Windows/Fonts/msyh.ttc"
BG_COLOR = (13, 17, 23)  # GitHub dark
ACCENT = (88, 166, 255)   # Blue
GREEN = (63, 185, 80)
WHITE = (255, 255, 255)
GRAY = (139, 148, 158)

FFMPEG = "C:/Users/shish/AppData/Local/Microsoft/WinGet/Packages/Gyan.FFmpeg_Microsoft.Winget.Source_8wekyb3d8bbwe/ffmpeg-8.1.1-full_build/bin/ffmpeg.exe"

def create_frame(text_lines, highlight_line=None, subtitle=None, width=1920, height=1080):
    """Create a single frame with styled text."""
    img = Image.new("RGB", (width, height), BG_COLOR)
    draw = ImageDraw.Draw(img)

    try:
        font_big = ImageFont.truetype(FONT_PATH, 80)
        font_mid = ImageFont.truetype(FONT_PATH, 48)
        font_small = ImageFont.truetype(FONT_PATH, 32)
    except:
        font_big = font_mid = font_small = ImageFont.load_default()

    # Blue accent bar on left
    draw.rectangle([60, 0, 68, height], fill=ACCENT)

    y = 200
    for i, line in enumerate(text_lines):
        color = ACCENT if (highlight_line is not None and i == highlight_line) else WHITE
        font = font_big if i < 2 else font_mid
        draw.text((140, y), line, fill=color, font=font)
        y += 100 if i < 2 else 70

    if subtitle:
        # Bottom bar
        draw.rectangle([0, height-120, width, height], fill=(22, 27, 34))
        draw.rectangle([0, height-120, width, height-118], fill=ACCENT)
        draw.text((140, height-100), subtitle, fill=WHITE, font=font_small)

    # GitHub URL
    draw.text((140, height-60), "github.com/shimenghan6/claude-code-starter", fill=GRAY, font=font_small)

    return img

def gen_scene_frames(scenes, fps=2):
    """Generate frames for each scene, each scene lasts ~seconds."""
    frame_files = []
    for i, (text, secs, sub) in enumerate(scenes):
        img = create_frame(text, highlight_line=0, subtitle=sub)
        fname = str(PROMO_DIR / f"frame_{i:03d}.png")
        img.save(fname)
        # Duplicate for duration
        for _ in range(int(secs * fps)):
            frame_files.append(fname)
    return frame_files

# ── Define scenes ──
scenes = [
    # (text_lines, duration_seconds, subtitle)
    (["3 分钟拥有", "AI 编程助手"], 4, ""),
    (["Claude Code + DeepSeek V4", "小白专用 · 双击即用"], 3, ""),
    (["第一步：双击 install.bat", "自动检测环境 · 安装 Claude Code", "自动弹出 DeepSeek 注册页"], 5, "不需要手动安装任何东西"),
    (["第二步：粘贴 API Key", "没有 Key？脚本自动打开注册页", "注册 → API Keys → 创建 → 复制 → 粘贴"], 5, "DeepSeek 注册送额度，每月几块钱"),
    (["配置完成！", "终端输入 claude", "模型：DeepSeek V4 Pro · 上下文 100 万 token"], 4, "3 分钟搞定，零出错"),
    (["演示：写代码", '> 帮我用 Python 写一个爬虫', "自动生成代码 · 实时输出结果"], 8, "它可以读文件、写代码、执行命令"),
    (["演示：浏览器操控", "> 搜一下 React 19 新特性", "自动打开百度 → 搜索 → 点击 → 读给你听"], 8, "装上 browser-control，一句话操控浏览器"),
    (["演示：微信遥控（可选）", "地铁上发微信 → 电脑干活 → 微信回复结果", "离开电脑也能操控 Claude Code"], 6, "支持图片识别、语音转文字、视频分析"),
    (["全部开源 · 免费使用", "github.com/shimenghan6/claude-code-starter", "", "不想自己装？远程协助 100 元全包"], 6, ""),
    (["3 分钟拥有", "AI 编程助手", "双击 install.bat → 现在就开始"], 4, "⭐ Star 就是最大的支持"),
]

print("生成场景帧...")
frames = gen_scene_frames(scenes)

# Write frame list for FFmpeg concat
concat_file = str(PROMO_DIR / "frames.txt")
with open(concat_file, "w") as f:
    for frame in frames:
        f.write(f"file '{frame}'\n")
        f.write("duration 0.5\n")

print(f"共 {len(frames)} 帧, 渲染视频...")

# Use FFmpeg to create video from frames
subprocess.run([
    FFMPEG, "-y",
    "-f", "concat", "-safe", "0", "-i", concat_file,
    "-c:v", "libx264", "-preset", "fast", "-crf", "23",
    "-pix_fmt", "yuv420p", "-r", "30",
    "-movflags", "+faststart",
    OUTPUT
], check=True, capture_output=True)

# Cleanup
for f in frames:
    try: Path(f).unlink()
    except: pass
try: Path(concat_file).unlink()
except: pass

size_mb = os.path.getsize(OUTPUT) / 1_000_000
print(f"✓ 视频生成完成: {OUTPUT} ({size_mb:.1f}MB)")
