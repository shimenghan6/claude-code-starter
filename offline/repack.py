import os, shutil, zipfile

HOME = os.path.expanduser('~')
DESKTOP = os.path.join(HOME, 'Desktop', 'cc文档生成')
REPO = os.path.join(HOME, 'github-repos', 'claude-code-starter')
CLAUDE = os.path.join(HOME, '.claude')
TEMP = os.path.join(os.environ.get('TEMP', '/tmp'), 'claude-repack')

os.makedirs(DESKTOP, exist_ok=True)

def create_package(name, desc, skills, wechat, filename):
    staging = os.path.join(TEMP, name)
    if os.path.exists(staging):
        shutil.rmtree(staging)
    os.makedirs(staging, exist_ok=True)

    installer = os.path.join(REPO, 'offline', 'install-offline.bat')
    shutil.copy(installer, os.path.join(staging, '双击安装.bat'))
    shutil.copy(os.path.join(REPO, 'settings.template.json'), os.path.join(staging, 'settings-template.json'))

    skill_dest = os.path.join(staging, 'skills')
    os.makedirs(skill_dest, exist_ok=True)
    for skill in skills:
        actual = 'claude-code-sound-notifier' if skill == 'sound-notifier' else skill
        src = os.path.join(CLAUDE, 'skills', actual, 'SKILL.md')
        dst_dir = os.path.join(skill_dest, skill)
        os.makedirs(dst_dir, exist_ok=True)
        if os.path.exists(src):
            shutil.copy(src, dst_dir)
            print(f'  [OK] {skill}')
        else:
            print(f'  [WARN] {skill} missing')

    if wechat:
        w_dst = os.path.join(staging, 'wechat')
        os.makedirs(w_dst, exist_ok=True)
        for f in ['wechat-bridge.mjs', 'media-processor.py', 'cloud_vision.py']:
            p = os.path.join(CLAUDE, f)
            if os.path.exists(p):
                shutil.copy(p, w_dst)
        print('  [OK] WeChat module')

    price = '88' if '基础' in name else ('168' if '进阶' in name else '298')
    skill_text = ', '.join(skills)
    if wechat:
        skill_text += ' + WeChat'
    readme = f'{name}\n\nSkills: {skill_text}\nPrice: {price} RMB\n\nhttps://github.com/shimenghan6/claude-code-starter'
    with open(os.path.join(staging, 'readme.txt'), 'w', encoding='utf-8') as f:
        f.write(readme)

    output = os.path.join(DESKTOP, filename)
    with zipfile.ZipFile(output, 'w', zipfile.ZIP_DEFLATED) as zf:
        for root, dirs, files in os.walk(staging):
            for file in files:
                fpath = os.path.join(root, file)
                aname = os.path.relpath(fpath, staging)
                zf.write(fpath, aname)
    size_kb = os.path.getsize(output) / 1024
    print(f'  [OK] {filename} ({size_kb:.1f} KB)')

print('=== Repack 3 tiers ===')
if os.path.exists(TEMP):
    shutil.rmtree(TEMP)

# Delete old zips
for f in os.listdir(DESKTOP):
    if f.endswith('.zip') and any(x in f for x in ['88元', '168元', '298元']):
        os.remove(os.path.join(DESKTOP, f))

create_package('基础版', '基础版', ['browser-control', 'github-research'], False, '基础版-88元-ClaudeCode安装包.zip')
create_package('进阶版', '进阶版', ['browser-control', 'github-research', 'sound-notifier', 'github-publisher'], False, '进阶版-168元-ClaudeCode全skill安装包.zip')
create_package('尊享版', '尊享版', ['browser-control', 'github-research', 'sound-notifier', 'github-publisher'], True, '尊享版-298元-含微信安装包.zip')

shutil.rmtree(TEMP)
print('Done!')
