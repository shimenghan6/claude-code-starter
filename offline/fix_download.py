"""Replace Invoke-WebRequest with curl.exe — simpler, more reliable on fresh Windows."""
import os

repo = r'C:\Users\shish\github-repos\claude-code-starter'

for bat_name in ['install.bat', 'offline/install-offline.bat']:
    fpath = os.path.join(repo, bat_name)
    with open(fpath, 'r', encoding='utf-8') as f:
        content = f.read()
    original = content

    # VS Code: Invoke-WebRequest -> curl.exe
    old = (
        'powershell -NoProfile -Command "Invoke-WebRequest '
        "-Uri 'https://code.visualstudio.com/sha/download?build=stable&os=win32-x64-user' "
        "-OutFile '%TEMP%\\VSCodeSetup.exe'\""
    )
    new = 'curl.exe -L -o "%TEMP%\\VSCodeSetup.exe" "https://code.visualstudio.com/sha/download?build=stable&os=win32-x64-user"'
    if old in content:
        content = content.replace(old, new)
        print(f'[{bat_name}] VS Code: Invoke-WebRequest -> curl.exe')
    else:
        print(f'[{bat_name}] VS Code: NOT FOUND — checking for variant')
        for line in content.split('\n'):
            if 'VSCodeSetup' in line:
                print(f'  [{line.strip()}]')

    # Node.js: Invoke-WebRequest -> curl.exe
    old2 = (
        'powershell -NoProfile -Command "Invoke-WebRequest '
        "-Uri 'https://nodejs.org/dist/v22.14.0/node-v22.14.0-x64.msi' "
        "-OutFile '%TEMP%\\nodejs.msi'\""
    )
    new2 = 'curl.exe -L -o "%TEMP%\\nodejs.msi" "https://nodejs.org/dist/v22.14.0/node-v22.14.0-x64.msi"'
    if old2 in content:
        content = content.replace(old2, new2)
        print(f'[{bat_name}] Node.js: Invoke-WebRequest -> curl.exe')
    else:
        print(f'[{bat_name}] Node.js: NOT FOUND')

    if content != original:
        with open(fpath, 'w', encoding='utf-8', newline='\r\n') as f:
            f.write(content)
    else:
        print(f'[{bat_name}] No changes')

print('Done')
