{
  inputs.nixpkgs.url = "nixpkgs/8bdebd463bc77c9b83d66e690cba822a51c34b9b";


  outputs = { self, nixpkgs }: {

    overlay = final: prev: {
      nuclear = self.defaultPackage.x86_64-linux;
    };

    defaultPackage.x86_64-linux =
      with import nixpkgs { system = "x86_64-linux";};
      with (import ./build-appimage.nix { inherit pkgs; });
      let
        version = "0.6.6";
      in
        buildAppImage {
          name   = "Nuclear";
          url    = "https://github.com/nukeop/nuclear/releases/download/v${version}/nuclear-v${version}.AppImage";
          sha256 = "sha256-UYc1e0FBjhFSUIZmEYEeRmxvF0w7cNC7yVFFepvjWcs=";
          icon   = fetchurl {
            url    = https://raw.githubusercontent.com/nukeop/nuclear/master/packages/app/resources/media/1024x1024.png;
            sha256 = "sha256-ROsh8UMDGJXW7kngGTfk7dJv8dVrl5FttaQ3k3nDFUA=";
          };
          categories = "Streaming Music";
        };

    checks.x86_64-linux.build = self.defaultPackage.x86_64-linux;

  };

}
