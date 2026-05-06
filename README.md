# portfolio-infra

Ansible repository that provisions and operates my single-server infrastructure on OVH (portfolio + side projects).

## What it does

Runs an end-to-end setup on the target host:

- **Hardening** — SSH (`jyok1m.hardening.ssh_hardening`), UFW (`jyok1m.hardening.firewall`), Fail2ban (`jyok1m.hardening.fail2ban`), unattended upgrades
- **Engine** — Docker + Compose v2
- **Shared apps** — Traefik (reverse proxy + TLS), Jenkins (CI), Prometheus/Grafana (monitoring)
- **Client apps** — `portfolio`, `ipseis`
- **Test** — `mongo_test` stack

All apps are deployed as Docker Compose stacks via `jyok1m.docker_compose.deploy`, fronted by Traefik.

## Layout

```
.
├── site.yml                # Main playbook (ordered roles)
├── inventory.yml           # Single host: ovh_host
├── group_vars/             # Vault-encrypted variables
├── roles/                  # Local roles (per-stack apps)
├── collections/            # Vendored Ansible collections (jyok1m.*)
├── requirements.yml        # Pinned collection versions
├── requirements-dev.txt    # Python tooling (lint, molecule, pre-commit)
├── scripts/                # Tooling (Galaxy publish, etc.)
├── .pre-commit-config.yaml # yamllint + ansible-lint + vault hooks
├── .yamllint               # yamllint configuration
├── .ansible-lint           # ansible-lint configuration
└── Makefile                # Common entry points
```

The `jyok1m.docker_compose` collection (vendored under `collections/`) provides the reusable `deploy` role for Compose stacks. The `jyok1m.hardening` collection (also vendored) ships the `ssh_hardening`, `firewall`, and `fail2ban` roles, with a single Molecule scenario under `extensions/molecule/default/`.

## Requirements

- Ansible `>= 2.20`
- Python tooling: `pip install -r requirements-dev.txt`
- A `.vault_pass` file at the repo root
- A `.env` file with `ANSIBLE_GALAXY_TOKEN=...` (only needed to publish the collections)
- SSH access to the target host configured via the variables in `inventory.yml`

## Usage

```bash
make install-collections   # Install pinned collections
make setup-hooks           # Install pre-commit hooks
make ping                  # Smoke-test connectivity
make lint                  # Run yamllint + ansible-lint over the repo
make dry-run               # Run the playbook in --check --diff mode
make run                   # Run the playbook
make run TAGS=traefik      # Run a single role
```

Vault helpers (idempotent — no-op when already in the target state):

```bash
make edit-vault
make encrypt-vault
make decrypt-vault
```

## Testing the hardening collection

```bash
cd collections/ansible_collections/jyok1m/hardening/extensions
molecule test
```

## Publishing collections

```bash
make publish-collection            # jyok1m.docker_compose
make publish-collection-hardening  # jyok1m.hardening
```

Both pull `ANSIBLE_GALAXY_TOKEN` from `.env`. Bump `version:` in the collection's `galaxy.yml` before publishing.

## License

MIT
