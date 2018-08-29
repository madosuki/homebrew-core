class Openblas < Formula
  desc "Optimized BLAS library"
  homepage "https://www.openblas.net/"
  url "https://github.com/xianyi/OpenBLAS/archive/v0.3.2.tar.gz"
  sha256 "e8ba64f6b103c511ae13736100347deb7121ba9b41ba82052b1a018a65c0cb15"
  revision 1
  head "https://github.com/xianyi/OpenBLAS.git", :branch => "develop"

  bottle do
    sha256 "bc3e69ecb52089f782c48d7c8ae3c6a202fcbaf79503023d97ed4a7b6ba830c5" => :mojave
    sha256 "6e19cf0d1d388a065a41746177a0e6e5e1aa3b7c8d58c65a03660441b47c2b12" => :high_sierra
    sha256 "68680574b7dd9b038bc94e137e5bb16a6a3c02fbb621907080e1f72f398a3c2a" => :sierra
    sha256 "d272b0b7e084ea7a578d20d321635100bde056bbbe6c1cb171573c4b11a78db2" => :el_capitan
  end

  keg_only :provided_by_macos,
           "macOS provides BLAS and LAPACK in the Accelerate framework"

  option "with-openmp", "Enable parallel computations with OpenMP"

  depends_on "gcc" # for gfortran

  fails_with :clang if build.with? "openmp"

  # Fixes CMake symbol export bug; this patch will be in the OpenBLAS
  # 0.3.3 release
  patch do
    url "https://github.com/xianyi/OpenBLAS/pull/1703.patch?full_index=1"
    sha256 "b7c6909b0630b6ae73c9e98cedf5acb494ac4b94bb5c974f674bd77b66b82c27"
  end

  def install
    ENV["DYNAMIC_ARCH"] = "1" if build.bottle?
    ENV["USE_OPENMP"] = "1" if build.with? "openmp"

    # Must call in two steps
    system "make", "CC=#{ENV.cc}", "FC=gfortran", "libs", "netlib", "shared"
    system "make", "PREFIX=#{prefix}", "install"

    lib.install_symlink "libopenblas.dylib" => "libblas.dylib"
    lib.install_symlink "libopenblas.dylib" => "liblapack.dylib"
  end

  test do
    (testpath/"test.c").write <<~EOS
      #include <stdio.h>
      #include <stdlib.h>
      #include <math.h>
      #include "cblas.h"

      int main(void) {
        int i;
        double A[6] = {1.0, 2.0, 1.0, -3.0, 4.0, -1.0};
        double B[6] = {1.0, 2.0, 1.0, -3.0, 4.0, -1.0};
        double C[9] = {.5, .5, .5, .5, .5, .5, .5, .5, .5};
        cblas_dgemm(CblasColMajor, CblasNoTrans, CblasTrans,
                    3, 3, 2, 1, A, 3, B, 3, 2, C, 3);
        for (i = 0; i < 9; i++)
          printf("%lf ", C[i]);
        printf("\\n");
        if (fabs(C[0]-11) > 1.e-5) abort();
        if (fabs(C[4]-21) > 1.e-5) abort();
        return 0;
      }
    EOS
    system ENV.cc, "test.c", "-I#{include}", "-L#{lib}", "-lopenblas",
                   "-o", "test"
    system "./test"
  end
end
