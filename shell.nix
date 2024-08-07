  #############################################
  #                                           #
  #                                           #
  # Nix-Shell automated packages installed    #
  # for my environments                       #
  #                                           #
  #############################################
 { pkgs ? import <nixpkgs> {} }:
 pkgs.mkShell {
  packages = with pkgs; [ 
    nodejs
    git
    gh
    python312
    pnpm
  ];
}
