require 'formula'

class Sphinx206 < Formula
  homepage 'http://www.sphinxsearch.com'
  url 'http://sphinxsearch.com/files/sphinx-2.0.6-release.tar.gz'
  sha1 'fe1b990052f961a100adba197abe806a3c1b70dc'

  head 'http://sphinxsearch.googlecode.com/svn/trunk/'

  bottle do
    sha1 "2d58704fcd15ec7d9c8ac7f4bb4391b9105ea35f" => :mavericks
    sha1 "5e3447a20996bd752d1b1793efef72b6dbf8421f" => :mountain_lion
    sha1 "cd9566b61321cb1ae618c0937c5133219183b478" => :lion
  end

  option 'mysql', 'Force compiling against MySQL'
  option 'pgsql', 'Force compiling against PostgreSQL'
  option 'id64',  'Force compiling with 64-bit ID support'

  depends_on "re2" => :optional
  depends_on :mysql if build.include? 'mysql'
  depends_on :postgresql if build.include? 'pgsql'

  # http://snowball.tartarus.org/
  resource 'stemmer' do
    url 'http://snowball.tartarus.org/dist/libstemmer_c.tgz'
    sha1 '1ac6bb16e829e9f3a58f62c27047c26784975aa1'
  end

  fails_with :llvm do
    build 2334
    cause "ld: rel32 out of range in _GetPrivateProfileString from /usr/lib/libodbc.a(SQLGetPrivateProfileString.o)"
  end

  fails_with :clang do
    build 421
    cause "sphinxexpr.cpp:1802:11: error: use of undeclared identifier 'ExprEval'"
  end

  def install
    (buildpath/'libstemmer_c').install resource('stemmer')

    inreplace "libstemmer_c/Makefile.in",
              "stem_ISO_8859_1_hungarian",
              "stem_ISO_8859_2_hungarian"

    args = %W[--prefix=#{prefix}
              --disable-dependency-tracking
              --localstatedir=#{var}
              --with-libstemmer]

    args << "--enable-id64" if build.include? 'id64'
    args << "--with-re2" if build.with? 're2'

    %w{mysql pgsql}.each do |db|
      if build.include? db
        args << "--with-#{db}"
      else
        args << "--without-#{db}"
      end
    end

    system "./configure", *args
    system "make install"
  end

  def caveats; <<-EOS.undent
    Sphinx has been compiled with libstemmer support.

    Sphinx depends on either MySQL or PostreSQL as a datasource.

    You can install these with Homebrew with:
      brew install mysql
        For MySQL server.

      brew install mysql-connector-c
        For MySQL client libraries only.

      brew install postgresql
        For PostgreSQL server.

    We don't install these for you when you install this formula, as
    we don't know which datasource you intend to use.
    EOS
  end
end
