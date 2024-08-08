# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:

# with lib;
# let
  # piaInterface = config.services.pia-vpn.interface;

  # processTorrent = pkgs.writeScript "process-torrent" ''
  #   #!${pkgs.stdenv.shell}
  #   cd "$TR_TORRENT_DIR"
  #   if [ -d "$TR_TORRENT_NAME" ]; then
  #     cd "$TR_TORRENT_NAME"
  #     for dir in $(find . -name '*.rar' -exec dirname {} \; | sort -u); do
  #       pushd $dir; ${pkgs.unrar}/bin/unrar x *.rar; popd
  #     done
  #   in
  # '';

  # startTransmission = pkgs.writeScript "start-transmission" ''
  #   #!${pkgs.stdenv.shell}
  #   IP=$(${pkgs.iproute2}/bin/ip -j addr show dev ${piaInterface} | ${pkgs.jq}/bin/jq -r '.[0].addr_info | map(select(.family == "inet"))[0].local')
  #   ${pkgs.transmission}/bin/transmission-daemon -f \
  #     -g "${config.services.transmission.home}/.config/transmission-daemon" \
  #     --bind-address-ipv4 $IP
  # '';

# in
{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];
  nix.nixPath = [
    "nixpkgs=/nix/var/nix/profiles/per-user/root/channels/nixos"
    "nixos-config=${config.users.users.kixadmin.home}/.dotfiles/configuration.nix"
    "/nix/var/nix/profiles/per-user/root/channels"
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.kernelModules = [ "amdgpu" "ehci_pci" "usbcore" "uas" "libcomposite" "xhci_pci" "thunderbolt" "nvme" "usbhid" "usb_storage" "sd_mod" "sdhci_pci" "uhci_hcd" "virtio_pci" "sdhci_pci" ];
  boot.kernelModules =  [ "wireguard" "kvm-amd" ];
  boot.blacklistedKernelModules = [ "bluetooth" "btusb" ];
  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = true;
    "net.ipv6.ip_forward" = true;
  };

  # Add kernel parameters like iommu
  boot.kernelParams = [
    "quiet"
    "amd_pstate=guided"
    "iommu_pt"
    #usbcore.blinkenlights=1
  ];
  
  # Disable Bluetooth
  hardware.bluetooth = {
    enable = false;
    powerOnBoot = false;
  };
  # AMD GPU
  hardware.graphics.extraPackages = with pkgs; [
    # VA-API and VDPAU
    vaapiVdpau

    # AMD ROCm OpenCL runtime
    rocmPackages.clr
    rocmPackages.clr.icd

    # AMDVLK drivers can be used in addition to the Mesa RADV drivers.
    #amdvlk
  ];
  hardware.graphics.extraPackages32 = with pkgs; [
    driversi686Linux.amdvlk
  ];

  # Most software has the HIP libraries hard-coded. Workaround:
  systemd.tmpfiles.rules = [
    "L+    /opt/rocm/hip   -    -    -     -    ${pkgs.rocmPackages.clr}"
  ];

  # Use the latest kernel available
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Add extra modules to kernel
  # boot.extraModulePackages = with config.boot.kernelPackages; [ wireguard ];

  # Add Flakes
  nix.settings.experimental-features = ["nix-command" "flakes"];

  networking.wireless.enable = false;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";
  # Enable networking

  networking = {
    hostName = "powerhouse"; # Define your hostname.
    #useNetworkd = true;  # Use networkd for managing network interfaces
    useDHCP = false;     # Disable dhcpcd to avoid conflicts
    # dhcpcd.enable = false;
    networkmanager = {
    enable = false;
    };
    interfaces.eno1.useDHCP = true;
    interfaces.br0.useDHCP = true;
    bridges = {
      "br0" = {
        interfaces = [ "eno1" ];
      };
    };
    firewall = {
      enable = true;
      allowedTCPPorts = [ 80 443 8443 ];
      allowedUDPPortRanges = [
        { from = 41641; to = 41641; } #Tailscale
        { from = 4000; to = 4007; }
        { from = 8000; to = 8010; }
      ];
      trustedInterfaces = [
   	  	"br0"
        "tailscale0"
      ];
    };

    extraHosts = 
      ''
        192.168.2.120 miniserver
        192.168.2.80 truck
        192.168.2.181 tehila
        192.168.2.241 saba
        192.168.2.11 wifi
        192.168.2.3 pihole
        192.168.2.1 router
        139.177.202.138 freeswitch
    '';
  #   bridges.br0.interfaces = [ "eno1" ];
  #   interfaces.br0.ipv4.addresses = [
  #       {
  #         # choose your local fixed address 'xxx' :
  #         address = "192.168.2.121";
  #         prefixLength = 24;
  #       }
  #     ];
  #   defaultGateway.address = "192.168.2.1";
  #   nameservers = [ "192.168.2.3" ];
  #   firewall.enable = false;
  #   firewall.trustedInterfaces = [
  # 	  	"br0"
  #   ];
  };
  fileSystems."/media/incus" = {
    device = "/dev/sda";
    fsType = "btrfs";
    #options = [ "x-systemd.after=network-online.target" "x-systemd.mount-timeout=30" ];
    options = [ "x-systemd.automount" "x-systemd.after=network-online.target" "x-systemd.mount-timeout=10" ];
  };
  #systemd.network.networks."40-br0".gateway = [ "192.168.2.1" ];
  #systemd.network.networks."40-br0".nameservers = [ "192.168.2.3" ];

  #systemd.network.networks."40-"
  # Set your time zone.
  time.timeZone = "America/New_York";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Used to autmount disks

  services.gvfs.enable = true;
  services.udisks2.enable = true; 

  # Add iOS support
  services.usbmuxd = {
    enable = true;
    package = pkgs.usbmuxd2;
  };

  # ffmpeg package for transcoding
  # services.go2rtc.settings.ffmpeg.bin = {
  #   path = "${lib.getBin pkgs.ffmpeg-full}/bin/ffmpeg";
  # };

  # Add Flatpak support
  services.flatpak.enable = true;
   xdg.portal.enable = true;

  # Add PIA Wireguard into NixOS
  services = {
    pia-vpn = {
      enable = true;
      certificateFile = "/home/kixadmin/.vpn/ca.rsa.4096.crt";
      environmentFile = "/home/kixadmin/.vpn/pia.env";
      portForward = {
        enable = true;
       #  script = ''
       #    ${pkgs.transmission}/bin/transmission-remote --port $port || true
       # '';
      };
    };
  };

  # systemd.services.transmission = {
  #   after = [ "pia-vpn.service" ];
  #   bindsTo = [ "pia-vpn.service" ];
  #   requires = [ "network.target" ];
  #   wantedBy = [ "multi-user.target" ];
  #   serviceConfig.ExecStart = mkForce ''
  #     ${startTransmission}
  #   '';
  # };

  # Have Tailscale running

  services.tailscale = {
    enable = true;
    useRoutingFeatures = "server";
    extraUpFlags = [
      "--ssh=true"
      "--accept-dns=true"
      "--accept-routes=false"
      "--reset"
    ];
  };


  # Enable the X11 windowing system.
  # You can disable this if you're only using the Wayland session.
  # services.xserver.enable = true;

  # Enable the KDE Plasma Desktop Environment.
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;
  services.desktopManager.plasma6.enable = true;
  environment.plasma6.excludePackages = with pkgs.kdePackages; [
    gwenview
    partitionmanager
    kio-fuse
  ];


  # Configure keymap in X11
  services.xserver = {
    xkb = {
      layout = "us,il";
      variant = "";
    };
  };

  # Stop sudo from asking for passwords
  security.sudo.wheelNeedsPassword = false;

  # Enable CUPS to print documents.

  services.printing = {
    enable = true;
    drivers = with pkgs; [
      canon-cups-ufr2
      gutenprintBin
    ];
  };
  services.avahi = {
    enable = true;
    ipv4 = true;
    ipv6 = false;
    #domainName = "mylocal";
    #wideArea = false;
    nssmdns4 = true;
    nssmdns6 = false;
    publish = {
    enable = true;
    addresses = true;
    };
  };
  # Enable sound with pipewire.
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.kixadmin = {
    isNormalUser = true;
    description = "kixadmin";
    extraGroups = ["networkmanager" "wheel" "incus-admin" "media" "libvirtd" "kvm" "lp"];
    packages = with pkgs; [
      kdePackages.kate
      kdePackages.kdeconnect-kde
      #  thunderbird
    ];
  };
  # mapping Gids Uids so you can read/write in the containers in /mnt/pris-incus with alain user
  users.users.root.subGidRanges = lib.mkForce [
    { count = 1; startGid = 100; }
    { count = 1000000000; startGid = 1000000; }
  ];
  users.users.root.subUidRanges = lib.mkForce [
    { count = 1; startUid = 1000; }
    { count = 1000000000; startUid = 1000000; }
  ];
  # Enable automatic login for the user.
  #services.xserver.displayManager.autoLogin.enable = true;
  #services.xserver.displayManager.autoLogin.user = "kixadmin";

  # Install firefox.
  programs.firefox = {
    enable = true;
    languagePacks = [ "he" ];
    nativeMessagingHosts.packages = [ 
      # pkgs.plasma-browser-integration 
      # pkgs.ff2mpv 
    ];
  };


  # programs.nixvim.enable = true;
  # Make sure NeoVim is the default environment editor
  environment = {
    shells = [ pkgs.bash ];
    variables = {
    EDITOR = "lvim";
    SYSTEMD_EDITOR = "lvim";
    VISUAL = "lvim";
    # VAAPI and VDPAU config for accelerated video.
    # See https://wiki.archlinux.org/index.php/Hardware_video_acceleration
    "VDPAU_DRIVER" = "radeonsi";
    "LIBVA_DRIVER_NAME" = "radeonsi";
    };
  };
  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;


  #environment.interactiveShellInit = ''
  programs.bash.shellAliases = {
    rr="cd /home/kixadmin/.dotfiles && sudo nixos-rebuild switch --flake /home/kixadmin/.dotfiles && cd -";
    qq="sudo vim /home/kixadmin/.dotfiles/configuration.nix && sudo nix-env --delete-generations 7d";
    nu="nix flake update && sudo nixos-rebuild switch --flake .";
    ng="nix-collect-garbage -d && sudo nix-env --delete-generations --profile /nix/var/nix/profiles/system 2d";
    gs="git status";
    yt="yt-dlp -f 140";
    n="pnpm";
    v="lvim";
    vim="lvim";
    vi="lvim";
    sudo="sudo ";
    ls="ls --color=tty";
    l="ls -alh --color=tty";
    getPiaPort="journalctl -u pia-vpn-portforward.service -n 10";
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    neovim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    # (vivaldi.override {
    #   proprietaryCodecs = true;
    #   enableWidevine = false;
    # })
    libimobiledevice
    ifuse
    libva-utils
    nmap
    unzip
    pnpm
    yt-dlp
    vivaldi-ffmpeg-codecs
    ffmpeg
    (opera.override { proprietaryCodecs = true; })
    dig
    fastfetch
    linssid
    wget
    git
    git-lfs
    curl
    alejandra
    black
    google-java-format
    prettierd
    lazygit
    tree-sitter
    wl-clipboard
    ripgrep
    fd
    lunarvim
    rustfmt
    stylua
    jq
    wireguard-tools
    qbittorrent
    mpv
    nodePackages_latest.nodejs
    telegram-desktop
    discord-screenaudio
    zoom-us
    gh # GitHub CLI tool
    pdfarranger
    usbutils
    udiskie 
    udisks
    remmina
    sshfs
    btop
    quickgui
   # vivaldi
    vivaldi-ffmpeg-codecs
    arduino-ide
    podman-compose
    podman-desktop
    distrobox
    audacity
    inputs.Neve.packages.${pkgs.system}.default
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
   programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      package = pkgs.qemu_kvm;
      runAsRoot = true;
      swtpm.enable = true;
      ovmf = {
        enable = true;
        packages = [(pkgs.OVMF.override {
          secureBoot = true;
          tpmSupport = true;
        }).fd];
      };
    };
  };
  programs.virt-manager.enable = true;
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
  };

