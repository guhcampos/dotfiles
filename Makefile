SHELL := /bin/bash
ANSIBLE := /opt/homebrew/bin/ansible-playbook

################################################################################
# layout:
#   dotfiles/   per-user configuration, symlinked into $HOME by scripts/link-dotfiles.sh
#   ansible/    sandbox profiles: headless accounts + per-profile on-demand
#               opencode agents (see ansible/README.md). profiles are named
#               after the NATO phonetic alphabet to keep this repository free
#               of employer/project names.
################################################################################
all: | dotfiles

.PHONY: dotfiles
dotfiles:
	./scripts/link-dotfiles.sh

.PHONY: brew
brew:
	brew bundle --file=Brewfile

################################################################################
# sandboxed workspace users + per-user on-demand opencode agents. this creates
# real macOS users and launchd daemons, so it is deliberately OPT-IN and NOT
# part of the default goal.
################################################################################
.PHONY: sandboxes
sandboxes:
	cd ansible && $(ANSIBLE) -i 'localhost,' -K sandbox-setup.playbook.yaml

.PHONY: sandbox
sandbox:
	@profile="$(word 1,$(filter-out sandbox,$(MAKECMDGOALS)))"; \
	if [ -z "$$profile" ]; then \
		echo "usage: make sandbox <profile> (one of: alfa bravo charlie)" >&2; \
		exit 1; \
	fi; \
	cd ansible && $(ANSIBLE) -i 'localhost,' -K sandbox-setup.playbook.yaml -e "sandbox_profile=$$profile"

# swallow the profile name passed after `make sandbox <profile>` so make does
# not try to run it as a target
%:
	@:


.DEFAULT_GOAL=dotfiles
