INVENTORY_FILE = inventory.yml
VAULT_FILE = group_vars/portfolio_group/vault.yml
VAULT_PASSWORD_FILE = .vault_pass
TAGS ?=
ANSIBLE_ARGS = -i $(INVENTORY_FILE) --vault-password-file $(VAULT_PASSWORD_FILE) $(if $(TAGS),--tags $(TAGS))

.DEFAULT_GOAL := help
.PHONY: help install-collections setup-hooks ping edit-vault encrypt-vault decrypt-vault dry-run run

# ------------------------------------------------------------------ #
#                                Help                                #
# ------------------------------------------------------------------ #

help:
	@echo "Usage: make [target]"
	@echo ""
	@echo "Setup:"
	@echo "	install-collections	Install Ansible collections from requirements.yml"
	@echo "	setup-hooks		Configure Git hooks for vault encryption"
	@echo ""
	@echo "Tests:"
	@echo "	ping			Ping the server to check connectivity"
	@echo ""
	@echo "Vault:"
	@echo "	edit-vault		Edit the Ansible vault file"
	@echo "	encrypt-vault		Encrypt the Ansible vault file"
	@echo "	decrypt-vault		Decrypt the Ansible vault file"
	@echo ""
	@echo "Run:"
	@echo "	dry-run			Run the Ansible playbook in check mode with diff"
	@echo "	run			Run the Ansible playbook"
	@echo ""
	@echo "Run options:"
	@echo "	TAGS=<tag>		Filter by Ansible tags (e.g. make run TAGS=fail2ban)"

# ------------------------------------------------------------------ #
#                                Setup                               #
# ------------------------------------------------------------------ #

install-collections:
	ansible-galaxy collection install -r requirements.yml

setup-hooks:
	git config core.hooksPath .githooks
	chmod +x .githooks/*
	@echo "Git hooks configured"

# ------------------------------------------------------------------ #
#                                Tests                               #
# ------------------------------------------------------------------ #

ping:
	ansible -i $(INVENTORY_FILE) ovh_host -m ping

# ------------------------------------------------------------------ #
#                                Vault                               #
# ------------------------------------------------------------------ #

edit-vault:
	ansible-vault edit $(VAULT_FILE) --vault-password-file $(VAULT_PASSWORD_FILE)

encrypt-vault:
	ansible-vault encrypt $(VAULT_FILE) --vault-password-file $(VAULT_PASSWORD_FILE)

decrypt-vault:
	ansible-vault decrypt $(VAULT_FILE) --vault-password-file $(VAULT_PASSWORD_FILE)

# ------------------------------------------------------------------ #
#                                Run                                 #
# ------------------------------------------------------------------ #

dry-run:
	ansible-playbook $(ANSIBLE_ARGS) site.yml --check --diff

run:
	ansible-playbook $(ANSIBLE_ARGS) site.yml