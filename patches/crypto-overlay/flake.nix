{
  description = "Crypto overlay";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };
  outputs = { self, nixpkgs, ... } @ inputs: let
    system = "x86_64-linux";  # Define systemNix
  in {
    overlays = {
      crypto = import /home/kixadmin/.dotfiles/patches/crypto-overlay/default.nix {
        inherit nixpkgs system;
      };
    };
    legacyPackages.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.extend self.overlays.crypto;
  };
}
