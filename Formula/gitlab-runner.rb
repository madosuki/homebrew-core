class GitlabRunner < Formula
  desc "The official GitLab CI runner written in Go"
  homepage "https://gitlab.com/gitlab-org/gitlab-runner"
  url "https://gitlab.com/gitlab-org/gitlab-runner.git",
      :tag => "v11.0.2",
      :revision => "1db57d4aea2aa85adaa5b020493b6756107466c6"
  head "https://gitlab.com/gitlab-org/gitlab-runner.git"

  bottle do
    cellar :any_skip_relocation
    sha256 "635072ae4fcac45079cbf3a795373f6c2d876ae4c37ceaa07c27ec87f169c2ec" => :high_sierra
    sha256 "e5e156fffbc4734ebd4128e590dfc2ba8a42e91d062ecac449b810569ba267f0" => :sierra
    sha256 "9ff26319d023c3b35939181039625fa003995b70ccf91ecc9e411ad9206c87f9" => :el_capitan
  end

  depends_on "go" => :build
  depends_on "go-bindata" => :build
  depends_on "docker" => :recommended

  resource "prebuilt-x86_64.tar.xz" do
    url "https://gitlab-runner-downloads.s3.amazonaws.com/v11.0.2/docker/prebuilt-x86_64.tar.xz",
        :using => :nounzip
    version "11.0.2"
    sha256 "a5b6fc4ae25577966d24ef34aa68ed296001b2f166851052b2db0facd89a0cdb"
  end

  resource "prebuilt-arm.tar.xz" do
    url "https://gitlab-runner-downloads.s3.amazonaws.com/v11.0.2/docker/prebuilt-arm.tar.xz",
        :using => :nounzip
    version "11.0.2"
    sha256 "bc54019871aa2446cf2f76853d604b2ed77eac601818ed3f798fd865df5bd862"
  end

  def install
    ENV["GOPATH"] = buildpath
    dir = buildpath/"src/gitlab.com/gitlab-org/gitlab-runner"
    dir.install buildpath.children

    cd dir do
      Pathname.pwd.install resource("prebuilt-x86_64.tar.xz"),
                           resource("prebuilt-arm.tar.xz")
      system "go-bindata", "-pkg", "docker", "-nocompress", "-nomemcopy",
                           "-nometadata", "-o",
                           "#{dir}/executors/docker/bindata.go",
                           "prebuilt-x86_64.tar.xz",
                           "prebuilt-arm.tar.xz"

      proj = "gitlab.com/gitlab-org/gitlab-runner"
      commit = Utils.popen_read("git", "rev-parse", "--short", "HEAD").chomp
      branch = version.to_s.split(".")[0..1].join("-") + "-stable"
      built = Time.new.strftime("%Y-%m-%dT%H:%M:%S%:z")
      system "go", "build", "-ldflags", <<~EOS
        -X #{proj}/common.NAME=gitlab-runner
        -X #{proj}/common.VERSION=#{version}
        -X #{proj}/common.REVISION=#{commit}
        -X #{proj}/common.BRANCH=#{branch}
        -X #{proj}/common.BUILT=#{built}
      EOS

      bin.install "gitlab-runner"
      prefix.install_metafiles
    end
  end

  plist_options :manual => "gitlab-runner start"

  def plist; <<~EOS
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
      <dict>
        <key>SessionCreate</key><false/>
        <key>KeepAlive</key><true/>
        <key>RunAtLoad</key><true/>
        <key>Disabled</key><false/>
        <key>Label</key>
        <string>#{plist_name}</string>
        <key>ProgramArguments</key>
        <array>
          <string>#{opt_bin}/gitlab-runner</string>
          <string>run</string>
          <string>--working-directory</string>
          <string>#{ENV["HOME"]}</string>
          <string>--config</string>
          <string>#{ENV["HOME"]}/.gitlab-runner/config.toml</string>
          <string>--service</string>
          <string>gitlab-runner</string>
          <string>--syslog</string>
        </array>
      </dict>
    </plist>
  EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/gitlab-runner --version")
  end
end
