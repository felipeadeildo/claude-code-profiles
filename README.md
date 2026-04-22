<div align="center">

  <img src="banner.png" alt="ccp - Claude Code Profiles" width="400" />

  <h1>ccp: Claude Code Profiles</h1>

  <p>Switch between Claude Code setups with a single command. Different accounts, different providers, different models: each in its own profile.</p>

  <p>No dependencies. Pure bash.</p>

  [![Version](https://img.shields.io/github/v/release/felipeadeildo/claude-code-profiles?label=version&color=58a6ff)](https://github.com/felipeadeildo/claude-code-profiles/releases/latest)
  [![License](https://img.shields.io/github/license/felipeadeildo/claude-code-profiles?color=3fb950)](LICENSE)

</div>

## Install

```bash
curl -fsSL https://raw.githubusercontent.com/felipeadeildo/claude-code-profiles/main/install.sh | bash
source ~/.bashrc   # or ~/.zshrc
```

## Quickstart

```bash
ccp new work       # create a profile (interactive wizard)
ccp work           # launch claude with that profile
ccp use work       # or: export its vars into your current shell
```

`ccp new` asks for provider, API key, and model mapping. That's it.

## How profiles work

A profile is a `.env` file under `~/.ccp/profiles/`. Each profile gets an isolated `CLAUDE_CONFIG_DIR`: separate settings, history, and todos.

```
~/.ccp/
  profiles/
    work.env
    personal.env
    openrouter.env
  config          # stores default profile name
  data/           # isolated CLAUDE_CONFIG_DIR per profile
```

Example profile:

```bash
# ~/.ccp/profiles/work.env
CLAUDE_CONFIG_DIR=~/.ccp/data/work
ANTHROPIC_BASE_URL=https://openrouter.ai/api
ANTHROPIC_API_KEY=sk-or-...
```

## Commands

```
ccp list                   list all profiles
ccp new <profile>          create a profile (interactive)
ccp show <profile>         show vars (keys masked)
ccp edit <profile>         open in $EDITOR
ccp remove <profile>       delete a profile

ccp <profile>              launch claude with profile vars
ccp use <profile>          export vars into current shell
ccp run <profile> <cmd>    run any command with profile vars

ccp default [profile]      get or set the default profile
ccp doctor                 validate all profiles
ccp version                show current version
ccp update                 update to the latest release
```

**`ccp use` vs `ccp <profile>`**: use `use` when you want vars to stick in your shell session. Use the shorthand to launch claude once.

**Default profile**: `ccp default work` makes `work` the profile used when you run bare `ccp`.

## Providers

| Provider       | `ANTHROPIC_BASE_URL`                   | Auth                          |
|----------------|----------------------------------------|-------------------------------|
| Anthropic      | (leave blank)                          | `ANTHROPIC_API_KEY`           |
| OpenRouter     | `https://openrouter.ai/api`            | `ANTHROPIC_API_KEY`           |
| z.ai (GLM)     | `https://api.z.ai/api/anthropic`       | `ANTHROPIC_AUTH_TOKEN`        |
| Kimi           | `https://api.moonshot.ai/anthropic`    | `ANTHROPIC_AUTH_TOKEN`        |
| DeepSeek       | `https://api.deepseek.com/anthropic`   | `ANTHROPIC_AUTH_TOKEN`        |
| Ollama (local) | `http://localhost:11434`               | `ANTHROPIC_AUTH_TOKEN=ollama` |

z.ai, Kimi, and DeepSeek use `ANTHROPIC_AUTH_TOKEN` instead of `ANTHROPIC_API_KEY`. The wizard sets the right var automatically.

## Model mapping

Claude Code always requests `claude-opus`, `claude-sonnet`, etc. internally. If your provider uses different model names, map them in the profile:

```bash
ANTHROPIC_DEFAULT_OPUS_MODEL=glm-4.6
ANTHROPIC_DEFAULT_SONNET_MODEL=glm-4.6
ANTHROPIC_DEFAULT_HAIKU_MODEL=glm-4.5-air
```

The wizard asks for these optionally when creating a profile.

## `ccp use` requires sourcing

`ccp use` exports vars into your current shell, which only works if the script is sourced. That's why `install.sh` adds a `source` line to your shell rc file.

`ccp <profile>` and `ccp run` spawn a subprocess: vars are scoped to that command only.

## Updating

```bash
ccp update    # downloads and installs the latest release
ccp version   # show current version
```

ccp checks for updates in the background on each invocation and notifies you when a new version is available.

## Development

Requirements: `bash`, `git`, `make`, `curl`, `unzip`.

```bash
git clone https://github.com/felipeadeildo/claude-code-profiles
cd claude-code-profiles
make install        # installs from local source
```

Releasing a new version:

```bash
# 1. make your changes with conventional commits
#    feat: ...   fix: ...   docs: ...

# 2. bump the version
make bump-patch     # 0.1.0 -> 0.1.1
make bump-minor     # 0.1.0 -> 0.2.0
make bump-major     # 0.1.0 -> 1.0.0

# 3. tag and push
make release
git push origin main --tags
# GitHub Actions creates the release automatically via git-cliff
```
