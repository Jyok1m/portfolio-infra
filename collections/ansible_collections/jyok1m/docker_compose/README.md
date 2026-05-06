# jyok1m.docker_compose

Ansible collection for idempotent Docker Compose stack deployments.

## Contents

| Role                           | Description                                                                                                                      |
| ------------------------------ | -------------------------------------------------------------------------------------------------------------------------------- |
| `jyok1m.docker_compose.deploy` | Creates the app directory, renders templates, copies files, pulls images, and brings the stack up — with log capture on failure. |

## Requirements

- Ansible `>= 2.20`
- Collection `community.docker >= 5.2.0` (installed automatically)
- Docker Engine + Compose v2 plugin on target hosts

## Installation

```bash
ansible-galaxy collection install jyok1m.docker_compose
```

## Quick start

```yaml
- name: Deploy my app
  jyok1m.docker_compose.deploy:
    docker_compose_app_name: my_app
    docker_compose_app_path: /opt/my_app
    docker_compose_templates:
      - src: docker-compose.yml.j2
        dest: docker-compose.yml
        mode: "0644"
        no_log: true
```

See `roles/deploy/README.md` for the full variable reference.

## License

MIT
