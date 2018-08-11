class Mint < Formula
  desc "Dependency manager that installs and runs Swift command-line tool packages"
  homepage "https://github.com/yonaskolb/Mint"
  url "https://github.com/yonaskolb/Mint/archive/0.11.1.tar.gz"
  sha256 "9a545bc78c2d346171e0d8c69d2089da12e17b2b393d127254e7e8efa785deb5"

  bottle do
    cellar :any_skip_relocation
    sha256 "d07d2e5e0bf5619bb6d423c5ceaa070410a55cfb9d1713fb8d79994facf8929f" => :high_sierra
    sha256 "75fa5d324b1881a2a57453d5eee3f4d39a1244ea0999d5a694dafc83bf88e656" => :sierra
  end

  depends_on :xcode => ["9.2", :build]

  def install
    system "make", "install", "PREFIX=#{prefix}"
  end

  test do
    # Test by showing the help scree
    system "#{bin}/mint", "--help"
    # Test showing list of installed tools
    system "#{bin}/mint", "list"
  end
end
