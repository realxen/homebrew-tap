class Cartograph < Formula
  desc "Build a nervous system for your codebase"
  homepage "https://github.com/realxen/cartograph"
  url "https://github.com/realxen/cartograph/releases/download/v0.1.2/cartograph-darwin-arm64"
  version "0.1.2"
  sha256 "484c47767d9fd196c6bc41c6fd58b68c31f77c688a727bedf21c032e955bccea"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/realxen/cartograph/releases/download/v0.1.2/cartograph-darwin-arm64"
      sha256 "484c47767d9fd196c6bc41c6fd58b68c31f77c688a727bedf21c032e955bccea"
    end

    if Hardware::CPU.intel?
      url "https://github.com/realxen/cartograph/releases/download/v0.1.2/cartograph-darwin-amd64"
      sha256 "a636c7af354e3ad4821244b276c1dd57cf8b3cb26321f0902f5d23d1f372cbca"
    end
  end

  on_linux do
    if Hardware::CPU.intel?
      url "https://github.com/realxen/cartograph/releases/download/v0.1.2/cartograph-linux-amd64"
      sha256 "da36ff74877190b1246c0b113c38416cb32a3139cf07bf505ad70fcb8215579e"
    end

    if Hardware::CPU.arm?
      url "https://github.com/realxen/cartograph/releases/download/v0.1.2/cartograph-linux-arm64"
      sha256 "ef9399770cc124f87a0fa11f4bd3df9b4850a46ae875338cb261eaf96dec56cc"
    end
  end

  def install
    binary_name =
      if OS.mac?
        Hardware::CPU.arm? ? "cartograph-darwin-arm64" : "cartograph-darwin-amd64"
      elsif OS.linux?
        Hardware::CPU.arm? ? "cartograph-linux-arm64" : "cartograph-linux-amd64"
      else
        odie "unsupported platform"
      end

    bin.install binary_name => "cartograph"
    (buildpath/"cartograph.bash").write <<~BASH
      complete -o default -o bashdefault -C #{opt_bin}/cartograph cartograph
    BASH
    bash_completion.install buildpath/"cartograph.bash" => "cartograph"
  end

  def post_install
    system bin/"cartograph", "skills", "install", "--upgrade"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/cartograph -v")
    assert_match "complete -o default", shell_output("#{bin}/cartograph completion -c bash")
  end
end
