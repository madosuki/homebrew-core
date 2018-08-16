class Hub < Formula
  desc "Add GitHub support to git on the command-line"
  homepage "https://hub.github.com/"
  url "https://github.com/github/hub/archive/v2.5.0.tar.gz"
  sha256 "8e3bda092ddc81eaf208c5fd2b87f66e030012129d55fa631635c6adf8437941"
  head "https://github.com/github/hub.git"

  bottle do
    cellar :any_skip_relocation
    rebuild 1
    sha256 "6ecbc86d7695b2dd376a5ebd6ae02959132eec9a83464f252cb8d700dd5cd5cb" => :mojave
    sha256 "2609a97cd6233a635e69e6baae251641729f73317db40d26c13a9f96c45d59cd" => :high_sierra
    sha256 "aabdf10641af380804c8a640a072acd6c6806c1d1dc015d18169ae5e3e221653" => :sierra
    sha256 "82c72bd7c6a4f9a4d24dd95bb3540b9d2f44985e3c3b72b92eccbd442fbacc87" => :el_capitan
  end

  option "without-completions", "Disable bash/zsh completions"
  option "without-docs", "Don't install man pages"

  depends_on "go" => :build

  # System Ruby uses old TLS versions no longer supported by RubyGems.
  depends_on "ruby" => :build if MacOS.version <= :sierra

  def install
    ENV["GOPATH"] = buildpath
    (buildpath/"src/github.com/github/hub").install buildpath.children
    cd "src/github.com/github/hub" do
      if build.with? "docs"
        begin
          deleted = ENV.delete "SDKROOT"
          ENV["GEM_HOME"] = buildpath/"gem_home"
          system "gem", "install", "bundler"
          ENV.prepend_path "PATH", buildpath/"gem_home/bin"
          system "make", "man-pages"
        ensure
          ENV["SDKROOT"] = deleted
        end
        system "make", "install", "prefix=#{prefix}"
      else
        system "script/build", "-o", "hub"
        bin.install "hub"
      end

      prefix.install_metafiles

      if build.with? "completions"
        bash_completion.install "etc/hub.bash_completion.sh"
        zsh_completion.install "etc/hub.zsh_completion" => "_hub"
        fish_completion.install "etc/hub.fish_completion" => "hub.fish"
      end
    end
  end

  test do
    system "git", "init"
    %w[haunted house].each { |f| touch testpath/f }
    system "git", "add", "haunted", "house"
    system "git", "commit", "-a", "-m", "Initial Commit"
    assert_equal "haunted\nhouse", shell_output("#{bin}/hub ls-files").strip
  end
end
