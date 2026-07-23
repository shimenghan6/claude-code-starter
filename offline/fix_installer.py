"""Fix installer issues: remove 'call', show installer UI, suppress harmless warnings."""
import os

repo = r'C:\Users\shish\github-repos\claude-code-starter'

for bat_name in ['install.bat', 'offline/install-offline.bat']:
    fpath = os.path.join(repo, bat_name)
    with open(fpath, 'r', encoding='utf-8') as f:
        content = f.read()
    original = content

    # 1) VS Code: call powershell -> powershell, /verysilent -> (remove), show progress
    old_vscode = (
        'call powershell -Command "Invoke-WebRequest '
        "-Uri 'https://code.visualstudio.com/sha/download?build=stable&os=win32-x64-user' "
        "-OutFile '%TEMP%\\VSCodeSetup.exe'\" 2>nul"
    )
    new_vscode = (
        'powershell -NoProfile -Command "Invoke-WebRequest '
        "-Uri 'https://code.visualstudio.com/sha/download?build=stable&os=win32-x64-user' "
        "-OutFile '%TEMP%\\VSCodeSetup.exe'\""
    )
    if old_vscode in content:
        content = content.replace(old_vscode, new_vscode)
        print(f'[{bat_name}] VS Code download: call -> powershell -NoProfile')
    else:
        print(f'[{bat_name}] VS Code download: NOT FOUND')

    # VS Code install: remove /verysilent so user sees the installer
    old_vscode_run = 'start /wait "" "%TEMP%\\VSCodeSetup.exe" /verysilent /norestart'
    new_vscode_run = 'start /wait "" "%TEMP%\\VSCodeSetup.exe" /norestart'
    if old_vscode_run in content:
        content = content.replace(old_vscode_run, new_vscode_run)
        print(f'[{bat_name}] VS Code install: removed /verysilent')
    else:
        print(f'[{bat_name}] VS Code install: NOT FOUND')

    # 2) Node.js: call powershell -> powershell
    old_node = (
        'call powershell -Command "Invoke-WebRequest '
        "-Uri 'https://nodejs.org/dist/v22.14.0/node-v22.14.0-x64.msi' "
        "-OutFile '%TEMP%\\nodejs.msi'\" 2>nul"
    )
    new_node = (
        'powershell -NoProfile -Command "Invoke-WebRequest '
        "-Uri 'https://nodejs.org/dist/v22.14.0/node-v22.14.0-x64.msi' "
        "-OutFile '%TEMP%\\nodejs.msi'\""
    )
    if old_node in content:
        content = content.replace(old_node, new_node)
        print(f'[{bat_name}] Node.js download: call -> powershell -NoProfile')
    else:
        print(f'[{bat_name}] Node.js download: NOT FOUND')

    # Node.js install: /quiet -> (remove), let user see MSI progress
    old_node_run = 'start /wait msiexec /i "%TEMP%\\nodejs.msi" /quiet /norestart'
    new_node_run = 'start /wait msiexec /i "%TEMP%\\nodejs.msi" /norestart'
    if old_node_run in content:
        content = content.replace(old_node_run, new_node_run)
        print(f'[{bat_name}] Node.js install: removed /quiet')
    else:
        print(f'[{bat_name}] Node.js install: NOT FOUND')

    if content != original:
        with open(fpath, 'w', encoding='utf-8', newline='\r\n') as f:
            f.write(content)
    else:
        print(f'[{bat_name}] No changes made')

print('Done')
