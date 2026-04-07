class Cartograph < Formula
  desc "Build a nervous system for your codebase"
  homepage "https://github.com/realxen/cartograph"
  url "https://github.com/realxen/cartograph/releases/download/v0.1.0/cartograph-darwin-arm64"
  version "0.1.0"
  sha256 "b5e37e4be6a62e0c4babc70afdd1fb33e3df2a1d08e113367517c1da78499c9d"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/realxen/cartograph/releases/download/v0.1.0/cartograph-darwin-arm64"
      sha256 "b5e37e4be6a62e0c4babc70afdd1fb33e3df2a1d08e113367517c1da78499c9d"
    end

    if Hardware::CPU.intel?
      url "https://github.com/realxen/cartograph/releases/download/v0.1.0/cartograph-darwin-amd64"
      sha256 "c4db1ae46568c8ff303a0499a06ce71a43ce2d4d7e2ab54653941feafedf972c"
    end
  end

  on_linux do
    if Hardware::CPU.intel?
      url "https://github.com/realxen/cartograph/releases/download/v0.1.0/cartograph-linux-amd64"
      sha256 "1494a85b153c549ad9461c5aa9102265921688c34d307997f68475dcb08adbfc"
    end

    if Hardware::CPU.arm?
      url "https://github.com/realxen/cartograph/releases/download/v0.1.0/cartograph-linux-arm64"
      sha256 "82f0b4b8e8f6cb163319d9f9e8e7fec24a785a44a6db5643c4a88655414f4068"
    end
  end

  def install
    bin.install Dir["cartograph*"].first => "cartograph"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/cartograph -v")
  end
end
