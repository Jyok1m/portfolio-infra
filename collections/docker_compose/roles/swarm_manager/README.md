# jyok1m.docker_compose.swarm_manager

Initializes a Docker Swarm cluster on the first manager node, then reads back the worker/manager join tokens and the advertise address so subsequent plays can use them. Idempotent: re-runs are no-ops once the swarm is up.

## Variables

| Variable                          | Default | Description                                                                                                   |
| --------------------------------- | ------- | ------------------------------------------------------------------------------------------------------------- |
| `swarm_manager_advertise_addr`    | `""`    | Address advertised to other nodes (e.g. `192.168.1.10`). Empty → docker picks the default routable interface. |
| `swarm_manager_listen_addr`       | `""`    | Listen address for swarm traffic (default `0.0.0.0:2377` when empty).                                         |
| `swarm_manager_default_addr_pool` | `[]`    | Default address pools for overlay networks (e.g. `["10.20.0.0/16"]`).                                         |
| `swarm_manager_show_tokens`       | `true`  | When `true`, prints the worker/manager tokens via `debug` so you can copy them into your vault.               |

## Facts exposed

After the role runs, the following host facts are set on the manager node and available in `hostvars[manager_host]`:

| Fact                  | Description                                                               |
| --------------------- | ------------------------------------------------------------------------- |
| `swarm_worker_token`  | Token used by `swarm_worker` (or `docker swarm join`) to enroll a worker. |
| `swarm_manager_token` | Token used to enroll an additional manager (HA control plane).            |
| `swarm_manager_addr`  | `host:port` other nodes connect to (e.g. `192.168.1.10:2377`).            |

## Example

This is a **role**, not a module — invoke it with `import_role` (or `include_role`).

```yaml
- name: Initialize the swarm
  ansible.builtin.import_role:
    name: jyok1m.docker_compose.swarm_manager
  vars:
    swarm_manager_advertise_addr: "{{ ansible_default_ipv4.address }}"
```

Once the tokens are vaulted, silence the debug print:

```yaml
- name: Re-run the manager role idempotently
  ansible.builtin.import_role:
    name: jyok1m.docker_compose.swarm_manager
  vars:
    swarm_manager_show_tokens: false
```
