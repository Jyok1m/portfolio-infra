# jyok1m.docker_compose.deploy

Deploys a Docker Compose stack: provisions the target directory, renders Jinja templates, copies static files, pulls images, and brings the stack up. On failure, captures container logs and fails the play.

## Variables

### Required

| Variable                  | Description                                               |
| ------------------------- | --------------------------------------------------------- |
| `docker_compose_app_name` | Logical app name (used in messages and the default path). |

### Optional

| Variable                        | Default                                                           | Description                                                |
| ------------------------------- | ----------------------------------------------------------------- | ---------------------------------------------------------- |
| `docker_compose_app_path`       | `{{ app_path \| default('/opt') }}/{{ docker_compose_app_name }}` | Deployment path on the target host.                        |
| `docker_compose_dir_mode`       | `"0755"`                                                          | Directory permissions.                                     |
| `docker_compose_templates`      | `[]`                                                              | List of `{src, dest, mode?, no_log?}` rendered with Jinja. |
| `docker_compose_files`          | `[]`                                                              | List of `{src, dest, mode?}` copied as-is.                 |
| `docker_compose_pull`           | `true`                                                            | Pull images before bringing the stack up.                  |
| `docker_compose_remove_orphans` | `true`                                                            | Remove orphan containers.                                  |
| `docker_compose_wait_timeout`   | `120`                                                             | Healthcheck wait timeout in seconds.                       |
| `docker_compose_logs_tail`      | `100`                                                             | Number of log lines captured on failure.                   |

## Example

This is a **role**, not a module. Invoke it with `import_role` (or `include_role`) and pass variables under `vars:`.

```yaml
- name: Deploy my-app
  ansible.builtin.import_role:
    name: jyok1m.docker_compose.deploy
  vars:
    docker_compose_app_name: my-app
    docker_compose_templates:
      - src: docker-compose.yml.j2
        dest: docker-compose.yml
        mode: "0644"
        no_log: true
    docker_compose_files:
      - src: configs/nginx.conf
        dest: configs/nginx.conf
```

`src` paths resolve against the calling role's `templates/` and `files/` directories.
