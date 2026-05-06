# jyok1m.hardening.fail2ban

Installs fail2ban and renders a `/etc/fail2ban/jail.local` with a UFW-backed `sshd` jail.

## Variables

| Variable                | Default | Description                                   |
| ----------------------- | ------- | --------------------------------------------- |
| `fail2ban_max_retry`    | `5`     | Failed attempts before a ban.                 |
| `fail2ban_ban_time`     | `3600`  | Ban duration in seconds.                      |
| `fail2ban_find_time`    | `600`   | Window in which `maxretry` is counted (sec).  |
| `fail2ban_ban_action`   | `ufw`   | Action used to ban (`ufw`, `iptables`, ...).  |
| `fail2ban_ssh_port`     | `22`    | Port watched by the `sshd` jail.              |
| `fail2ban_ssh_enabled`  | `true`  | Enable the `sshd` jail.                       |

## Example

```yaml
- role: jyok1m.hardening.fail2ban
  vars:
    fail2ban_ssh_port: 2222
    fail2ban_ban_time: 7200
```
