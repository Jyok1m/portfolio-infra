# jyok1m.docker_compose

Ansible collection for installing Docker and orchestrating idempotent Compose stack deployments on Debian Trixie.

## Contents

| Role                                   | Description                                                                                                                      |
| -------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------- |
| `jyok1m.docker_compose.install`        | Installs Docker Engine and the Compose v2 plugin from the official Docker apt repository (GPG-signed deb822 source).             |
| `jyok1m.docker_compose.deploy`         | Creates the app directory, renders templates, copies files, pulls images, and brings the stack up — with log capture on failure. |
| `jyok1m.docker_compose.swarm_manager`  | Initializes a Docker Swarm cluster on the first manager node and exposes the worker/manager join tokens as host facts.           |
| `jyok1m.docker_compose.swarm_worker`   | Joins a host to an existing Docker Swarm as a worker node (idempotent via `community.docker.docker_swarm`).                      |

## Requirements

- Ansible `>= 2.20`
- Collection `community.docker >= 5.2.0` (installed automatically)
- Debian Trixie target host with `apt` (for `install`)
- Docker Engine + Compose v2 plugin on the target host (for `deploy` — provided by `install`)

## Installation

```bash
ansible-galaxy collection install jyok1m.docker_compose
```

## Quick start

`deploy` is a **role**, not a module — invoke it with `import_role` (or `include_role`) and pass its variables under `vars:`.

```yaml
- name: Deploy my app
  ansible.builtin.import_role:
    name: jyok1m.docker_compose.deploy
  vars:
    docker_compose_app_name: my_app
    docker_compose_app_path: /opt/my_app
    docker_compose_templates:
      - src: docker-compose.yml.j2
        dest: docker-compose.yml
        mode: "0644"
        no_log: true
```

`src` paths in `docker_compose_templates` / `docker_compose_files` resolve against the **calling role's** `templates/` and `files/` directories.

See `roles/deploy/README.md` for the full variable reference.

## Swarm topologies

`swarm_manager` and `swarm_worker` are independent and can be invoked alone or together — topology is driven by inventory, not by extra variables.

### Manager only (single-node swarm)

```yaml
- hosts: swarm_managers
  become: true
  tasks:
    - ansible.builtin.import_role: { name: jyok1m.docker_compose.install }
    - ansible.builtin.import_role: { name: jyok1m.docker_compose.swarm_manager }
```

### Manager + worker(s) (same Ansible run)

```yaml
- hosts: all
  become: true
  tasks:
    - ansible.builtin.import_role: { name: jyok1m.docker_compose.install }

- hosts: swarm_managers
  become: true
  tasks:
    - ansible.builtin.import_role: { name: jyok1m.docker_compose.swarm_manager }

- hosts: swarm_workers
  become: true
  tasks:
    - ansible.builtin.import_role:
        name: jyok1m.docker_compose.swarm_worker
      vars:
        swarm_worker_token: "{{ hostvars[groups['swarm_managers'][0]].swarm_worker_token }}"
        swarm_worker_manager_addr: "{{ hostvars[groups['swarm_managers'][0]].swarm_manager_addr }}"
```

The worker play picks the token straight from the fact set by the manager play in the previous play of the same run — no vault round-trip needed on first provisioning.

### Workers only (join an existing swarm, separate run)

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

## Testing

Three Molecule scenarios live under `extensions/molecule/`:

| Scenario        | What it covers                                                                |
| --------------- | ----------------------------------------------------------------------------- |
| `default`       | `install` + `deploy` against a tiny alpine stack inside a Debian 13 container. |
| `swarm_manager` | `install` + `swarm_manager` (single-node swarm init).                         |
| `swarm_worker`  | `install` + `swarm_manager` + `swarm_worker` across two networked containers. |

```bash
cd extensions
molecule test --all          # all scenarios
molecule test -s swarm_worker  # one specific scenario
```

## License

MIT
