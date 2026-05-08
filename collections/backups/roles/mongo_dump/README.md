# jyok1m.backups.mongo_dump

Schedules logical Mongo dumps via `mongodump`, encrypts them with restic, and pushes them to an off-site repository on a systemd timer. Old archives are pruned by restic; the most recent local copies are kept for fast same-day restores.

## Behavior

For a given `mongo_dump_name`, the role lays down:

| Path                                            | Purpose                                                           |
| ----------------------------------------------- | ----------------------------------------------------------------- |
| `/usr/local/bin/mongo-dump-<name>.sh`           | Dump + restic push + retention script (`0750 root:root`)          |
| `/etc/mongo-dump-<name>.env`                    | Restic + Mongo credentials sourced by the unit (`0600 root:root`) |
| `/etc/systemd/system/mongo-dump-<name>.service` | Oneshot unit                                                      |
| `/etc/systemd/system/mongo-dump-<name>.timer`   | Schedule (default: daily, randomized 30 min, `Persistent=true`)   |
| `/var/backups/mongo/<name>/`                    | Local staging directory (`0700 root:root`)                        |

The dump is produced by running an ephemeral `mongo` container on the same docker network as the target Mongo, so no Mongo client is needed on the host. Only `restic` is installed by the role itself.

## Variables

| Variable                      | Default                     | Description                                                                                                   |
| ----------------------------- | --------------------------- | ------------------------------------------------------------------------------------------------------------- |
| `mongo_dump_name`             | _(required)_                | Unique identifier — used to name the script/units/env file.                                                   |
| `mongo_dump_container`        | `<name>-db`                 | Mongo container hostname inside the docker network.                                                           |
| `mongo_dump_network`          | `<name>-internal`           | Docker network shared with the Mongo container.                                                               |
| `mongo_dump_image`            | `mongo:8.2.5`               | Image used to invoke `mongodump`.                                                                             |
| `mongo_dump_port`             | `27017`                     | Mongo TCP port.                                                                                               |
| `mongo_dump_username`         | _(required)_                | Mongo user with backup privileges.                                                                            |
| `mongo_dump_password`         | _(required)_                | Password for the Mongo user (vault).                                                                          |
| `mongo_dump_authdb`           | `admin`                     | Authentication database.                                                                                      |
| `mongo_dump_db`               | `""`                        | Restrict the dump to a single database (empty = all).                                                         |
| `mongo_dump_local_dir`        | `/var/backups/mongo/<name>` | Local staging directory for the archive.                                                                      |
| `mongo_dump_local_keep`       | `2`                         | Number of recent local archives kept after a successful push.                                                 |
| `mongo_dump_restic_repo`      | _(required)_                | Restic repository URL (e.g. `s3:https://s3.gra.io.cloud.ovh.net/bucket`, `sftp:user@host:repo`).              |
| `mongo_dump_restic_password`  | _(required)_                | Restic repository password (vault).                                                                           |
| `mongo_dump_restic_env`       | `{}`                        | Extra env vars for the restic backend (e.g. `AWS_ACCESS_KEY_ID` + `AWS_SECRET_ACCESS_KEY` for S3-compatible). |
| `mongo_dump_restic_init`      | `true`                      | Run `restic init` on the first invocation if the repo is empty.                                               |
| `mongo_dump_keep_daily`       | `7`                         | restic forget retention.                                                                                      |
| `mongo_dump_keep_weekly`      | `4`                         | restic forget retention.                                                                                      |
| `mongo_dump_keep_monthly`     | `12`                        | restic forget retention.                                                                                      |
| `mongo_dump_on_calendar`      | `daily`                     | systemd `OnCalendar` expression.                                                                              |
| `mongo_dump_randomized_delay` | `30min`                     | systemd `RandomizedDelaySec`.                                                                                 |
| `mongo_dump_persistent`       | `true`                      | systemd `Persistent=` (catches up missed runs).                                                               |
| `mongo_dump_packages`         | `[restic]`                  | Packages installed via apt.                                                                                   |
| `mongo_dump_timer_state`      | `started`                   | Final state of the timer.                                                                                     |
| `mongo_dump_timer_enabled`    | `true`                      | Whether the timer is enabled at boot.                                                                         |

## Example

```yaml
- name: Schedule <app_name>-db dumps
  ansible.builtin.import_role:
    name: jyok1m.backups.mongo_dump
  vars:
    mongo_dump_name: <app_name>
    mongo_dump_container: <app_name>-db
    mongo_dump_network: <app_name>-internal
    mongo_dump_username: "{{ <app_name>_db_user }}"
    mongo_dump_password: "{{ <app_name>_db_password }}"
    mongo_dump_restic_repo: "s3:https://s3.gra.io.cloud.ovh.net/<bucket>"
    mongo_dump_restic_password: "{{ restic_password }}"
    mongo_dump_restic_env:
      AWS_ACCESS_KEY_ID: "{{ s3_access_key_<app_name> }}"
      AWS_SECRET_ACCESS_KEY: "{{ s3_secret_key<app_name> }}"
    mongo_dump_on_calendar: "*-*-* 03:00:00"
```

Run on demand:

```bash
sudo systemctl start mongo-dump-<app_name>.service
journalctl -u mongo-dump-<app_name>.service -f
systemctl list-timers mongo-dump-<app_name>.timer
```
