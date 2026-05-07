# jyok1m.hardening.firewall

Installs UFW, opens a configurable allow-list of ports, and enables a deny-by-default ingress policy.

## Variables

| Variable               | Default                                                  | Description                          |
| ---------------------- | -------------------------------------------------------- | ------------------------------------ |
| `ufw_allowed_ports`    | `[{port: "22", proto: tcp, comment: SSH}]`              | List of `{port, proto, comment}` rules. |
| `ufw_default_incoming` | `deny`                                                   | Default ingress policy.              |
| `ufw_default_outgoing` | `allow`                                                  | Default egress policy.               |
| `ufw_logging`          | `low`                                                    | UFW logging level (`off`/`low`/`medium`/`high`/`full`). |

## Example

```yaml
- name: Apply firewall hardening
  ansible.builtin.import_role:
    name: jyok1m.hardening.firewall
  vars:
    ufw_allowed_ports:
      - { port: 2222, proto: tcp, comment: SSH }
      - { port: 80, proto: tcp, comment: HTTP }
      - { port: 443, proto: tcp, comment: HTTPS }
```
