self: super: {
  incus = super.incus.overrideAttrs (oldAttrs: {
    version = "6.4";  # Replace with a suitable version greater than 6.3
    src = super.fetchFromGitHub {
      owner = "lxc";
      repo = "incus";
      rev = "some_commit_hash";  # Update to a commit that provides the version greater than 6.3
      sha256 = "some_sha256";  # Ensure this matches the source
    };
  });
}

