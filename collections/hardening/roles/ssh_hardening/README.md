# jyok1m.hardening.ssh_hardening

Renders a hardened `/etc/ssh/sshd_config` and reloads sshd safely (the template runs `sshd -t -f %s` via the `validate` parameter before writing).

## Variables

| Variable                       | Default | Description                                     |
| ------------------------------ | ------- | ----------------------------------------------- |
| `ssh_port`                     | `22`    | Port sshd listens on.                           |
| `ssh_allowed_users`            | `[]`    | List of users allowed to log in. Empty = no `AllowUsers` directive (everyone). |
| `ssh_max_auth_tries`           | `5`     | Maximum auth attempts per connection.           |
| `ssh_login_grace_time`         | `30`    | Seconds before unauthenticated connection drop. |
| `ssh_client_alive_interval`    | `120`   | Keepalive interval (seconds).                   |
| `ssh_client_alive_count_max`   | `2`     | Keepalive misses before disconnect.             |
| `ssh_x11_forwarding`           | `false` | Enable X11 forwarding.                          |
| `ssh_tcp_forwarding`           | `true`  | Enable TCP forwarding.                          |
| `ssh_remove_cloud_init_dropin` | `true`  | Remove `/etc/ssh/sshd_config.d/50-cloud-init.conf` if present. |

## Example

```yaml
- name: Apply SSH hardening
  ansible.builtin.import_role:
    name: jyok1m.hardening.ssh_hardening
  vars:
    ssh_port: 2222
    ssh_allowed_users: [admin, deploy]
```
