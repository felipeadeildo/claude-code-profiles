CURRENT_VERSION := $(shell grep '^CCP_VERSION=' src/lib/config.sh | cut -d'"' -f2)

.PHONY: install uninstall bump-patch bump-minor bump-major release

install:
	bash install.sh

uninstall:
	bash uninstall.sh

version:
	@echo "v$(CURRENT_VERSION)"

bump-patch:
	@$(MAKE) _bump PART=patch

bump-minor:
	@$(MAKE) _bump PART=minor

bump-major:
	@$(MAKE) _bump PART=major

_bump:
	@major=$$(echo "$(CURRENT_VERSION)" | cut -d. -f1); \
	minor=$$(echo "$(CURRENT_VERSION)" | cut -d. -f2); \
	patch=$$(echo "$(CURRENT_VERSION)" | cut -d. -f3); \
	case "$(PART)" in \
	  major) major=$$((major+1)); minor=0; patch=0 ;; \
	  minor) minor=$$((minor+1)); patch=0 ;; \
	  patch) patch=$$((patch+1)) ;; \
	esac; \
	new="$$major.$$minor.$$patch"; \
	sed -i "s/^CCP_VERSION=.*/CCP_VERSION=\"$$new\"/" src/lib/config.sh; \
	echo "v$(CURRENT_VERSION) -> v$$new"

release:
	@new_ver=$$(grep '^CCP_VERSION=' src/lib/config.sh | cut -d'"' -f2); \
	tag="v$$new_ver"; \
	if git rev-parse "$$tag" >/dev/null 2>&1; then \
	  echo "error: tag $$tag already exists"; exit 1; \
	fi; \
	git add src/lib/config.sh; \
	git diff --cached --quiet || git commit -m "chore: bump version to $$tag"; \
	git tag "$$tag"; \
	echo "Tagged $$tag. Push with: git push origin main --tags"
