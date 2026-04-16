INVENTORY_FILE = inventory.yml
VAULT_FILE = group_vars/portfolio_group/vault.yml
VAULT_PASSWORD_FILE = .vault_pass

encrypt-vault:
	ansible-vault encrypt $(VAULT_FILE) --vault-password-file $(VAULT_PASSWORD_FILE)

decrypt-vault:
	ansible-vault decrypt $(VAULT_FILE) --vault-password-file $(VAULT_PASSWORD_FILE)

edit-vault:
	ansible-vault edit $(VAULT_FILE) --vault-password-file $(VAULT_PASSWORD_FILE)

ping:
	ansible -i $(INVENTORY_FILE) ovh_host -m ping

setup-hooks:
	git config core.hooksPath .githooks
	chmod +x .githooks/*
	@echo "Git hooks configured"

help:
	@echo "Usage: make [target]"
	@echo "Targets:"
	@echo "	encrypt-vault	Encrypt the Ansible vault file"
	@echo "	decrypt-vault	Decrypt the Ansible vault file"
	@echo "	edit-vault	Edit the Ansible vault file"
	@echo "	ping		Ping the server to check connectivity"
	@echo "	setup-hooks	Configure Git hooks for vault encryption"

.DEFAULT_GOAL := help
.PHONY: edit-vault help ping encrypt-vault decrypt-vault setup-hooks
