# jyok1m.hardening.firewall

Installs UFW, opens a configurable allow-list of ports, allows trusted source networks, and enables a deny-by-default ingress policy.

## Variables

| Variable               | Default                                                  | Description                          |
| ---------------------- | -------------------------------------------------------- | ------------------------------------ |
| `ufw_allowed_ports`    | `[{port: "22", proto: tcp, comment: SSH}]`              | List of `{port, proto, comment}` rules opened to any source. |
| `ufw_allowed_sources`  | `[]`                                                     | List of `{src, comment}` rules that allow all traffic from a CIDR (e.g. a private vRack subnet). |
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
    ufw_allowed_sources:
      - { src: "10.42.0.0/24", comment: "vRack intra-cluster" }
```

> Entries in `ufw_allowed_sources` open **all** ports to the given CIDR — use it for trusted private subnets only.
