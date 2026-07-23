"""Fix: DeepSeek key input - add confirmation before skipping."""
import os, re

repo = r'C:\Users\shish\github-repos\claude-code-starter'

for bat_name in ['install.bat', 'offline/install-offline.bat']:
    fpath = os.path.join(repo, bat_name)
    with open(fpath, 'r', encoding='utf-8-sig') as f:
        content = f.read()

    # Find the set /p DEEPSEEK_KEY block by looking for unique markers
    # We need: from "set DEEPSEEK_KEY=" through the end of the "if empty" branch
    # ending at ") else ("

    # Use a more reliable approach: find line numbers
    lines = content.split('\n')
    set_key_line = None
    set_p_line = None
    skip_line = None

    for i, line in enumerate(lines):
        if line.strip() == 'set DEEPSEEK_KEY=':
            set_key_line = i
        if set_key_line is not None and 'set /p DEEPSEEK_KEY=' in line:
            set_p_line = i
        if set_p_line is not None and 'settings.json' in line and '跳过' in line:
            skip_line = i
            break

    if all(x is not None for x in [set_key_line, set_p_line, skip_line]):
        # Replace the "if empty, skip" block
        old_lines = lines[set_key_line:skip_line+1]

        new_lines = [
            'set DEEPSEEK_KEY=',
            'set /p DEEPSEEK_KEY="   在此粘贴 API Key（sk-xxx，直接回车跳过）："',
            'if "!DEEPSEEK_KEY!"=="" (',
            '    set /p CONFIRM="   Key为空，确认跳过配置？(Y/N): "',
            '    if /i not "!CONFIRM!"=="Y" (',
            '        echo   重新输入：',
            '        goto :input_key',
            '    )',
            '    echo   [跳过] 之后可手动创建 %%USERPROFILE%%\\.claude\\settings.json',
        ]

        lines[set_key_line:skip_line+1] = new_lines

        # Also add :input_key label before the set DEEPSEEK_KEY= line
        # Find the echo line just before set DEEPSEEK_KEY=
        label_pos = set_key_line
        lines.insert(label_pos, '')
        lines.insert(label_pos, ':input_key')

        content = '\n'.join(lines)

        with open(fpath, 'w', encoding='utf-8-sig', newline='\r\n') as f:
            f.write(content)
        print(f'[{bat_name}] DeepSeek key: added confirmation prompt')
    else:
        print(f'[{bat_name}] Could not find key input block')
        print(f'  set_key={set_key_line}, set_p={set_p_line}, skip={skip_line}')
