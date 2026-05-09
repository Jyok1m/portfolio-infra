# jyok1m.hardening.create_admin

Creates an admin user with a chosen name, adds it to the requested groups (default: `sudo`), and authorizes an SSH public key in its `~/.ssh/authorized_keys`. Optionally grants passwordless sudo via a validated drop-in in `/etc/sudoers.d/`.

## Variables

| Variable                         | Default     | Description                                                                                          |
| -------------------------------- | ----------- | ---------------------------------------------------------------------------------------------------- |
| `admin_username`                 | `""`        | **Required.** Login name of the admin account to create.                                             |
| `admin_public_key`               | `""`        | **Required.** SSH public key (one key, or several separated by newlines).                            |
| `admin_groups`                   | `[sudo]`    | Supplementary groups (appended, never replaces existing membership).                                 |
| `admin_shell`                    | `/bin/bash` | Login shell.                                                                                         |
| `admin_passwordless_sudo`        | `false`     | If true, drops `/etc/sudoers.d/90-<username>` granting `NOPASSWD:ALL` (validated with `visudo -cf`). |
| `admin_authorized_key_exclusive` | `false`     | If true, replaces the user's existing `authorized_keys` content with the provided key(s).            |

## Example

```yaml
- name: Create admin account
  ansible.builtin.import_role:
    name: jyok1m.hardening.create_admin
  vars:
    admin_username: deploy
    admin_public_key: "ssh-ed25519 AAAAC3Nza... user@host"
    admin_passwordless_sudo: true
```
