# frozen_string_literal: true

# Homebrew Formula for the zapVM Host tools.
class Zapvm < Formula
  desc "Agent Computer VM runtime and Host tools"
  homepage "https://github.com/JackCaow/homebrew-zapvm"
  url "https://github.com/JackCaow/homebrew-zapvm/releases/download/v0.3.0-beta.1/zapvm_0.3.0-beta.1_darwin_arm64.tar.gz"
  version "0.3.0-beta.1"
  revision 1
  sha256 "7dd0305a99f65e24dce1d0c364ec5088c65504c18092cd280b5ee545d4a938b9"
  license "Apache-2.0"

  depends_on arch: :arm64
  depends_on :macos

  def install
    bin.install "zapvm", "zapvm-node", "zapvm-image", "zapvm-sbom", "zapvm-host-install"
    pkgshare.install "LICENSE", "NOTICE", "README.md", "THIRD_PARTY_NOTICES.md", "docs", "examples"
  end

  def caveats
    <<~EOS
      This Formula installs Host tools only. It does not install or trust a VM image.
      Run `zapvm doctor`, then import a separately signed Host Runtime image using
      its pinned image public key. Offline guides are installed in:
        #{pkgshare}/docs
    EOS
  end

  test do
    assert_equal version.to_s, shell_output("#{bin}/zapvm version").strip
    system "/usr/bin/codesign", "--verify", "--strict", bin/"zapvm"
    entitlements = shell_output("/usr/bin/codesign -d --entitlements :- #{bin}/zapvm 2>/dev/null")
    assert_match "com.apple.security.virtualization", entitlements
  end
end
