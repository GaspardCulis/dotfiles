# Gasdev infrastructure

## Initial installation

Cloud providers not always provide a NixOS install option, so I use [nixos-anywhere](https://github.com/nix-community/nixos-anywhere) for remote NixOS installation using SSH

### Kexec installation

As specified in [nixos-images](https://github.com/nix-community/nixos-images#kexec-tarballs):

```sh
# Run as root
curl -L https://github.com/nix-community/nixos-images/releases/download/nixos-unstable/nixos-kexec-installer-noninteractive-x86_64-linux.tar.gz | tar -xzf- -C /root
/root/kexec/run
```

The machine will restart in a new NixOS installation. The existing SSH keys are copied to the new installation's _root_ user.

### NixOS-everywhere

```sh
nix run github:nix-community/nixos-anywhere -- --flake .#<configuration name> root@<ip address>
```

## Deploy configuration

In order to deploy new configuration changes after the initial NixOS installation, I use [deploy-rs](https://github.com/serokell/deploy-rs). It requires a properly set-up **ssh-agent** and SSH keys being installed on the **gaspard** user.

Then you can deploy the new configuration:

```sh
nix run github:serokell/deploy-rs .#<configuration name>
```
