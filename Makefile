.DEFAULT_GOAL := help
.PHONY: help install-collections setup-hooks

# ------------------------------------------------------------------ #
#                                Help                                #
# ------------------------------------------------------------------ #

help:
	@echo "Usage: make [target]"
	@echo ""
	@echo "Setup:"
	@echo "	install-collections		Install Ansible collections from requirements.yml"
	@echo "	setup-hooks			Install pre-commit hooks (yamllint, ansible-lint, vault)"

# ------------------------------------------------------------------ #
#                                Setup                               #
# ------------------------------------------------------------------ #

install-collections:
	ansible-galaxy collection install -r requirements.yml

setup-hooks:
	@command -v pre-commit >/dev/null 2>&1 || { echo "error: pre-commit not installed. Run: pip install pre-commit"; exit 1; }
	@git config --unset-all core.hooksPath 2>/dev/null || true
	pre-commit install --install-hooks
	@echo "Git hooks installed via pre-commit"