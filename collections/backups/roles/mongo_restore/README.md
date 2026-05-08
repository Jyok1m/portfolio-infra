# jyok1m.backups.mongo_restore

Installs a restore script that fetches a restic snapshot and pipes it into `mongorestore` against a running Mongo container. Manual invocation only — no timer.

## Behavior

For a given `mongo_restore_name`, the role lays down:

| Path                                     | Purpose                                                             |
| ---------------------------------------- | ------------------------------------------------------------------- |
| `/usr/local/bin/mongo-restore-<name>.sh` | Restore script (`0750 root:root`)                                   |
| `/etc/mongo-restore-<name>.env`          | Restic + Mongo credentials sourced by the script (`0600 root:root`) |
| `/var/backups/mongo/<name>/restore/`     | Local working directory (`0700 root:root`)                          |

The script:

1. Resolves the requested snapshot (`latest` or a snapshot ID) against the restic repo.
2. Restores the archive into a per-invocation working directory.
3. Prompts for confirmation, then runs `mongorestore` from inside an ephemeral `mongo` container on the target docker network.
4. Cleans the working directory on success.

## Variables

| Variable                        | Default                             | Description                                                     |
| ------------------------------- | ----------------------------------- | --------------------------------------------------------------- |
| `mongo_restore_name`            | _(required)_                        | Identifier — should match the `mongo_dump_name` of the source.  |
| `mongo_restore_container`       | `<name>-db`                         | Target Mongo container hostname.                                |
| `mongo_restore_network`         | `<name>-internal`                   | Docker network shared with the target Mongo.                    |
| `mongo_restore_image`           | `mongo:8.2.5`                       | Image used to invoke `mongorestore`.                            |
| `mongo_restore_port`            | `27017`                             | Mongo TCP port.                                                 |
| `mongo_restore_username`        | _(required)_                        | Mongo user with restore privileges.                             |
| `mongo_restore_password`        | _(required)_                        | Mongo user password (vault).                                    |
| `mongo_restore_authdb`          | `admin`                             | Authentication database.                                        |
| `mongo_restore_db`              | `""`                                | Restrict the restore to a single database (`--nsInclude db.*`). |
| `mongo_restore_local_dir`       | `/var/backups/mongo/<name>/restore` | Local working directory.                                        |
| `mongo_restore_restic_repo`     | _(required)_                        | Restic repository URL (typically same as the dump role).        |
| `mongo_restore_restic_password` | _(required)_                        | Restic password (vault).                                        |
| `mongo_restore_restic_env`      | `{}`                                | Extra env vars for the restic backend.                          |
| `mongo_restore_packages`        | `[restic]`                          | Packages installed via apt.                                     |

## Example

```yaml
- name: Install <app_name> restore tooling
  ansible.builtin.import_role:
    name: jyok1m.backups.mongo_restore
  vars:
    mongo_restore_name: <app_name>
    mongo_restore_username: "{{ <app_name>_db_user }}"
    mongo_restore_password: "{{ <app_name>_db_password }}"
    mongo_restore_restic_repo: "s3:https://s3.gra.io.cloud.ovh.net/<bucket>"
    mongo_restore_restic_password: "{{ restic_password }}"
    mongo_restore_restic_env:
      AWS_ACCESS_KEY_ID: "{{ s3_access_key_<app_name> }}"
      AWS_SECRET_ACCESS_KEY: "{{ s3_secret_key<app_name> }}"
```

On the host:

```bash
# inspect available snapshots
sudo bash -c '. /etc/mongo-restore-<app_name>.env && restic snapshots --tag <app_name>'

# restore the most recent snapshot (interactive confirmation)
sudo mongo-restore-<app_name>.sh latest

# restore a specific snapshot, dropping existing collections first
sudo mongo-restore-<app_name>.sh 1a2b3c4d --drop

# scripted, no prompt
sudo mongo-restore-<app_name>.sh latest --yes
```
