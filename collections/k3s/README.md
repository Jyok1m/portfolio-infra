# jyok1m.k3s

Ansible collection for installing and configuring [k3s](https://k3s.io/) on Debian Trixie. Two **independent** roles — server (control plane) and agent (worker) — that can be invoked alone or together. Topology (single-node, master + worker(s), agents joining an existing master) is driven by inventory groups, not by extra variables.

## Contents

| Role                | Description                                                                              |
| ------------------- | ---------------------------------------------------------------------------------------- |
| `jyok1m.k3s.server` | Installs k3s in server mode via the official `get.k3s.io` script. Idempotent on version. |
| `jyok1m.k3s.agent`  | Installs k3s in agent mode and joins an existing server. Idempotent on version.          |

## Requirements

- Ansible `>= 2.20`
- Debian Trixie target host with `apt`
- Outbound HTTPS to `get.k3s.io` (and to the k3s API on port `6443` for agents)

## Installation

```bash
ansible-galaxy collection install jyok1m.k3s
```

## Topologies

The two roles are **fully independent** — `jyok1m.k3s.server` and `jyok1m.k3s.agent` have no implicit coupling and can be invoked together, separately, in the same Ansible run, or in completely separate runs. Topology is driven entirely by your inventory and which plays you include.

### Server only (single-node cluster, or control plane to grow later)

```yaml
- hosts: k3s_servers
  become: true
  tasks:
    - ansible.builtin.import_role:
        name: jyok1m.k3s.server
```

A single-node k3s server already schedules workloads on itself — useful for dev, edge, or before adding workers.

### Master + worker(s) (same Ansible run)

```yaml
# inventory.yml
all:
  children:
    k3s_servers:
      hosts:
        node1:
    k3s_agents:
      hosts:
        node2:
        node3:
```

```yaml
- hosts: k3s_servers
  become: true
  tasks:
    - ansible.builtin.import_role:
        name: jyok1m.k3s.server

- hosts: k3s_agents
  become: true
  tasks:
    - ansible.builtin.import_role:
        name: jyok1m.k3s.agent
      vars:
        k3s_agent_server_url: "https://{{ hostvars[groups['k3s_servers'][0]].ansible_host }}:6443"
        k3s_agent_token: "{{ hostvars[groups['k3s_servers'][0]].k3s_server_node_token }}"
```

The agent play picks the token straight from the fact set by the server play in the previous play of the same run — no vault round-trip needed on first provisioning. For more workers, just add hosts under `k3s_agents`; Ansible fans out in parallel.

### Agents only (join an existing master, separate run)

```yaml
- hosts: k3s_agents
  become: true
  tasks:
    - ansible.builtin.import_role:
        name: jyok1m.k3s.agent
      vars:
        k3s_agent_server_url: "https://master.example.com:6443"
        k3s_agent_token: "{{ k3s_token }}"
```

The server isn't part of this run, so the token has to come from somewhere — typically your vault, populated once from the debug output the server role printed on first install (see `roles/server/README.md`).

## Quick start

Each role is a standalone unit — invoke it with `import_role` (or `include_role`) and pass its variables under `vars:`. See `roles/server/README.md` and `roles/agent/README.md` for the full variable reference.

## Testing

A minimal Molecule scenario installs the server role inside a Debian 13 systemd container, with the install script set to skip starting the service (k3s in DinD is unreliable; the meaningful check is that the binary and systemd unit are correctly laid down):

```bash
cd extensions
molecule test
```

## License

MIT
