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

- Python `>= 3.10` (`python3 --version`)
- Docker (Desktop, Colima, or OrbStack — must be running for Molecule)
- A `.vault_pass` file at the repo root
- A `.env` file with `ANSIBLE_GALAXY_TOKEN=...` (only needed to publish the collections)
- SSH access to the target host configured via the variables in `inventory.yml`

## Local setup (first time)

Create a virtualenv and install the Python tooling (Ansible, lint, Molecule, pre-commit). Doing this in a venv keeps the system Python clean.

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements-dev.txt
```

Activate the venv at the start of every new shell (`source .venv/bin/activate`). Then bootstrap the repo:

```bash
make install-collections   # Pinned Ansible collections
make setup-hooks           # Pre-commit hooks (yamllint, ansible-lint, vault encrypt/decrypt)
```

## Usage

```bash
make ping                  # Smoke-test connectivity to the OVH host
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

The pre-commit hook auto-encrypts `vault.yml` before each commit if it's staged. After committing vault changes, run `make decrypt-vault` to put the working tree back into editable plaintext.

## Testing the collections

Each collection ships a single Molecule scenario under `extensions/molecule/default/`. Docker must be running.

```bash
cd collections/ansible_collections/jyok1m/hardening/extensions    && molecule test
cd collections/ansible_collections/jyok1m/docker_compose/extensions && molecule test
```

`molecule test` runs the full cycle: create container → converge (apply role) → idempotence (re-apply, fail on `changed`) → verify → destroy. While iterating, prefer the short cycle that keeps the container alive between runs:

```bash
molecule converge   # apply the role
molecule verify     # re-run assertions
molecule login      # shell into the container
molecule destroy    # cleanup when done
```

## Publishing collections

```bash
make publish-collection            # jyok1m.docker_compose
make publish-collection-hardening  # jyok1m.hardening
```

Both pull `ANSIBLE_GALAXY_TOKEN` from `.env`. Bump `version:` in the collection's `galaxy.yml` before publishing.

## License

MIT
