class Dxpy < Formula
  include Language::Python::Virtualenv

  desc "DNAnexus toolkit utilities and platform API bindings for Python"
  homepage "https://github.com/dnanexus/dx-toolkit"
  url "https://files.pythonhosted.org/packages/49/30/5f66717f2bd26bf4c562741e22821341a211b3ed383577d0697cfcb2711b/dxpy-0.257.3.tar.gz"
  sha256 "4cb99e16d0f40efe3542b4fcaa2b4b707e3db531790dea93d7237f4b8011cc23"

  bottle do
    cellar :any_skip_relocation
    sha256 "b5d35df80be660470c7d7116f6463567044866e2a8b5a1ae783fbed997c3b3fc" => :high_sierra
    sha256 "35c5878e4775e96903484dc8a5734ae78d7e4e3b9fd2ea31184bcfe1292fa9cc" => :sierra
    sha256 "1aea695dfcc85d4e1bfcc26de344b6145e8df9f2c3567afa26de5c79be1c5a84" => :el_capitan
  end

  depends_on "python@2"

  resource "beautifulsoup4" do
    url "https://files.pythonhosted.org/packages/26/79/ef9a8bcbec5abc4c618a80737b44b56f1cb393b40238574078c5002b97ce/beautifulsoup4-4.4.1.tar.gz"
    sha256 "87d4013d0625d4789a4f56b8d79a04d5ce6db1152bb65f1d39744f7709a366b4"
  end

  resource "fusepy" do
    url "https://files.pythonhosted.org/packages/0f/4d/26a937988e2633aa9f1d5268aa3782afaee9a482c6c6f221fc1e1ae58862/fusepy-2.0.2.tar.gz"
    sha256 "aa5929d5464caed81406481a330dc975d1a95b9a41d0a98f095c7e18fe501bfc"
  end

  resource "futures" do
    url "https://files.pythonhosted.org/packages/8d/73/b5fff618482bc06c9711e7cdc0d5d7eb1904d35898f48f2d7f9696b08bef/futures-3.0.4.tar.gz"
    sha256 "19485d83f7bd2151c0aeaf88fbba3ee50dadfb222ffc3b66a344ef4952b782a3"
  end

  resource "psutil" do
    url "https://files.pythonhosted.org/packages/fe/69/c0d8e9b9f8a58cbf71aa4cf7f27c27ee0ab05abe32d9157ec22e223edef4/psutil-3.3.0.tar.gz"
    sha256 "421b6591d16b509aaa8d8c15821d66bb94cb4a8dc4385cad5c51b85d4a096d85"
  end

  resource "python-dateutil" do
    url "https://files.pythonhosted.org/packages/b9/d3/7800c2560d81f112417d245468b8c8d71a068d98cd13c3c14f193a297036/python-dateutil-2.5.0.tar.gz"
    sha256 "c1f7a66b0021bd7b206cc60dd47ecc91b931cdc5258972dc56b25186fa9a96a5"
  end

  resource "python-magic" do
    url "https://files.pythonhosted.org/packages/21/57/57c47169c651534014a9852ec690fc0893bab2f67e24d6dab3c945522e7d/python-magic-0.4.6.tar.gz"
    sha256 "903d3d3c676e2b1244892954e2bbbe27871a633385a9bfe81f1a81a7032df2fe"
  end

  resource "requests" do
    url "https://files.pythonhosted.org/packages/0a/00/8cc925deac3a87046a4148d7846b571cf433515872b5430de4cd9dea83cb/requests-2.7.0.tar.gz"
    sha256 "398a3db6d61899d25fd4a06c6ca12051b0ce171d705decd7ed5511517b4bb93d"
  end

  resource "six" do
    url "https://files.pythonhosted.org/packages/16/d8/bc6316cf98419719bd59c91742194c111b6f2e85abac88e496adefaf7afe/six-1.11.0.tar.gz"
    sha256 "70e8a77beed4562e7f14fe23a786b54f6296e34344c23bc42f07b15018ff98e9"
  end

  resource "ws4py" do
    url "https://files.pythonhosted.org/packages/d6/69/0f5723c5784317278866891546c5fe4521dc404600df504651e9c934fd0d/ws4py-0.3.2.tar.gz"
    sha256 "48a4e005496a60081f74ca130ce55603ff87e1507483535acf902b94761bda8b"
  end

  resource "xattr" do
    url "https://files.pythonhosted.org/packages/c5/80/b25d549ae4bf4f3e9635a331b759ffca2de4dd8a78dc5106d1ca92f5d08d/xattr-0.6.4.tar.gz"
    sha256 "f9dcebc99555634b697fa3dad8ea3047deb389c6f1928d347a0c49277a5c0e9e"
  end

  def install
    virtualenv_install_with_resources
  end

  test do
    dxenv = <<~EOS
      API server protocol	https
      API server host		api.dnanexus.com
      API server port		443
      Current workspace	None
      Current folder		None
      Current user		None
    EOS
    assert_match dxenv, shell_output("#{bin}/dx env")
  end
end
