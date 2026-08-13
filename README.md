# Homebrew tap for zapVM

This public tap distributes the macOS Apple Silicon Host tools for the private
[`JackCaow/zapVM`](https://github.com/JackCaow/zapVM) project.

```bash
brew tap JackCaow/zapvm
brew install zapvm
zapvm doctor
```

The Formula installs `zapvm`, `zapvm-node`, `zapvm-image`, `zapvm-sbom`, the
remote Host installer, configuration examples, and offline documentation. It
does **not** install, download, or trust a guest VM image. A signed Host Runtime
image and its pinned public trust root remain a separate delivery.

Current platform support through this tap: macOS Apple Silicon.
