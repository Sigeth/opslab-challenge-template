# opslab challenge template

Start here to write a challenge for opslab (working name). A challenge is a standalone repository: the platform installs it from a catalog, runs it in an isolated environment for each student, and checks the tasks automatically.

## Layout

```
challenge.yaml        manifest: machines, access, tasks and their checks
instructions/en.md    what the student reads (one file per language)
setup/                scripts run once as root when an instance starts (break things here)
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

## Checks

Each task has one check, evaluated **from outside** the student's machines:

| Check | Passes when |
|---|---|
| `shell` | a command exits with `expectExit` (default 0) and its output matches `expectOutput` |
| `file` | a file exists (or not) with the expected `mode`, `owner` and content (`contains` / `notContains`) |
| `sshLogin` | logging in as `user` is `allowed` or `denied` (vm, sysbox) |
| `port` | a port is `open` or `closed` |
| `http` | a request returns `expectStatus` and a body matching `expectBody` |
| `kubeCEL` | a CEL expression holds for `all`, `any` or `none` of the selected objects (vcluster) |
| `goss` | a [goss](https://github.com/goss-org/goss) spec passes |

Good checks:
- **Test behavior, not files.** "SSH as root is denied" beats "sshd_config contains PermitRootLogin no", because a student with root can fake a file but not a behavior.
- **Fail closed.** If the student breaks the checker's access, the task fails. It never passes.
- **One task, one idea**, with a title that says what "solved" means.

Need logic beyond these? Set `spec.validation.checkerImage` to a custom checker image. The [opslab-checker SDK](https://github.com/Sigeth/opslab-checker) makes that a single Go function.

## Workflow

```sh
opslab challenge lint .      # validate (same rules as the platform)
```

Coming next: `opslab challenge test` (checks fail, solution, checks pass), and `push --sign` to publish to a catalog.

Rules for publishing:
- Pin every image by digest.
- Bump `metadata.version` for every release.
- Keep `solution/` working.

## License

[MIT](LICENSE). Your challenge can use any license: set it in `spec.license`.
