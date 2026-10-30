# ACB Wingman

Portable Anypoint Code Builder environment for classroom use. Spins up a clean, isolated VS Code instance with the full ACB extension pack — independent of any personal VS Code installation.

## How It Works

VS Code's **portable mode** stores all extensions, settings, and state in a `code-portable-data` folder alongside the app. This project manages that folder so every class session starts from a known-good baseline.

```
ACB-wingman/
├── bin/
│   ├── setup.sh          ← Run once (or when rebuilding from scratch)
│   ├── reset.sh          ← Run between sessions to restore clean state
│   └── launch.sh         ← Run to open the portable ACB instance
├── snapshots/
│   └── clean/            ← Golden copy of extensions + settings
├── workspace-template/   ← Default workspace opened on launch
├── Visual Studio Code.app  ← Portable VS Code (created by setup.sh)
└── code-portable-data/   ← Live runtime data (extensions, settings, state)
```

## Quickstart

### First Time
```bash
chmod +x bin/*.sh
bin/setup.sh
```

This will:
1. Copy VS Code from `/Applications` into this project folder
2. Copy the ACB extensions from your local VS Code install
3. Write baseline settings (telemetry off, no auto-updates)
4. Bake a clean snapshot for resets

### Launch
```bash
bin/launch.sh
```

Opens the portable ACB instance at the `workspace-template` folder. Pass a path to open somewhere else:
```bash
bin/launch.sh ~/my-mule-project
```

### Reset (Before Each Class Session)
```bash
bin/reset.sh
```

Wipes `code-portable-data` and restores from the clean snapshot. Takes seconds. Students get a fresh environment.

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
