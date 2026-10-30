# ACB Wingman

Portable Anypoint Code Builder environment for classroom use. Spins up a clean, isolated VS Code instance with the full ACB extension pack — independent of any personal VS Code installation.

**No prerequisites required.** On a clean machine with no VS Code installed, `setup.sh` / `setup.bat` will download VS Code and install the ACB extensions automatically. Internet access required for a first run on a clean machine.

## How It Works

VS Code's **portable mode** stores all extensions, settings, and state in a `code-portable-data` folder alongside the app. This project manages that folder so every class session starts from a known-good baseline.

```
ACB-wingman/
├── bin/
│   ├── setup.sh          ← Run once (downloads VS Code + ACB if needed)
│   ├── bootstrap.sh      ← Called by setup.sh on a clean machine (macOS)
│   ├── reset.sh          ← Run between sessions to restore clean state
│   └── launch.sh         ← Run to open the portable ACB instance
├── snapshots/
│   └── clean/            ← Golden copy of extensions + settings
├── workspace-template/   ← Default workspace opened on launch
├── Visual Studio Code.app  ← Portable VS Code (created by setup.sh)
└── code-portable-data/   ← Live runtime data (extensions, settings, state)
```

## Quickstart

### macOS — First Time
```bash
chmod +x bin/*.sh
bin/setup.sh
```

This will:
1. Copy VS Code from `/Applications` into this project folder
2. Copy the ACB extensions from your local VS Code install (`~/.vscode/extensions`)
3. Write baseline settings (telemetry off, no auto-updates)
4. Bake a clean snapshot for resets

### macOS — Launch
```bash
bin/launch.sh
```

Opens the portable ACB instance at the `workspace-template` folder. Pass a path to open somewhere else:
```bash
bin/launch.sh ~/my-mule-project
```

### macOS — Reset (Before Each Class Session)
```bash
bin/reset.sh
```

---

### Windows — First Time
```bat
bin\setup.bat
```

This will:
1. Copy VS Code from `%LOCALAPPDATA%\Programs\Microsoft VS Code` into this project folder as `VSCode\`
2. Copy the ACB extensions from your local VS Code install (`%USERPROFILE%\.vscode\extensions`)
3. Write baseline settings (telemetry off, no auto-updates)
4. Bake a clean snapshot for resets

> **Prerequisite:** VS Code must be installed via the standard [User Installer](https://code.visualstudio.com/download) and the ACB extension pack must be installed in it before running setup.

### Windows — Launch
```bat
bin\launch.bat
```

Pass a path to open a specific folder:
```bat
bin\launch.bat C:\Users\me\my-mule-project
```

### Windows — Reset (Before Each Class Session)
```bat
bin\reset.bat
```

---

## Updating the Baseline

After you've tuned settings or pinned new extension versions:

```bash
# Manually overwrite the snapshot with current state
cp -R code-portable-data/extensions snapshots/clean/extensions
cp -R code-portable-data/user-data   snapshots/clean/user-data
```

Or re-run `bin/setup.sh` after updating extensions in your main VS Code install.

## ACB Extensions Included

| Extension | Version |
|---|---|
| salesforce.mule-dx-extension-pack | 1.18.0 |
| salesforce.mule-dx-vscode | 5.14.4 |
| salesforce.mule-dx-mule-dev-component | 3.27.5 |
| salesforce.mule-dx-runtime | 1.0.3 |
| salesforce.mule-dx-api-component | 4.18.0 |
| salesforce.mule-dx-apikit-component | 1.3.3 |
| salesforce.mule-dx-data-weave-client | 2.12.1 |
| salesforce.mule-dx-dependencies | 1.6.2 |
| salesforce.mule-dx-munit-component | 1.3.11 |
