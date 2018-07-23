class Proselint < Formula
  include Language::Python::Virtualenv

  desc "Linter for prose"
  homepage "http://proselint.com"
  url "https://files.pythonhosted.org/packages/32/1b/573ba8b6bf254906c7c305cb1708036d5f989c8997c89a7d01eba1e8a363/proselint-0.9.0.tar.gz"
  sha256 "4b91f71b15aba9e1f44161261ad9b4e2b314ca663346f281750b80ee88982bba"
  head "https://github.com/amperser/proselint.git"

  bottle do
    cellar :any_skip_relocation
    sha256 "fa76d08057c3c6bd51a07f1476641c100811a8501f0ccebe5477fe4b9438bd83" => :high_sierra
    sha256 "028ab9bffa58f5030e88ab489327874c7a6e337b38b47867af684ea0e7dca598" => :sierra
    sha256 "b813819099009a35035eec564ea8d89d5ca53d1c942863c7b823d88abe1bc184" => :el_capitan
  end

  depends_on "python@2"

  resource "click" do
    url "https://files.pythonhosted.org/packages/95/d9/c3336b6b5711c3ab9d1d3a80f1a3e2afeb9d8c02a7166462f6cc96570897/click-6.7.tar.gz"
    sha256 "f15516df478d5a56180fbf80e68f206010e6d160fc39fa508b65e035fd75130b"
  end

  resource "future" do
    url "https://files.pythonhosted.org/packages/00/2b/8d082ddfed935f3608cc61140df6dcbf0edea1bc3ab52fb6c29ae3e81e85/future-0.16.0.tar.gz"
    sha256 "e39ced1ab767b5936646cedba8bcce582398233d6a627067d4c6a454c90cfedb"
  end

  resource "six" do
    url "https://files.pythonhosted.org/packages/16/d8/bc6316cf98419719bd59c91742194c111b6f2e85abac88e496adefaf7afe/six-1.11.0.tar.gz"
    sha256 "70e8a77beed4562e7f14fe23a786b54f6296e34344c23bc42f07b15018ff98e9"
  end

  def install
    virtualenv_install_with_resources
  end

  test do
    output = pipe_output("#{bin}/proselint --compact -", "John is very unique.")
    assert_match /weasel_words\.very.*uncomparables/m, output
  end
end
