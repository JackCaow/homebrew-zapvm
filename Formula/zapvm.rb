# frozen_string_literal: true

# Homebrew Formula for the complete zapVM Agent Computer.
class Zapvm < Formula
  desc "Ready-to-run Agent Computer VM for macOS"
  homepage "https://github.com/JackCaow/homebrew-zapvm"
  url "https://github.com/JackCaow/homebrew-zapvm/releases/download/v0.3.0-beta.2/zapvm_0.3.0-beta.2_darwin_arm64.tar.gz"
  version "0.3.0-beta.2"
  sha256 "cf6160d39fb32114ecf022a9458599e74e2b22857b6a85d25dd9845cf5049775"
  license "Apache-2.0"

  depends_on arch: :arm64
  depends_on :macos

  resource "agent_computer_image" do
    url "https://github.com/JackCaow/homebrew-zapvm/releases/download/v0.3.0-beta.2/zapvm-image_1.12.0-layered-rc7_arm64.bundle.tar.zst"
    sha256 "bd426b04eaa99d188e54add1813730d004588d179496d6c7808012677c01ba41"
  end

  resource "image_public_key" do
    url "https://github.com/JackCaow/homebrew-zapvm/releases/download/v0.3.0-beta.2/zapvm-image-public.pem"
    sha256 "ad2d183b02e194d7538ab4c791bf594aa94c4b84308ea061713f91f0515bd66c"
  end

  def install
    libexec.install "zapvm", "zapvm-node", "zapvm-image", "zapvm-sbom", "zapvm-host-install"
    pkgshare.install "LICENSE", "NOTICE", "README.md", "THIRD_PARTY_NOTICES.md", "docs", "examples"

    resource("agent_computer_image").stage do
      pkgshare.install "zapvm-image_1.12.0-layered-rc7_arm64.bundle.tar.zst"
    end
    resource("image_public_key").stage do
      pkgshare.install "zapvm-image-public.pem"
    end

    image_root = pkgshare/"images"
    image_bundle = pkgshare/"zapvm-image_1.12.0-layered-rc7_arm64.bundle.tar.zst"
    image_public_key = pkgshare/"zapvm-image-public.pem"
    system libexec/"zapvm-image", "install-bundle",
           "--root", image_root,
           "--bundle", image_bundle,
           "--public-key", image_public_key,
           "--arch", "arm64",
           "--smoke-binary", libexec/"zapvm"

    bin.write_env_script libexec/"zapvm",
                         ZAPVM_IMAGE_ROOT:       image_root,
                         ZAPVM_IMAGE_PUBLIC_KEY: image_public_key
    bin.install_symlink libexec/"zapvm-node"
    bin.install_symlink libexec/"zapvm-image"
    bin.install_symlink libexec/"zapvm-sbom"
    bin.install_symlink libexec/"zapvm-host-install"
  end

  def caveats
    <<~EOS
      zapVM Agent Computer is installed and ready.

      Verify the complete VM runtime:
        zapvm verify

      Run an isolated task in the current directory:
        zapvm run --workspace "$PWD" --stop-after-exec -- /bin/sh -lc 'uname -a'
    EOS
  end

  test do
    assert_equal version.to_s, shell_output("#{bin}/zapvm version").strip
    system "/usr/bin/codesign", "--verify", "--strict", libexec/"zapvm"
    entitlements = shell_output("/usr/bin/codesign -d --entitlements :- #{libexec}/zapvm 2>/dev/null")
    assert_match "com.apple.security.virtualization", entitlements
    assert_match "ZAPVM_AGENT_COMPUTER_OK", shell_output("#{bin}/zapvm verify 2>&1")
  end
end
