{
  inputs.nixpkgs.url = "nixpkgs/8bdebd463bc77c9b83d66e690cba822a51c34b9b";


  outputs = { self, nixpkgs }: {

    overlay = final: prev: {
      nuclear = self.defaultPackage.x86_64-linux;
    };

    defaultPackage.x86_64-linux =
      with import nixpkgs { system = "x86_64-linux";};
      stdenv.mkDerivation {
        pname = "nuclear";
        version = "0.6.3";
        # fetching a .deb because there's no easy way to package this Electron app
        src = fetchurl {
          url = "https://github.com/nukeop/nuclear/releases/download/v${self.outputs.defaultPackage.x86_64-linux.version}/nuclear-fca030.deb";
          hash = "sha256-cKp0OpgqDsxTBa6/SQ7emSdFgR+V74fhCkbmN/b5Xiw=";
        };

        buildInputs = [
          gnome3.gsettings_desktop_schemas
          glib
          gtk3
          cairo
          gnome2.pango
          atk
          gdk-pixbuf
          at-spi2-atk
          dbus
          dconf
          xorg.libX11
          xorg.libxcb
          xorg.libXi
          xorg.libXcursor
          xorg.libXdamage
          xorg.libXrandr
          xorg.libXcomposite
          xorg.libXext
          xorg.libXfixes
          xorg.libXrender
          xorg.libXtst
          xorg.libXScrnSaver
          nss
          nspr
          alsaLib
          cups
          fontconfig
          expat
          vips
        ];

        nativeBuildInputs = [
          wrapGAppsHook
          autoPatchelfHook
          makeWrapper
          dpkg
        ];

        runtimeLibs = lib.makeLibraryPath [ libudev0-shim glibc curl openssl libnghttp2 ];

        unpackPhase = "dpkg-deb -x $src .";

        installPhase = ''
        mkdir -p $out/share/nuclear
        mkdir -p $out/bin
        mkdir -p $out/lib

        mv opt/nuclear/* $out/share/nuclear

        mv $out/share/nuclear/*.so $out/lib
        mv usr/share/* $out/share/
        ln -s $out/share/nuclear/nuclear $out/bin/nuclear

        substituteInPlace $out/share/applications/nuclear.desktop  \
          --replace "/opt/nuclear/nuclear %U" "$out/bin/nuclear $U"
          '';

        preFixup = ''
         gappsWrapperArgs+=(--prefix LD_LIBRARY_PATH : "${self.outputs.defaultPackage.x86_64-linux.runtimeLibs}")
         '';

        enableParallelBuilding = true;
      };

    checks.x86_64-linux.build = self.defaultPackage.x86_64-linux;

  };

}
