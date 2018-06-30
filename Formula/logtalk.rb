class Logtalk < Formula
  desc "Object-oriented logic programming language"
  homepage "https://logtalk.org/"
  url "https://github.com/LogtalkDotOrg/logtalk3/archive/lgt3180stable.tar.gz"
  version "3.18.0"
  sha256 "88b0bd2d426eec6add81580002c1709efc3c4b3423121d19587c03ab4cafec85"

  bottle do
    cellar :any_skip_relocation
    sha256 "76fed54df59e8c192c6888c05a762d53ba8d6dd4e36ff0e85b71e8c69d86af94" => :high_sierra
    sha256 "ee45142748660a689cf94968ab570b4be268d0ce95bd00c98d8035aece4dfc8c" => :sierra
    sha256 "00ac3bcd9ee04f242158092375708e0f0f14c74bc68b5acec0b095cef5e11ba2" => :el_capitan
  end

  option "with-swi-prolog", "Build using SWI Prolog as backend"
  option "with-gnu-prolog", "Build using GNU Prolog as backend (Default)"

  deprecated_option "swi-prolog" => "with-swi-prolog"
  deprecated_option "gnu-prolog" => "with-gnu-prolog"

  if build.with? "swi-prolog"
    depends_on "swi-prolog"
  else
    depends_on "gnu-prolog"
  end

  def install
    cd("scripts") { system "./install.sh", "-p", prefix }
  end
end
