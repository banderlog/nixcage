## Claude Code in a VM-isolated NixOS environment
##
## Usage:
##   1. Copy this file to your project root as nixcage.vm.nix
##   2. Set ANTHROPIC_API_KEY in your host shell
##   3. Run: nix run github:banderlog/nixcage build && nix run github:banderlog/nixcage shell
##   4. Inside the VM: claude
{ pkgs, ... }:
{

  ## Add project-specific packages
  environment.systemPackages = with pkgs; [
    claude-code
    vim
    jq
    git
    #nodejs_24
  ];

  environment.localBinInPath = true;

  environment.variables = {
    EDITOR = "vim";
    # keeps everuthing local
    CLAUDE_CONFIG_DIR = "/workspace/.claude";
  };

  ## Adjust VM resources (defaults: 2 GB RAM, 2 vCPUs)
  microvm.mem = 4096;
  microvm.vcpu = 4;

}
