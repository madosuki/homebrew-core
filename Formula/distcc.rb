class Distcc < Formula
  desc "Distributed compiler client and server"
  homepage "https://github.com/distcc/distcc/"
  url "https://github.com/distcc/distcc/releases/download/v3.3.1/distcc-3.3.1.tar.gz"
  sha256 "750665c1284a0d7ad54961751f3bbd5e09a66ea10d1f3d0660d10eb5cc27199f"
  head "https://github.com/distcc/distcc.git"

  bottle do
    sha256 "2f91a0ccf6b56b24d84dea6efcebdd977f93ca509c8e2a3c9debaa690a539d5b" => :high_sierra
    sha256 "fd960b0812628dfbd0609064252087d5aa29e289c5e30898b084ebb3607c264e" => :sierra
    sha256 "8ad03ced9351a105470a36c59309f369cce8832784c36ac53505845a7fc74d8f" => :el_capitan
  end

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "python"

  resource "libiberty" do
    url "https://mirrors.ocf.berkeley.edu/debian/pool/main/libi/libiberty/libiberty_20180614.orig.tar.xz"
    mirror "https://mirrorservice.org/sites/ftp.debian.org/debian/pool/main/libi/libiberty/libiberty_20180614.orig.tar.xz"
    sha256 "ffee051e01d07833ba2ae8cfaf8fffaa8047f530d725c6c6fcaf51c3d604740c"
  end

  def install
    # While libiberty recommends that packages vendor libiberty into their own source,
    # distcc wants to have a package manager-installed version.
    # Rather than make a package for a floating package like this, let's just
    # make it a resource.
    buildpath.install resource("libiberty")
    cd "libiberty" do
      system "./configure"
      system "make"
    end
    ENV.append "LDFLAGS", "-L#{buildpath}/libiberty"
    ENV.append_to_cflags "-I#{buildpath}/include"

    # Make sure python stuff is put into the Cellar.
    # --root triggers a bug and installs into HOMEBREW_PREFIX/lib/python2.7/site-packages instead of the Cellar.
    inreplace "Makefile.in", '--root="$$DESTDIR"', ""
    system "./autogen.sh"
    system "./configure", "--prefix=#{prefix}"
    system "make", "install"
  end

  plist_options :manual => "distccd"

  def plist; <<~EOS
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
      <dict>
        <key>Label</key>
        <string>#{plist_name}</string>
        <key>RunAtLoad</key>
        <true/>
        <key>KeepAlive</key>
        <true/>
        <key>ProgramArguments</key>
        <array>
            <string>#{opt_prefix}/bin/distccd</string>
            <string>--daemon</string>
            <string>--no-detach</string>
            <string>--allow=192.168.0.1/24</string>
        </array>
        <key>WorkingDirectory</key>
        <string>#{opt_prefix}</string>
      </dict>
    </plist>
  EOS
  end

  test do
    system "#{bin}/distcc", "--version"
  end
end
