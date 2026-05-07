# jyok1m.docker_compose

Ansible collection for installing Docker and orchestrating idempotent Compose stack deployments on Debian Trixie.

## Contents

| Role                            | Description                                                                                                                      |
| ------------------------------- | -------------------------------------------------------------------------------------------------------------------------------- |
| `jyok1m.docker_compose.install` | Installs Docker Engine and the Compose v2 plugin from the official Docker apt repository (GPG-signed deb822 source).             |
| `jyok1m.docker_compose.deploy`  | Creates the app directory, renders templates, copies files, pulls images, and brings the stack up — with log capture on failure. |

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

## Testing

A minimal Molecule scenario deploys a tiny `alpine` stack inside a Debian 13 systemd container:

```bash
cd extensions
molecule test
```

## License

MIT
