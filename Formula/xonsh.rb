class Xonsh < Formula
  include Language::Python::Virtualenv

  desc "Python-ish, BASHwards-compatible shell language and command prompt"
  homepage "http://xon.sh"
  url "https://github.com/xonsh/xonsh/archive/0.6.8.tar.gz"
  sha256 "77d8b64ddc600549fd073a3ead20c41e049e61e26e7f3337322449f7c9b11b71"
  revision 1
  head "https://github.com/xonsh/xonsh.git"

  bottle do
    cellar :any_skip_relocation
    sha256 "11dbedbc6f2537c85b219b5413ab67179c6ff45424dc5303400cc110db20de2e" => :high_sierra
    sha256 "3a831c959a7095513ff26467f2326aa1271c74c1a942945cd94b41ed775ec6a0" => :sierra
    sha256 "1c4015239d5a89aa4938558fd4264b7483f44d39f0d2f0416ecbef10fe2db9e4" => :el_capitan
  end

  depends_on "python"

  def install
    virtualenv_install_with_resources
  end

  test do
    assert_match "4", shell_output("#{bin}/xonsh -c 2+2")
  end
end
