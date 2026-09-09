# nixcage

Author of original repo decided to switch from microVM to containers: <https://github.com/hamidr/nixcage/issues/1>

This is fork of original v1.2.0 (before contaners) with some flake tweaks:
- "x86_64-linux" only
- nothing preinstalled except `bash` and `openssh`
- no devshell and overlay
- no hooks on dir enter in bash file
- more examples

---

NixOS microVM environments for AI coding agents.
Enter a project directory and your terminal switches into a full NixOS VM -- isolated at the kernel level, driven entirely by a Nix flake you control.

## How it works

```
cd myproject
     |
     v
shell hook detects nixcage.vm.nix
     |
     v
nixcage shell
     |
     +-- VM already running? -----> SSH in (~50ms)
     |
     +-- not running? -----------> nixcage start
                                        |
                                        v
                              fork hypervisor process
                              (cloud-hypervisor on Linux)
                                        |
                                   boots NixOS VM
                                        |
                              +----[VM boundary]-----+
                              |                      |
                              |  /workspace          |  <- your project dir
                              |  /nix/store (ro)     |  <- shared host store
                              |  + your packages     |
                              |                      |
                              +----------------------+
                                        |
                                   SSH session opens
                                   drops into /workspace
```

The host `/nix/store` is shared read-only across all VMs -- packages built once are
reused everywhere. Only `/workspace` (your project directory) crosses the VM
boundary as a live read-write mount.


## Installation and usage

### Install nix

```bash
# install nix
#  <https://nix.dev/install-nix>
curl -L https://nixos.org/nix/install | sh -s -- --daemon

# enable flakes for user
install -Dv <(echo "experimental-features = nix-command flakes") ~/.config/nix/nix.conf

# or for system
echo "experimental-features = nix-command flakes" | sudo tee -a /etc/nix/nix.conf
```

### Use this flake

```bash
nix run github:banderlog/nixcage  # help
```


## Quick start

```bash
cd ~/myproject

nix run github:banderlog/nixcage init   # generates nixcage.vm.nix + .nixcage-vm/
nix run github:banderlog/nixcage build  # builds the VM image (~15 min first run)
nix run github:banderlog/nixcage shell  # SSH login to VM
```


## Configuration -- `nixcage.vm.nix`

The only file you edit. It will appear in the root of your project after init.

SSH, the nixcage user, and the `/workspace` mount are all provided by the base layer -- you do not declare them.

> [!warning]
> see examples dir for opencode and claude-code examples


## SSH tweak

Add this tou your `~/.ssh/config` to remove keystroke lag:

```
# ~/.ssh/config
Host 127.0.0.1 localhost
    NoHostAuthenticationForLocalhost yes
    IPQoS throughput
    TCPKeepAlive yes
```


## Secrets

`nixcage init` scans the host environment for known AI/dev keys
(`ANTHROPIC_API_KEY`, `OPENAI_API_KEY`, `OPENCODE_API_KEY`, `GITHUB_TOKEN`)
and records their names in `.nixcage-vm/config`. When the VM starts, their values are piped into
`/run/nixcage-secrets` (tmpfs -- never flushed to disk) via SSH and made available
to every login shell. Values never enter the Nix store.

To change which keys are injected, edit `SECRET_VARS=` in `.nixcage-vm/config`.
