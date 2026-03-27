import os

replacements = {
    "AppTheme.primaryGold": "AppTheme.primary",
    "AppTheme.secondaryGold": "AppTheme.secondaryContainer",
    "AppTheme.backgroundDark": "AppTheme.background",
    "AppTheme.surfaceDark": "AppTheme.surfaceContainerLow",
    "AppTheme.accentOrange": "AppTheme.tertiary"
}

def run():
    for root, _, files in os.walk('lib'):
        for file in files:
            if file.endswith('.dart'):
                filepath = os.path.join(root, file)
                with open(filepath, 'r', encoding='utf-8') as f:
                    content = f.read()
                original_content = content
                for old, new in replacements.items():
                    content = content.replace(old, new)
                if content != original_content:
                    with open(filepath, 'w', encoding='utf-8') as f:
                        f.write(content)
                    print(f"Updated {filepath}")

if __name__ == '__main__':
    run()