#===========================================================================#
# Traceroute
programs.traceroute.enable = true;
#===========================================================================#

 # incus !
  
  networking.nftables.enable = true; # mandatory for incus in NixOS 
  virtualisation.incus = {
    enable = true;
    package = pkgs.incus;
    ui.enable = true;
    # preseed est un service systemd: systemctl status incus-preseed.service
    preseed = {
     # this is configuration of the incusd server side: 
      config = {
      "core.https_address" = "192.168.2.121:8443";
      "images.auto_update_interval" = 9;
      };
      
      networks = [
       {
         config = {
           "ipv4.address" = "192.168.2.121/24";
           "ipv4.dhcp" = "true";
           #"ipv4.dhcp.ranges" = "10.32.241.50-10.32.241.150";
           "ipv4.nat" = "false";
           "ipv4.firewall" = "false";
           #"ipv6.address" = "fd42:c3ac:167a:93e9::1/64";
           #"ipv6.nat" = "true";
           #"ipv6.firewall" = "false";
         };
         name = "br0";
         type = "bridge";
         description = "prem";
       }
      ];
     
      profiles = [
        {
           devices = {
            root = {
              path = "/";
              pool = "powerpool";
              size = "50 GiB";
              type = "disk";
            };
          };
    	  name = "default";
        }
        {
          devices = {
            eth0 = {
              name = "eth0";
              network = "br0";
              type = "nic";
              nictype = "bridged";
            };
          };
    	  name = "powerpool";
    	  description = "merci Big D";
        }
      ];
      # to be uncommented at first boot and commented once the zfs storage is created
      # once it is commented all preseed info above will be take in account at each rebuild
      # and when you restart preseed service:
      # systemctl restart incus-preseed.service
            
      storage_pools = [
       {
         config = {
           source = "/var/lib/incus/storage-pools/powerpool";
         };
         driver = "dir";
         name = "powerpool";
       }
      ];
        	
    };
  };


  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?
}
