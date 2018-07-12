class Dmd < Formula
  desc "D programming language compiler for macOS"
  homepage "https://dlang.org/"

  stable do
    url "https://github.com/dlang/dmd/archive/v2.081.1.tar.gz"
    sha256 "14f3aafe1c93c86646aaeb3ed7361a5fc5a24374cf25c8848c81942bfd9fae1a"

    resource "druntime" do
      url "https://github.com/dlang/druntime/archive/v2.081.0.tar.gz"
      sha256 "ab8a7b5c99a94a8e58b6761309997f5b54b317269769a8fe3b4a994aa65a4946"
    end

    resource "phobos" do
      url "https://github.com/dlang/phobos/archive/v2.081.0.tar.gz"
      sha256 "cd5785ebd83a5edc11cb31732042582c4a741c4aca491e538dc4ee382a60881f"
    end

    resource "tools" do
      url "https://github.com/dlang/tools/archive/v2.081.0.tar.gz"
      sha256 "452ba1709dc6aa50a0a4363916119d9ed7bd261c421483c2b187f55f8c774d17"
    end
  end

  bottle do
    sha256 "db80b1127ed24bc1092c2c5aa3e2543649add79d67d23bd573533e3023014d11" => :high_sierra
    sha256 "f8e42fccb34fece3eaa9eed5363ddb21597a7b74e27fc8de3ec993f91e2fcbfa" => :sierra
    sha256 "4de616383512748eb474f12edda62bfe9a1004907c875f85db5e51665c011887" => :el_capitan
  end

  head do
    url "https://github.com/dlang/dmd.git"

    resource "druntime" do
      url "https://github.com/dlang/druntime.git"
    end

    resource "phobos" do
      url "https://github.com/dlang/phobos.git"
    end

    resource "tools" do
      url "https://github.com/dlang/tools.git"
    end
  end

  def install
    make_args = ["INSTALL_DIR=#{prefix}", "MODEL=#{Hardware::CPU.bits}", "BUILD=release", "-f", "posix.mak"]

    dmd_make_args = ["SYSCONFDIR=#{etc}", "TARGET_CPU=X86", "AUTO_BOOTSTRAP=1", "ENABLE_RELEASE=1"]

    system "make", *dmd_make_args, *make_args

    make_args.unshift "DMD_DIR=#{buildpath}", "DRUNTIME_PATH=#{buildpath}/druntime", "PHOBOS_PATH=#{buildpath}/phobos"

    (buildpath/"druntime").install resource("druntime")
    system "make", "-C", "druntime", *make_args

    (buildpath/"phobos").install resource("phobos")
    system "make", "-C", "phobos", "VERSION=#{buildpath}/VERSION", *make_args

    resource("tools").stage do
      inreplace "posix.mak", "install: $(TOOLS) $(CURL_TOOLS)", "install: $(TOOLS) $(ROOT)/dustmite"
      system "make", "install", *make_args
    end

    bin.install "generated/osx/release/64/dmd"
    pkgshare.install "samples"
    man.install Dir["docs/man/*"]

    (include/"dlang/dmd").install Dir["druntime/import/*"]
    cp_r ["phobos/std", "phobos/etc"], include/"dlang/dmd"
    lib.install Dir["druntime/lib/*", "phobos/**/libphobos2.a"]

    (buildpath/"dmd.conf").write <<~EOS
      [Environment]
      DFLAGS=-I#{opt_include}/dlang/dmd -L-L#{opt_lib}
    EOS
    etc.install "dmd.conf"
  end

  # Previous versions of this formula may have left in place an incorrect
  # dmd.conf.  If it differs from the newly generated one, move it out of place
  # and warn the user.
  def install_new_dmd_conf
    conf = etc/"dmd.conf"

    # If the new file differs from conf, etc.install drops it here:
    new_conf = etc/"dmd.conf.default"
    # Else, we're already using the latest version:
    return unless new_conf.exist?

    backup = etc/"dmd.conf.old"
    opoo "An old dmd.conf was found and will be moved to #{backup}."
    mv conf, backup
    mv new_conf, conf
  end

  def post_install
    install_new_dmd_conf
  end

  test do
    system bin/"dmd", pkgshare/"samples/hello.d"
    system "./hello"
  end
end
