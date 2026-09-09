## nixcage VM configuration -- edit to customize your environment.
## Run 'nixcage sync' after changes.
{ pkgs, ... }: {

  ## Add project-specific packages
  # environment.systemPackages = with pkgs; [
  #   python3
  #   rustup
  #   postgresql
  # ];

  ## Adjust VM resources (defaults: 2 GB RAM, 2 vCPUs)
  # microvm.mem = 4096;
  # microvm.vcpu = 4;

  ## Mount extra host paths
  # microvm.shares = [{
  #   tag = "home-ssh";
  #   source = "/home/me/.ssh";
  #   mountPoint = "/home/nixcage/.ssh";
  #   proto = "virtiofs";
  # }];
}
