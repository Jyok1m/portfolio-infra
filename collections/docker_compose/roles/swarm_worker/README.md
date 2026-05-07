# jyok1m.docker_compose.swarm_worker

Joins a host to an existing Docker Swarm as a **worker**. Uses `community.docker.docker_swarm` so it's idempotent — re-runs are no-ops once the node is already in the swarm.

## Variables

| Variable                      | Default             | Description                                                                              |
| ----------------------------- | ------------------- | ---------------------------------------------------------------------------------------- |
| `swarm_worker_token`          | `""` (**required**) | Worker join token (matches `swarm_worker_token` exposed by `swarm_manager`). Vault this. |
| `swarm_worker_manager_addr`   | `""` (**required**) | Manager address `host:port` (e.g. `10.0.0.1:2377`).                                      |
| `swarm_worker_advertise_addr` | `""`                | Optional advertise address. Empty → docker picks the routable interface.                 |

## Example — same Ansible run as the manager

```yaml
- hosts: swarm_workers
  become: true
  tasks:
    - ansible.builtin.import_role:
        name: jyok1m.docker_compose.swarm_worker
      vars:
        swarm_worker_token: "{{ hostvars[groups['swarm_managers'][0]].swarm_worker_token }}"
        swarm_worker_manager_addr: "{{ hostvars[groups['swarm_managers'][0]].swarm_manager_addr }}"
```

## Example — separate run, vaulted token

```yaml
- hosts: swarm_workers
  become: true
  tasks:
    - ansible.builtin.import_role:
        name: jyok1m.docker_compose.swarm_worker
      vars:
        swarm_worker_token: "{{ vault_swarm_worker_token }}"
        swarm_worker_manager_addr: "manager.example.com:2377"
```
