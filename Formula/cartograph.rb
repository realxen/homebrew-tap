class Cartograph < Formula
  desc "Build a nervous system for your codebase"
  homepage "https://github.com/realxen/cartograph"
  url "https://github.com/realxen/cartograph/releases/download/v0.1.4/cartograph-darwin-arm64"
  version "0.1.4"
  sha256 "93dfd5b7f9caea8c65c53e69dd3e7ff7380d32769ae265a758ee941bf3a0410d"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/realxen/cartograph/releases/download/v0.1.4/cartograph-darwin-arm64"
      sha256 "93dfd5b7f9caea8c65c53e69dd3e7ff7380d32769ae265a758ee941bf3a0410d"
    end

    if Hardware::CPU.intel?
      url "https://github.com/realxen/cartograph/releases/download/v0.1.4/cartograph-darwin-amd64"
      sha256 "ef793e96ef1113ffa69b8e103e91c132c5c986468c011fbb5cec6a92546d418a"
    end
  end

  on_linux do
    if Hardware::CPU.intel?
      url "https://github.com/realxen/cartograph/releases/download/v0.1.4/cartograph-linux-amd64"
      sha256 "656623fd6944a52f3792aeb6f1431ffd7c557926238a571c39c56a19978688c9"
    end

    if Hardware::CPU.arm?
      url "https://github.com/realxen/cartograph/releases/download/v0.1.4/cartograph-linux-arm64"
      sha256 "c26837278cf5a401affe923d5ce018c7a25fa3a66a3ec19647fbdbaf1429825e"
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
