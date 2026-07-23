"""Add UTF-8 BOM to .bat files (required for cmd to decode Chinese chars)."""
import os

repo = r'C:\Users\shish\github-repos\claude-code-starter'
BOM = b'\xef\xbb\xbf'

for bat_name in ['install.bat', 'offline/install-offline.bat']:
    fpath = os.path.join(repo, bat_name)

    with open(fpath, 'rb') as f:
        raw = f.read()

    if raw[:3] == BOM:
        print(f'[{bat_name}] BOM already exists')
    else:
        with open(fpath, 'wb') as f:
            f.write(BOM + raw)
        print(f'[{bat_name}] BOM added')

print('Done')
