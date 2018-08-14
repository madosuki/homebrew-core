require "language/node"

class Jhipster < Formula
  desc "Generate, develop and deploy Spring Boot + Angular applications"
  homepage "https://www.jhipster.tech/"
  url "https://registry.npmjs.org/generator-jhipster/-/generator-jhipster-5.2.0.tgz"
  sha256 "1da284e70b9257f762f5e008c2bca96f35509c2c7325cc24d8f9d068ba08922b"

  bottle do
    cellar :any_skip_relocation
    sha256 "7b9a529cd70064cc312f58d0c1229f725c3c40c5efcbec5d6855e1e9a7839ecc" => :high_sierra
    sha256 "1f5570a006808a8b842ff49379700a96f31eb7a1be7f64d400255ceebe91d3d0" => :sierra
    sha256 "012af802af64063ef97ffd6399a9379d276f1a3aabe9fef64c24a79a705ce382" => :el_capitan
  end

  depends_on "node"
  depends_on "yarn"
  depends_on :java => "1.8+"

  def install
    system "npm", "install", *Language::Node.std_npm_install_args(libexec)
    bin.install_symlink Dir["#{libexec}/bin/*"]
  end

  test do
    assert_match "execution is complete", shell_output("#{bin}/jhipster info")
  end
end
