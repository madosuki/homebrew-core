class Poppler < Formula
  desc "PDF rendering library (based on the xpdf-3.0 code base)"
  homepage "https://poppler.freedesktop.org/"
  url "https://poppler.freedesktop.org/poppler-0.67.0.tar.xz"
  sha256 "a34a4f1a0f5b610c584c65824e92e3ba3e08a89d8ab4622aee11b8ceea5366f9"
  head "https://anongit.freedesktop.org/git/poppler/poppler.git"

  bottle do
    sha256 "70384a7280c49efffea70c7b050d2d4a2593e9ab765847f18ae5adf6e2bd7075" => :mojave
    sha256 "190faa3e8ab648a374570e94ef0fe7f3bcddc40319951f9db088d1b3ef25ff4c" => :high_sierra
    sha256 "3d5bf3e91d6cf3fe5fcb63d99340583fdd01f87e269ecb0efd24e40a71266aff" => :sierra
    sha256 "670869115562ce49ec960918ade78512b0d9adc4289b7618dcc9ef93c4a2e1df" => :el_capitan
  end

  option "with-qt", "Build Qt5 backend"
  option "with-little-cms2", "Use color management system"
  option "with-nss", "Use NSS library for PDF signature validation"

  deprecated_option "with-qt4" => "with-qt"
  deprecated_option "with-qt5" => "with-qt"
  deprecated_option "with-lcms2" => "with-little-cms2"

  depends_on "cmake" => :build
  depends_on "gobject-introspection" => :build
  depends_on "pkg-config" => :build
  depends_on "cairo"
  depends_on "fontconfig"
  depends_on "freetype"
  depends_on "gettext"
  depends_on "glib"
  depends_on "jpeg"
  depends_on "libpng"
  depends_on "libtiff"
  depends_on "openjpeg"
  depends_on "qt" => :optional
  depends_on "little-cms2" => :optional
  depends_on "nss" => :optional

  conflicts_with "pdftohtml", "pdf2image", "xpdf",
    :because => "poppler, pdftohtml, pdf2image, and xpdf install conflicting executables"

  resource "font-data" do
    url "https://poppler.freedesktop.org/poppler-data-0.4.9.tar.gz"
    sha256 "1f9c7e7de9ecd0db6ab287349e31bf815ca108a5a175cf906a90163bdbe32012"
  end

  needs :cxx11 if build.with?("qt") || MacOS.version < :mavericks

  def install
    ENV.cxx11 if build.with?("qt") || MacOS.version < :mavericks

    args = std_cmake_args + %w[
      -DENABLE_XPDF_HEADERS=ON
      -DENABLE_GLIB=ON
      -DBUILD_GTK_TESTS=OFF
      -DWITH_GObjectIntrospection=ON
      -DENABLE_QT4=OFF
    ]

    if build.with? "qt"
      args << "-DENABLE_QT5=ON"
    else
      args << "-DENABLE_QT5=OFF"
    end

    if build.with? "little-cms2"
      args << "-DENABLE_CMS=lcms2"
    else
      args << "-DENABLE_CMS=none"
    end

    system "cmake", ".", *args
    system "make", "install"
    system "make", "clean"
    system "cmake", ".", "-DBUILD_SHARED_LIBS=OFF", *args
    system "make"
    lib.install "libpoppler.a"
    lib.install "cpp/libpoppler-cpp.a"
    lib.install "glib/libpoppler-glib.a"
    resource("font-data").stage do
      system "make", "install", "prefix=#{prefix}"
    end

    libpoppler = (lib/"libpoppler.dylib").readlink
    to_fix = ["#{lib}/libpoppler-cpp.dylib", "#{lib}/libpoppler-glib.dylib",
              *Dir["#{bin}/*"]]
    to_fix << "#{lib}/libpoppler-qt5.dylib" if build.with?("qt")
    to_fix.each do |f|
      macho = MachO.open(f)
      macho.change_dylib("@rpath/#{libpoppler}", "#{lib}/#{libpoppler}")
      macho.write!
    end
  end

  test do
    system "#{bin}/pdfinfo", test_fixtures("test.pdf")
  end
end
