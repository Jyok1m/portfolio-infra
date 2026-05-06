INVENTORY_FILE = inventory.yml
VAULT_FILE = group_vars/portfolio_group/vault.yml
VAULT_PASSWORD_FILE = .vault_pass
TAGS ?=
ANSIBLE_ARGS = -i $(INVENTORY_FILE) --vault-password-file $(VAULT_PASSWORD_FILE) $(if $(TAGS),--tags $(TAGS))

.DEFAULT_GOAL := help
.PHONY: help install-collections setup-hooks lint ping edit-vault encrypt-vault encrypt-vault-and-stage decrypt-vault dry-run run publish-collection publish-collection-hardening

# ------------------------------------------------------------------ #
#                                Help                                #
# ------------------------------------------------------------------ #

help:
	@echo "Usage: make [target]"
	@echo ""
	@echo "Setup:"
	@echo "	install-collections		Install Ansible collections from requirements.yml"
	@echo "	setup-hooks			Install pre-commit hooks (yamllint, ansible-lint, vault)"
	@echo ""
	@echo "Tests:"
	@echo "	ping				Ping the server to check connectivity"
	@echo "	lint				Run yamllint + ansible-lint on the whole repo"
	@echo ""
	@echo "Vault:"
	@echo "	edit-vault			Edit the Ansible vault file"
	@echo "	encrypt-vault			Encrypt the Ansible vault file (idempotent)"
	@echo "	decrypt-vault			Decrypt the Ansible vault file (idempotent)"
	@echo ""
	@echo "Run:"
	@echo "	dry-run				Run the Ansible playbook in check mode with diff"
	@echo "	run				Run the Ansible playbook"
	@echo ""
	@echo "Run options:"
	@echo "	TAGS=<tag>			Filter by Ansible tags (e.g. make run TAGS=fail2ban)"
	@echo ""
	@echo "Collections:"
	@echo "	publish-collection		Build and publish jyok1m.docker_compose to Ansible Galaxy"
	@echo "	publish-collection-hardening	Build and publish jyok1m.hardening to Ansible Galaxy"

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

# ------------------------------------------------------------------ #
#                                Tests                               #
# ------------------------------------------------------------------ #

ping:
	ansible -i $(INVENTORY_FILE) ovh_host -m ping

lint:
	@command -v pre-commit >/dev/null 2>&1 || { echo "error: pre-commit not installed. Run: pip install pre-commit"; exit 1; }
	pre-commit run --all-files

# ------------------------------------------------------------------ #
#                                Vault                               #
# ------------------------------------------------------------------ #

edit-vault:
	ansible-vault edit $(VAULT_FILE) --vault-password-file $(VAULT_PASSWORD_FILE)

encrypt-vault:
	@if head -n 1 $(VAULT_FILE) 2>/dev/null | grep -q '^\$$ANSIBLE_VAULT'; then \
		echo "Vault already encrypted, skipping."; \
	else \
		ansible-vault encrypt $(VAULT_FILE) --vault-password-file $(VAULT_PASSWORD_FILE); \
	fi

encrypt-vault-and-stage: encrypt-vault
	git add $(VAULT_FILE)

decrypt-vault:
	@if head -n 1 $(VAULT_FILE) 2>/dev/null | grep -q '^\$$ANSIBLE_VAULT'; then \
		ansible-vault decrypt $(VAULT_FILE) --vault-password-file $(VAULT_PASSWORD_FILE); \
	else \
		echo "Vault already decrypted (or file missing), skipping."; \
	fi

# ------------------------------------------------------------------ #
#                                Run                                 #
# ------------------------------------------------------------------ #

dry-run:
	ansible-playbook $(ANSIBLE_ARGS) site.yml --check --diff

run:
	ansible-playbook $(ANSIBLE_ARGS) site.yml

# ------------------------------------------------------------------ #
#                             Collection                             #
# ------------------------------------------------------------------ #

publish-collection:
	./scripts/publish-collection.sh docker_compose

publish-collection-hardening:
	./scripts/publish-collection.sh hardening