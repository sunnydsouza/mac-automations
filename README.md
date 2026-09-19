# mac-automations

A small collection of macOS Finder Services / Automator Quick Actions.

The repository mirrors the location used by macOS:

```text
Library/
└── Services/
    ├── Compare with Meld.workflow
    ├── Create New File Here.workflow
    ├── Open in IntelliJ IDEA.workflow
    └── Open in VS Code Insiders.workflow
```

## Included services

- **Compare with Meld** — select exactly two files or folders in Finder and open them in Meld.
- **Create New File Here** — create a named file in the selected folder, beside the selected file, or in the current Finder folder when nothing is selected.
- **Open in IntelliJ IDEA** — open the selected Finder items (or current Finder folder) in IntelliJ IDEA. It tries IntelliJ IDEA Ultimate first and then Community Edition.
- **Open in VS Code Insiders** — open the selected Finder items (or current Finder folder) in Visual Studio Code - Insiders.

## Install

Clone the repository and run:

```bash
./install.sh
```

The installer copies every `.workflow` bundle from `Library/Services` into:

```text
~/Library/Services
```

Running the installer again is safe. Existing workflows with the same names are replaced; unrelated services in `~/Library/Services` are left untouched.

You can also inspect what would be installed without changing anything:

```bash
./install.sh --dry-run
```

## Requirements

- macOS
- **Meld** in `/Applications/Meld.app` for **Compare with Meld**
- **IntelliJ IDEA** or **IntelliJ IDEA CE** for **Open in IntelliJ IDEA**
- **Visual Studio Code - Insiders** for **Open in VS Code Insiders**

**Create New File Here** has no third-party application dependency.

## After installation

The workflows should become available as Finder Services / Quick Actions. If one is not visible, check **System Settings → Keyboard → Keyboard Shortcuts → Services** and enable it there. In some macOS versions, relaunching Finder or signing out and back in may be required before newly installed Services appear.

## Updating

Pull the latest changes and run the installer again:

```bash
git pull
./install.sh
```

The repository remains the source of truth; `~/Library/Services` is the installed copy.
