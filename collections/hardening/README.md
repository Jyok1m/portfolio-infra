# jyok1m.hardening

Ansible collection providing baseline Linux hardening roles.

## Contents

| Role                              | Description                                                          |
| --------------------------------- | -------------------------------------------------------------------- |
| `jyok1m.hardening.create_admin`   | Creates an admin user and authorizes an SSH public key for it.       |
| `jyok1m.hardening.ssh_hardening`  | Renders a hardened `sshd_config` (validated before reload).          |
| `jyok1m.hardening.firewall`       | Installs and configures UFW with a deny-by-default ingress policy.   |
| `jyok1m.hardening.fail2ban`       | Installs `fail2ban` with a UFW-backed `sshd` jail.                   |

## Requirements

- Ansible `>= 2.20`
- Collection `community.general >= 12.0.0` (installed automatically)
- Debian Trixie target host with `apt`

## Installation

```bash
ansible-galaxy collection install jyok1m.hardening
```

## Quick start

Each role is a standalone unit — invoke it with `import_role` (or `include_role`) and pass its variables under `vars:`.

```yaml
- name: Create admin account
  ansible.builtin.import_role:
    name: jyok1m.hardening.create_admin
  vars:
    admin_username: deploy
    admin_public_key: "ssh-ed25519 AAAAC3Nza... user@host"

- name: Apply SSH hardening
  ansible.builtin.import_role:
    name: jyok1m.hardening.ssh_hardening
  vars:
    ssh_port: 2222
    ssh_allowed_users: [admin, deploy]

- name: Apply firewall hardening
  ansible.builtin.import_role:
    name: jyok1m.hardening.firewall
  vars:
    ufw_allowed_ports:
      - { port: 2222, proto: tcp, comment: SSH }
      - { port: 80, proto: tcp, comment: HTTP }
      - { port: 443, proto: tcp, comment: HTTPS }
    ufw_allowed_sources:
      - { src: "10.42.0.0/24", comment: "vRack intra-cluster" }

- name: Apply fail2ban hardening
  ansible.builtin.import_role:
    name: jyok1m.hardening.fail2ban
  vars:
    fail2ban_ssh_port: 2222
```

See each role's `README.md` for the full variable reference.

## Testing

A single Molecule scenario applies the three roles together inside a Debian 13 systemd container:

```bash
cd extensions
molecule test
```

## License

MIT
