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

The installer discovers the `.workflow` bundles under `Library/Services` and presents an interactive menu:

```text
Automations in Library/Services:

  1) Compare with Meld
  2) Create New File Here
  3) Open in IntelliJ IDEA
  4) Open in VS Code Insiders

  a) All
  q) Quit

Select automations (e.g. 1,3 or a):
```

Choose one or more numbers, separated by commas or spaces, or choose `a` to install everything. The selected workflows are copied into:

```text
~/Library/Services
```

Running the installer again is safe. Existing workflows with the same names are replaced; unrelated services in `~/Library/Services` are left untouched.

### Non-interactive install

To install everything without showing the selection menu:

```bash
./install.sh --all
```

### Dry run

You can preview an interactive selection without changing anything:

```bash
./install.sh --dry-run
```

Or preview installing everything:

```bash
./install.sh --all --dry-run
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
