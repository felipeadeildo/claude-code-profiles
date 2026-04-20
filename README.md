# ccp - Claude Code Profiles

Switch between Claude Code setups with a single command. Different accounts, different providers, different models, each in its own profile.

No dependencies. Pure bash.

## Install

```bash
git clone https://github.com/felipeadeildo/claude-code-profiles
cd claude-code-profiles
bash install.sh
source ~/.bashrc   # or ~/.zshrc, ~/.config/fish/config.fish, etc.
```

## Quickstart

```bash
ccp new work       # create a profile (interactive wizard)
ccp work           # launch claude with that profile
ccp use work       # or: export its vars into your current shell
```

That's it. `ccp new` asks for provider, API key, and model mapping.

## How profiles work

A profile is a `.env` file under `~/.ccp/profiles/`. You name it whatever you want.

```
~/.ccp/
  profiles/
    work.env
    personal.env
    openrouter.env
  config
```

Example profile:

```bash
# ~/.ccp/profiles/work.env
CLAUDE_CONFIG_DIR=~/.ccp/config/work
ANTHROPIC_BASE_URL=https://openrouter.ai/api
ANTHROPIC_API_KEY=sk-or-...
```

`CLAUDE_CONFIG_DIR` is set automatically to `~/.ccp/config/<name>`: fully isolated settings, history, and todos per profile. Override it by editing the profile file directly.

## Commands

```
ccp new <profile>          create a profile (interactive)
ccp list                   list all profiles
ccp show <profile>         show vars (keys masked)
ccp edit <profile>         open in $EDITOR
ccp remove <profile>       delete a profile

ccp <profile>              launch claude with profile vars
ccp use <profile>          export vars into current shell
ccp run <profile> <cmd>    run any command with profile vars

ccp default [profile]      get or set the default profile
ccp doctor                 validate all profiles
```

`ccp use` vs `ccp <profile>`: use `use` when you want the vars to stick in your shell session. Use the shorthand when you just want to launch claude once.

## Providers

| Provider       | `ANTHROPIC_BASE_URL`                  | Auth                    |
|----------------|---------------------------------------|-------------------------|
| Anthropic      | (leave blank)                         | `ANTHROPIC_API_KEY`     |
| OpenRouter     | `https://openrouter.ai/api`           | `ANTHROPIC_API_KEY`     |
| z.ai (GLM)     | `https://api.z.ai/api/anthropic`      | `ANTHROPIC_AUTH_TOKEN`  |
| Kimi           | `https://api.moonshot.ai/anthropic`   | `ANTHROPIC_AUTH_TOKEN`  |
| DeepSeek       | `https://api.deepseek.com/anthropic`  | `ANTHROPIC_AUTH_TOKEN`  |
| Ollama (local) | `http://localhost:11434`              | `ANTHROPIC_AUTH_TOKEN=ollama` |

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

`ccp use` exports vars into your current shell, which only works if the script is sourced, not executed as a subprocess. That's why `install.sh` adds a `source` line to your shell rc file (`~/.bashrc`, `~/.zshrc`, etc.).

`ccp <profile>` and `ccp run` spawn a subprocess, so no sourcing needed. Vars are scoped to that command only.
