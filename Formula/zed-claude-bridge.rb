# typed: false
# frozen_string_literal: true

# Claude Code /ide integration for Zed: at-mentions, automatic active-file
# & selection awareness, and the openFile jump — via a local sidecar.
# https://github.com/virgoC0der/claude-code-zed
class ZedClaudeBridge < Formula
  desc "Claude Code /ide integration for Zed (at-mentions, selection awareness, openFile)"
  homepage "https://github.com/virgoC0der/claude-code-zed"
  version "0.2.2"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/virgoC0der/claude-code-zed/releases/download/v#{version}/zed-claude-bridge-v#{version}-aarch64-apple-darwin.tar.gz"
      sha256 "7f1d4afccc7d76e5187d8ec21f99e8029e07e03a590e47ede8f8e8374aedc21a" # filled from the release's checksums.txt
    else
      url "https://github.com/virgoC0der/claude-code-zed/releases/download/v#{version}/zed-claude-bridge-v#{version}-x86_64-apple-darwin.tar.gz"
      sha256 "1625e18a8ad2b0282557f6dde2ba6b73db0fa805e0095217e4393d219a505bd2" # filled from the release's checksums.txt
    end
  end

  def install
    bin.install "zed-claude-bridge"
  end

  # `brew services start zed-claude-bridge` runs the sidecar as a login
  # launchd agent: one instance pinned to $HOME (serves every project under
  # it via session-aware routing) on the fixed port 52840, so
  # CLAUDE_CODE_SSE_PORT=52840 auto-connects `claude` without /ide.
  service do
    run [opt_bin/"zed-claude-bridge", "--workspace", Dir.home, "--port", "52840"]
    keep_alive true
    log_path var/"log/zed-claude-bridge.log"
    error_log_path var/"log/zed-claude-bridge.log"
  end

  def caveats
    <<~EOS
      Start the sidecar as a login service:
        brew services start zed-claude-bridge

      Then either run /ide inside `claude`, or auto-connect every session by
      adding to your shell rc:
        export CLAUDE_CODE_SSE_PORT=52840

      To send editor selections with cmd-ctrl-c, copy the .zed/tasks.json and
      .zed/keymap.json from the project README into your project:
        https://github.com/virgoC0der/claude-code-zed#usage-send-a-selection-from-zed-to-claude-code
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/zed-claude-bridge --version")
  end
end
