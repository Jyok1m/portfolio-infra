# portfolio-infra

Ansible repository that provisions and operates my single-server infrastructure on OVH (portfolio + side projects).

## What it does

Runs an end-to-end setup on the target host:

- **Hardening** — SSH, UFW firewall, Fail2ban, unattended upgrades
- **Engine** — Docker + Compose v2
- **Shared apps** — Traefik (reverse proxy + TLS), Jenkins (CI), Prometheus/Grafana (monitoring)
- **Client apps** — `portfolio`, `ipseis`
- **Test** — `mongo_test` stack

All apps are deployed as Docker Compose stacks, fronted by Traefik.

## Layout

```
.
├── site.yml              # Main playbook (ordered roles)
├── inventory.yml         # Single host: ovh_host
├── group_vars/           # Vault-encrypted variables
├── roles/                # Local roles (per-stack)
├── collections/          # Vendored Ansible collections
├── requirements.yml      # Pinned collection versions
├── scripts/              # Tooling (Galaxy publish, etc.)
└── Makefile              # Common entry points
```

The `jyok1m.docker_compose` collection (vendored under `collections/`) provides the reusable `deploy` role for Compose stacks.

## Requirements

- Ansible `>= 2.20`
- A `.vault_pass` file at the repo root
- A `.env` file with `ANSIBLE_GALAXY_TOKEN=...` (only needed to publish the collection)
- SSH access to the target host configured via the variables in `inventory.yml`

## Usage

```bash
make install-collections   # Install pinned collections
make setup-hooks           # Enable the vault encrypt/decrypt git hooks
make ping                  # Smoke-test connectivity
make dry-run               # Run the playbook in --check --diff mode
make run                   # Run the playbook
make run TAGS=traefik      # Run a single role
```

Vault helpers:

```bash
make edit-vault
make encrypt-vault
make decrypt-vault
```

Publish the local Ansible collection to Galaxy:

```bash
make publish-collection
```

## License

MIT
