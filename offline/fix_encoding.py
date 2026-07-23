import os

repo = r'C:\Users\shish\github-repos\claude-code-starter'

for bat_name in ['install.bat', 'offline/install-offline.bat']:
    fpath = os.path.join(repo, bat_name)

    with open(fpath, 'r', encoding='utf-8') as f:
        content = f.read()

    # Fix broken \n -> newline in Node.js paths (Python escape side effect)
    # Each broken line looks like: ...ProgramFiles%<newline>odejs...
    # We need to rejoin them
    fixes = [
        (r'%ProgramFiles%' + '\n' + 'odejs', r'%ProgramFiles%\nodejs'),
        (r'%LOCALAPPDATA%\Programs' + '\n' + 'odejs', r'%LOCALAPPDATA%\Programs\nodejs'),
        (r'%SystemDrive%\Program Files' + '\n' + 'odejs', r'%SystemDrive%\Program Files\nodejs'),
        (r'%%~d' + '\n' + 'ode.exe', r'%%~d\node.exe'),
        (r'%ProgramFiles%' + '\n' + 'odejs', r'%ProgramFiles%\nodejs'),
    ]

    for old, new in fixes:
        if old in content:
            content = content.replace(old, new)
            print(f'[{bat_name}] Fixed: ...{old[-20:]}...')

    # Also fix any /dev/null -> nul (shell artifact)
    content = content.replace('>/dev/null 2>&1', '>nul 2>&1')

    with open(fpath, 'w', encoding='utf-8', newline='\r\n') as f:
        f.write(content)

    # Verify
    with open(fpath, 'r', encoding='utf-8') as f:
        test = f.read()

    issues = []
    if 'odejs' in test:
        # Check if it's standalone (after newline) or properly attached
        for i, line in enumerate(test.split('\n'), 1):
            stripped = line.strip()
            if stripped == 'odejs' or stripped.startswith('odejs"') or stripped.startswith('ode.exe'):
                issues.append(f'  Line {i}: BROKEN: [{stripped}]')

    if issues:
        print(f'[{bat_name}] STILL BROKEN:')
        for issue in issues:
            print(issue)
    else:
        print(f'[{bat_name}] All clean')
