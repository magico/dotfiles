# Mac Dotfiles

Interactive, colorful setup script for a fresh Mac. Installs dev tools, apps, themes, and system preferences in one go — no restarts needed.

## Quick Start (Brand New Mac)

1. **Open Terminal** — find it in `/Applications/Utilities/Terminal.app` or press `Cmd + Space` and type "Terminal"

2. **Clone this repo**
   ```bash
   git clone https://github.com/magico/dotfiles.git ~/dotfiles
   ```
   > On a fresh Mac, running `git` will prompt you to install Xcode Command Line Tools. Accept the prompt, wait for it to finish, then run the clone command again.

3. **Run the setup**
   ```bash
   cd ~/dotfiles
   chmod +x setup.sh
   ./setup.sh
   ```

4. **Follow the prompts** — the script will ask which steps to run, then handle everything automatically.

## What Gets Installed

| Step | What |
|------|------|
| Xcode CLI Tools | Compilers, git, and other dev essentials |
| Homebrew | macOS package manager |
| asdf | Version manager for Node.js, Python, and Ruby (latest stable of each) |
| Mac Apps | SteerMouse, iTerm2, Claude, VS Code, Sublime Merge, CleanShot X, Keynote, Pages, Numbers, Reeder, Reeder 4 |
| Dracula Theme | Applied to iTerm2 and VS Code |
| Dock | Custom layout with your preferred app order |
| macOS Settings | System preferences via `defaults write` |

## Customizing

The `config/` directory holds all your preferences. Edit these files and re-run `./setup.sh` — pick only the steps you want to re-apply.

| File | What to edit |
|------|--------------|
| `config/apps.sh` | Add or remove apps (Homebrew Cask names and Mac App Store IDs) |
| `config/dock.sh` | Change Dock app order, add spacers or folders |
| `config/macos.sh` | Add `defaults write` commands for system preferences |

## File Structure

```
├── setup.sh              Main entry point
├── lib/
│   └── utils.sh          UI helpers (colors, prompts, spinners)
├── modules/
│   ├── xcode.sh          Xcode Command Line Tools
│   ├── homebrew.sh       Homebrew
│   ├── asdf.sh           asdf + Node.js, Python, Ruby
│   ├── apps.sh           Mac apps (Cask + App Store)
│   ├── themes.sh         Dracula theme (iTerm2 + VS Code)
│   ├── dock.sh           Dock layout
│   └── macos.sh          macOS system settings
└── config/
    ├── apps.sh           App lists
    ├── dock.sh           Dock order
    └── macos.sh          macOS defaults (placeholder)
```

## Prerequisites

- A Mac running macOS Sonoma or later
- An Apple ID signed into the Mac App Store (for App Store apps)
- An internet connection

## Re-running

The script is safe to run multiple times. It skips anything already installed and only applies changes for items that are missing or different.
