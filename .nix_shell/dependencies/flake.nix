{
  description = "Development environment";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  };

  outputs =
    {
      self,
      nixpkgs,
      ...
    }:
    let
      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];

      forEachSupportedSystem =
        f:
        nixpkgs.lib.genAttrs supportedSystems (
          system:
          f {
            pkgs = import nixpkgs { inherit system; };
          }
        );
    in
    {
      devShells = forEachSupportedSystem (
        { pkgs }:
        let
          lib-path =
            with pkgs;
            lib.makeLibraryPath [
              libffi
              openssl
              stdenv.cc.cc
              zlib
            ];
        in
        {
          default = pkgs.mkShell {

            packages =
              with pkgs;
              [
                nixd
                nixfmt-rfc-style
                hayagriva
                typstyle
                typst
                tinymist
                plantuml
                graphviz
                python313
              ]
              ++ (with pkgs.python313Packages; [
                pip
                ruff
                venvShellHook
              ]);

            venvDir = ".venv";

            postShellHook = ''
              SOURCE_DATE_EPOCH=$(date +%s)
              export "LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${lib-path}"
            '';

          };
        }
      );
    };
}
