# con

A collection of small CLI scripts that help you connect to remote hosts without
typing hostnames manually. Each script reads available hosts from a source
(SSH config file or GCP API), displays a numbered list, and opens an SSH session
to the host you select.

## Scripts

| Script | OS / Environment | Backend |
|---|---|---|
| [`con.sh`](#consh--linux--macos) | Linux / macOS (Bash) | OpenSSH via `~/.ssh/config` |
| [`con.ps1`](#conps1--windows--powershell) | Windows (PowerShell) | OpenSSH via `~/.ssh/config` |
| [`gcp-con.sh`](#gcp-consh--linux--macos--google-cloud) | Linux / macOS (Bash) | Google Cloud VMs via `gcloud` |

> `very-old.ps1` is a historical prototype kept for reference only.
> Do not use it in practice.

---

## `con.sh` — Linux / macOS

Connects to SSH hosts defined in `~/.ssh/config`.

### Requirements

| Dependency | Notes |
|---|---|
| Bash 4.0+ | macOS ships with Bash 3.2; install a newer version via Homebrew (`brew install bash`) |
| `awk` | Any standard implementation |
| OpenSSH client (`ssh`) | Must be on `PATH` |
| `~/.ssh/config` | Must exist and contain at least one `Host` entry |

### Installation

**Option A — alias (recommended)**

Clone the repository once and add an alias to your shell profile. This way
updates only require a `git pull` and the alias always points to the latest
version.

```bash
git clone git@github.com:zwieratko/con.git ~/tools/con

# Add to ~/.bashrc or ~/.zshrc:
alias con="$HOME/tools/con/con.sh"
```

Reload your shell (`source ~/.bashrc` / `source ~/.zshrc`) and you can call
the script simply as `con`.

**Option B — copy to PATH**

```bash
git clone git@github.com:zwieratko/con.git ~/tools/con
cd ~/tools/con
chmod +x con.sh
sudo cp con.sh /usr/local/bin/con
```

### Usage

```bash
con               # show numbered list of hosts, then prompt for selection
con <number>      # connect directly to host <number> without prompting
```

### Notes

- The last **2** entries in `~/.ssh/config` are always excluded from the list.
  This is intentional — typically the trailing entries are catch-all (`Host *`)
  or group-separator blocks that should not be dialled directly.
  Adjust the `exceptLast` variable in the script if your config differs.
- There is no `-v` (version) or `-h` (help) flag.
- The `##div` grouping separator supported by `con.ps1` is not implemented here.

---

## `con.ps1` — Windows / PowerShell

Connects to SSH hosts defined in `~/.ssh/config`. This is the first and most
feature-complete implementation.

### Requirements

| Dependency | Notes |
|---|---|
| PowerShell 5.1+ | Windows PowerShell (built-in) or PowerShell Core 7+ |
| OpenSSH client (`ssh`) | Must be on `PATH`; available as an optional Windows feature |
| `~/.ssh/config` | Must exist and contain at least one `Host` entry |

### Installation

**Option A — alias (recommended)**

Clone the repository once and add an alias to your PowerShell profile. Updates
only require a `git pull`.

```powershell
git clone git@github.com:zwieratko/con.git "$HOME\tools\con"

# Add to your PowerShell profile ($PROFILE):
Set-Alias con "$HOME\tools\con\con.ps1"
```

Reload your profile (`. $PROFILE`) and you can call the script as `con`.

**Option B — copy to PATH**

```powershell
git clone git@github.com:zwieratko/con.git "$HOME\tools\con"
cd "$HOME\tools\con"

# Copy to a directory that is already on your PATH, e.g. ~/bin:
Copy-Item con.ps1 "$HOME\bin\con.ps1"

# Or add the repository directory to PATH in your PowerShell profile:
$env:PATH += ";$HOME\tools\con"
```

### Usage

```powershell
con                   # show numbered list of hosts, then prompt for selection
con <number>          # connect directly to host <number>
con -s <number>       # same as above (short form)
con -v                # print version
con -h                # print help
```

### Host grouping with `##div`

You can visually group hosts in the menu by placing a comment that starts with
`##div` on the line immediately before a `Host` block in your `~/.ssh/config`:

```
## ##div
Host prod-web-01
    HostName 192.168.1.10
    User deploy

## ##div
Host staging-web-01
    HostName 192.168.1.20
    User deploy
```

The script detects these markers and prints a blank line above the group in the
menu, making long host lists easier to read.

### Notes

- The last **3** entries in `~/.ssh/config` are excluded from the list
  (same rationale as `con.sh`). Adjust `$itemCount = $allHostsArray.count - 3`
  in the script if your config differs.
- Terminal foreground and background colors are saved before the SSH session
  and restored automatically after it ends.
- The menu header shows the current date and time.

---

## `gcp-con.sh` — Linux / macOS / Google Cloud

Connects to Google Cloud Platform VM instances using `gcloud compute ssh` with
IAP (Identity-Aware Proxy) tunneling. Hosts are discovered dynamically from the
GCP API — no static config file needed.

### Requirements

| Dependency | Notes |
|---|---|
| Bash 4.0+ | See note under `con.sh` for macOS |
| Google Cloud SDK (`gcloud`) | Must be installed and authenticated (`gcloud auth login`) |
| IAP enabled | The target VMs must be reachable via Identity-Aware Proxy |
| GCP project | Must be configured (see below) |

### Environment variables

| Variable | Required | Description |
|---|---|---|
| `GCLOUD_PROJECT` | Optional | GCP project ID to use. If not set, the script falls back to `gcloud config get-value project`. |

### Installation

**Option A — alias (recommended)**

```bash
git clone git@github.com:zwieratko/con.git ~/tools/con

# Add to ~/.bashrc or ~/.zshrc:
alias gcp-con="$HOME/tools/con/gcp-con.sh"
```

Reload your shell and call the script as `gcp-con`.

**Option B — copy to PATH**

```bash
git clone git@github.com:zwieratko/con.git ~/tools/con
cd ~/tools/con
chmod +x gcp-con.sh
sudo cp gcp-con.sh /usr/local/bin/gcp-con
```

### Usage

```bash
gcp-con               # list running VMs and prompt for selection
gcp-con <number>      # connect directly to VM <number>
gcp-con -h            # show help
```

```bash
# Override the GCP project for a single run:
GCLOUD_PROJECT=my-other-project gcp-con
```

### Notes

- Only VMs with `STATUS=RUNNING` are listed.
- Connection is always made via IAP tunnel (`--tunnel-through-iap`). The VM does
  not need a public IP address.
- The script uses `set -euo pipefail`, so it exits immediately on any unexpected
  error.
- Both the VM name and zone are shown before connecting.

---

## License

MIT — see [LICENSE](LICENSE).
