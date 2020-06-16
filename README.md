# `nixos-btrbk`

[NixOS](https://nixos.org/) configuration module for [`btrbk`](https://digint.ch/btrbk/)

## Installation <> use

1. Clone the repository or copy the files
2. Add to imports list in `configuration.nix`:
    ```nix
    imports = [
       path/to/btrbk
    ];
    ```

3. Add config or use default (**TODO**)
4. Enable the service: `services.btrbk.enable = true;`

## Overriding attributes

Since this is a simple module, all common NixOS tools can be used.
If you think many people would benefit from another toggle, never hesitate to file a pull request or open an issue.
The reason for me trying to make it as simple as possible is that I use this for myself only and might stop supporting it at any time I get more workload than I can handle.
