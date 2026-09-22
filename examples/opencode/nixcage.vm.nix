## OpenCode in a VM-isolated NixOS environment
##
## Usage:
##   1. Copy this file to your project root as nixcage.vm.nix
##   2. put your opencode.json in myproject/.opencode/
##   3. Run: nixcage init && nixcage build && nixcage shell
##   4. Inside the VM: opencode_with_env
{ pkgs, ... }:
let
  opencode_with_env = pkgs.writeShellScriptBin "opencode_with_env" ''
    # Isolate configs, data, caches, and logs entirely to workspace
    export OPENCODE_CONFIG_DIR="/workspace/.opencode/config"
    export OPENCODE_DATA_DIR="/workspace/.opencode/data"
    export OPENCODE_CACHE_DIR="/workspace/.opencode/cache"
    export OPENCODE_LOG_DIR="/workspace/.opencode/log"
    export OPENCODE_STATE_DIR="/workspace/.opencode/state"
    export OPENCODE_DB="/workspace/.opencode/data/opencode.db"
    export OPENCODE_AUTH_JSON="/workspace/.opencode/data/auth.json"
    mkdir -p "$OPENCODE_CONFIG_DIR" \
             "$OPENCODE_DATA_DIR" \
             "$OPENCODE_CACHE_DIR" \
             "$OPENCODE_LOG_DIR" \
             "$OPENCODE_STATE_DIR"
    exec opencode "$@"
  '';
in
{

  ## Add project-specific packages
  environment.systemPackages = with pkgs; [
    opencode
    opencode_with_env
    vim
    jq
    git
    #nodejs_24
  ];

  environment.localBinInPath = true;

  environment.variables = {
    EDITOR = "vim";
  };

  ## Adjust VM resources (defaults: 2 GB RAM, 2 vCPUs)
  microvm.mem = 4096;
  microvm.vcpu = 4;
}
