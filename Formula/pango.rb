class Pango < Formula
  desc "Framework for layout and rendering of i18n text"
  homepage "https://www.pango.org/"
  url "https://download.gnome.org/sources/pango/1.42/pango-1.42.2.tar.xz"
  sha256 "b1e416b4d40416ef6c8224cf146492b86848703264ba88f792290992cf3ca1e2"
  revision 1

  bottle do
    sha256 "7cababfdf855fb476c720a0321b61da3b136aafbb95d9777f3bd31feaf42f138" => :high_sierra
    sha256 "c7f02c6d349e1b936966035feb3bc85cb69f58c28d1cff415c7755152332e41e" => :sierra
    sha256 "e2996a4159ae800ace51b517b0f0690da8003fa9ce76c38e0df80bd46fd9446f" => :el_capitan
  end

  head do
    url "https://gitlab.gnome.org/GNOME/pango.git"

    depends_on "automake" => :build
    depends_on "autoconf" => :build
    depends_on "libtool" => :build
    depends_on "gtk-doc" => :build
  end

  depends_on "gobject-introspection" => :build
  depends_on "pkg-config" => :build
  depends_on "cairo"
  depends_on "fribidi"
  depends_on "fontconfig"
  depends_on "glib"
  depends_on "harfbuzz"

  # This fixes a font-size problem in gtk
  # For discussion, see https://bugzilla.gnome.org/show_bug.cgi?id=787867
  patch do
    url "https://gitlab.gnome.org/tschoonj/pango/commit/60df2b006e5d4553abc7bb5fe9a99539c91b0022.patch"
    sha256 "d5ece753cf393ef507dd2b0415721b4381159da5e2f40793c6d85741b1b163bc"
  end

  def install
    system "./autogen.sh" if build.head?
    system "./configure", "--disable-dependency-tracking",
                          "--disable-silent-rules",
                          "--prefix=#{prefix}",
                          "--with-html-dir=#{share}/doc",
                          "--enable-introspection=yes",
                          "--enable-static",
                          "--without-xft"

    system "make"
    system "make", "install"
  end

  test do
    system "#{bin}/pango-view", "--version"
    (testpath/"test.c").write <<~EOS
      #include <pango/pangocairo.h>

      int main(int argc, char *argv[]) {
        PangoFontMap *fontmap;
        int n_families;
        PangoFontFamily **families;
        fontmap = pango_cairo_font_map_get_default();
        pango_font_map_list_families (fontmap, &families, &n_families);
        g_free(families);
        return 0;
      }
    EOS
    cairo = Formula["cairo"]
    fontconfig = Formula["fontconfig"]
    freetype = Formula["freetype"]
    gettext = Formula["gettext"]
    glib = Formula["glib"]
    libpng = Formula["libpng"]
    pixman = Formula["pixman"]
    flags = %W[
      -I#{cairo.opt_include}/cairo
      -I#{fontconfig.opt_include}
      -I#{freetype.opt_include}/freetype2
      -I#{gettext.opt_include}
      -I#{glib.opt_include}/glib-2.0
      -I#{glib.opt_lib}/glib-2.0/include
      -I#{include}/pango-1.0
      -I#{libpng.opt_include}/libpng16
      -I#{pixman.opt_include}/pixman-1
      -D_REENTRANT
      -L#{cairo.opt_lib}
      -L#{gettext.opt_lib}
      -L#{glib.opt_lib}
      -L#{lib}
      -lcairo
      -lglib-2.0
      -lgobject-2.0
      -lintl
      -lpango-1.0
      -lpangocairo-1.0
    ]
    system ENV.cc, "test.c", "-o", "test", *flags
    system "./test"
  end
end
