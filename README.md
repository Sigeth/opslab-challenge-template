# opslab challenge template

Start here to write a challenge for opslab (working name). A challenge is a directory with a `challenge.yaml`: either a repository of its own (this template), or one directory of a repository holding several challenges, like the [official challenges](https://github.com/Sigeth/opslab-challenges). The platform installs it from a catalog, runs it in an isolated environment for each student, and checks the tasks automatically.

## Layout

```
challenge.yaml        manifest: machines, access, tasks and their checks
images/<machine>/     Dockerfile of each machine image (minimal, unprivileged user)
instructions/en.md    what the student reads (one file per language)
setup/                scripts run once when an instance starts (break things here)
solution/             reference solution, for testing and for teachers (never shown to students)
```

The first line of `challenge.yaml` links the JSON Schema: editors using the YAML language server (VS Code, Neovim, JetBrains…) then complete and validate every field.

## Runtimes

Pick the lightest runtime that can host the challenge. The cluster admin sees what it needs before installing.

| Runtime | What the student gets | Use it for |
|---|---|---|
| `pod` | A container, no privileges | Files, permissions, config, app debugging |
| `sysbox` | A system container with systemd, Docker or Podman inside | Services, container engines |
| `vcluster` | Admin of a virtual Kubernetes cluster | RBAC, NetworkPolicy, Pod Security, workloads |
| `vm` | A full virtual machine (KubeVirt) | Kernel, firewall, sshd, auditd, container escapes, kubeadm |

Only `pod` runs today; the other runtimes come with later platform versions.

**`pod` machines** run as UID/GID 1000 without any privilege (Pod Security "restricted"): no root, no `sudo`, no package installs. `setup/` scripts and checks run as that user too. The container gets a TTY, so an image whose default command is a shell stays up; services can be started in the background by a setup script.

## Machine images

Each machine image is built from `images/<machine>/Dockerfile` and published with the challenge. Students see how it is built, so make it an example of good practice:

- **An unprivileged user and group of its own:** `student`, UID/GID 1000, with a home directory and no extra groups. End with `USER 1000:1000`. Never rely on `root`, or on a distribution's default user that belongs to `sudo` or `adm`.
- **Only the tools the challenge needs.** Start from a small base (`alpine`, `busybox`, a `-slim` image) and add packages one by one. No `sudo`, `systemd`/`systemctl`, compilers or editors the tasks do not use: every extra binary is attack surface, and a distraction.
- **Pin the base image by digest**, and tag the machine image with the challenge version.

`opslab challenge images .` lists the images and the ones the challenge builds. The workspace dev loop builds and loads them into the dev cluster.

## Checks

Each task has one check, evaluated **from outside** the student's machines:

| Check | Passes when |
|---|---|
| `shell` | a command exits with `expectExit` (default 0) and its output matches `expectOutput` |
| `file` | a file exists (or not) with the expected `mode`, `owner` and content (`contains` / `notContains`) |
| `sshLogin` | logging in as `user` is `allowed` or `denied` (vm). The checker presents the student's key (or `password`), so for another user, install the student's public key for that user in your setup (`cp /home/student/.ssh/authorized_keys /root/.ssh/`). `denied` needs a running SSH server that refuses the login. |
| `port` | a port is `open` or `closed` |
| `http` | a request returns `expectStatus` and a body matching `expectBody` |
| `kubeCEL` | a CEL expression holds for `all`, `any` or `none` of the selected objects (vcluster) |
| `goss` | a [goss](https://github.com/goss-org/goss) spec passes |

On `vm` machines, `shell` and `file` checks run over SSH, as the check's `user` (default `root`) through `sudo`. The student is `student` (UID 1000) with passwordless `sudo`; setup scripts run as root.

Good checks:
- **Test behavior, not files.** "SSH as root is denied" beats "sshd_config contains PermitRootLogin no", because a student with root can fake a file but not a behavior.
- **Fail closed.** If the student breaks the checker's access, the task fails. It never passes.
- **One task, one idea**, with a title that says what "solved" means.

Need logic beyond these? Set `spec.validation.checkerImage` to a custom checker image. The [opslab-checker SDK](https://github.com/Sigeth/opslab-checker) makes that a single Go function.

## Workflow

```sh
opslab challenge lint .      # validate (same rules as the platform)
```

Try it on a local platform (the workspace dev cluster):

```sh
opslab challenge manifest . | kubectl apply -f -   # install it, unsigned (development only)
```

Coming next: `opslab challenge test` (checks fail, solution, checks pass), and `push --sign` to publish to a catalog.

Rules for publishing:
- Pin every image by digest.
- Bump `metadata.version` for every release.
- Keep `solution/` working.

## License

[MIT](LICENSE). Your challenge can use any license: set it in `spec.license`.
