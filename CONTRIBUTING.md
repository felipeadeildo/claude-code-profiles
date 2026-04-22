# Contributing

## Requirements

`bash`, `git`, `make`, `curl`, `unzip`

## Local setup

```bash
git clone https://github.com/felipeadeildo/claude-code-profiles
cd claude-code-profiles
make install
source ~/.zshrc   # or ~/.bashrc
```

## Project structure

```
src/
  ccp.sh            # main script (sourced by the shell)
  lib/
    config.sh       # shared vars, path helpers, utilities
    commands.sh     # all ccp commands
install.sh          # installer (curl-pipe and local modes)
uninstall.sh        # uninstaller
Makefile            # install, bump, release targets
```

Installed layout (`~/.ccp/bin/`):

```
~/.ccp/bin/
  ccp               # copy of src/ccp.sh
  lib/
    config.sh
    commands.sh
```

## Commit style

Use [Conventional Commits](https://www.conventionalcommits.org/):

```
feat: add X
fix: correct Y
docs: update Z
refactor: simplify W
chore: bump version
```

## Releasing

```bash
# 1. make your changes with conventional commits

# 2. bump the version
make bump-patch     # 0.1.0 -> 0.1.1
make bump-minor     # 0.1.0 -> 0.2.0
make bump-major     # 0.1.0 -> 1.0.0

# 3. tag and push
make release
git push origin main --tags
```

GitHub Actions picks up the tag and creates the release automatically using [git-cliff](https://git-cliff.org/) for the changelog.
