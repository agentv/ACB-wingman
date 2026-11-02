# ACB Wingman

Portable Anypoint Code Builder environment for classroom use. Spins up a clean, isolated VS Code instance with the full ACB extension pack — independent of any personal VS Code installation.

**No prerequisites required.** `setup.sh` / `setup.bat` handles everything: if VS Code and the ACB extensions are already installed on your machine they are copied locally (fast, works offline); if not, they are downloaded automatically. Internet access is only needed on the first run of a clean machine.

## How It Works

VS Code's **portable mode** stores all extensions, settings, and state in a dedicated data folder managed by this project. Every class session can be reset to a known-good baseline in seconds.

```
ACB-wingman/
├── bin/
│   ├── setup.sh / setup.bat          ← Run once to build the environment
│   ├── bootstrap.sh / bootstrap.bat  ← Auto-called by setup on a clean machine
│   ├── reset.sh / reset.bat          ← Restore clean state before each session
│   └── launch.sh / launch.bat        ← Open the portable ACB instance
├── snapshots/
│   └── clean/            ← Golden copy of extensions + settings (reset source)
├── workspace-template/   ← Default workspace opened on launch
├── Visual Studio Code.app  (macOS) ─┐ Portable VS Code — created by setup,
├── VSCode\               (Windows) ─┘ not tracked in git
└── code-portable-data/   ← Live runtime data (extensions, settings, state)
```

## Quickstart

### macOS

```bash
chmod +x bin/*.sh
bin/setup.sh
```

Setup will:
1. If VS Code is in `/Applications` — copy it into this project folder (offline, fast)
2. If VS Code is not present — download and unpack it automatically
3. If ACB extensions are in `~/.vscode/extensions` — copy them into the portable data dir
4. If extensions are not present locally — install them via `code --install-extension` (requires internet)
5. Write baseline settings (telemetry off, no auto-updates)
6. Bake a clean snapshot for resets

**Launch:**
```bash
bin/launch.sh
```
Opens at `workspace-template/` by default. Pass a path to open elsewhere:
```bash
bin/launch.sh ~/my-mule-project
```

**Reset before class:**
```bash
bin/reset.sh
```

---

### Windows

```bat
bin\setup.bat
```

Setup will:
1. If VS Code is in `%LOCALAPPDATA%\Programs\Microsoft VS Code` — copy it into this project folder as `VSCode\` (offline, fast)
2. If VS Code is not present — download the zip archive and unpack it automatically (no installer, no admin rights needed)
3. If ACB extensions are in `%USERPROFILE%\.vscode\extensions` — copy them into the portable data dir
4. If extensions are not present locally — install them via `code --install-extension` (requires internet)
5. Write baseline settings (telemetry off, no auto-updates)
6. Bake a clean snapshot for resets

**Launch:**
```bat
bin\launch.bat
```
Pass a path to open a specific folder:
```bat
bin\launch.bat C:\Users\me\my-mule-project
```

**Reset before class:**
```bat
bin\reset.bat
```

---

## Updating the Baseline

After tuning settings or installing updated extensions, re-bake the snapshot:

**macOS:**
```bash
cp -R code-portable-data/extensions snapshots/clean/extensions
cp -R code-portable-data/user-data   snapshots/clean/user-data
```

**Windows:**
```bat
xcopy /E /I /Y code-portable-data\extensions snapshots\clean\extensions
xcopy /E /I /Y code-portable-data\user-data   snapshots\clean\user-data
```

Or simply re-run `bin/setup.sh` / `bin\setup.bat` after updating extensions in your main VS Code install — it will overwrite the snapshot.

---

## Admin Usage Guide

**What it is:** A portable, self-contained Anypoint Code Builder (ACB) environment built on VS Code portable mode. Designed for classroom/lab use — isolated from any personal VS Code install, resettable to a clean baseline in seconds.

### Getting Started on a New Machine

**1. Clone the repo**
```bash
git clone https://github.com/agentv/ACB-wingman.git
cd ACB-wingman
```

**2. Run setup (once)**

macOS:
```bash
chmod +x bin/*.sh
bin/setup.sh
```
Windows:
```bat
bin\setup.bat
```

Setup is fully automatic. It detects whether VS Code and ACB extensions are already installed locally (fast, offline copy) or downloads them if not (internet required on first run only).

### Daily / Per-Session Workflow

| Task | macOS | Windows |
|---|---|---|
| Reset to clean state before class | `bin/reset.sh` | `bin\reset.bat` |
| Launch ACB | `bin/launch.sh` | `bin\launch.bat` |
| Open a specific project | `bin/launch.sh ~/path/to/project` | `bin\launch.bat C:\path\to\project` |

### Updating the Baseline

After tweaking settings or updating extensions, re-bake the snapshot so future resets use the new baseline:

```bash
bin/setup.sh   # re-run setup after updating your main VS Code install
```

Or manually copy `code-portable-data/extensions` and `code-portable-data/user-data` into `snapshots/clean/`.

### Key Points for Admins

- **No admin rights needed** — VS Code runs fully portable, no installer
- **No internet after first setup** — everything is local once bootstrapped
- **Resets are instant** — `reset.sh` / `reset.bat` restores from the `snapshots/clean/` golden copy
- **No impact on personal VS Code** — completely isolated data directory

---

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
