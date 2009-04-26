# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header$

EAPI="2"
DESCRIPTION="Pike programming language and runtime"
HOMEPAGE="http://pike.ida.liu.se/"
#SRC_URI="http://pike.ida.liu.se/pub/pike/all/${PV}/Pike-v${PV}.tar.gz"
SRC_URI="http://pike.ida.liu.se/generated/pikefarm/packages/devel/latest -> Pike-7.8-snapshot.tar.gz"

LICENSE="GPL-2 LGPL-2.1 MPL-1.1"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~hppa ~ia64 ~mips ~ppc ~sparc ~x86 ~x86-fbsd"
IUSE="bzip2 debug doc fftw gdbm gtk hardened jpeg kerberos mime mysql opengl pcre pdf scanner sdl svg tiff truetype zlib"

DEPEND="dev-libs/nettle
	dev-libs/gmp
	media-libs/giflib
	bzip2? ( app-arch/bzip2 )
	fftw? ( sci-libs/fftw )
	gdbm? ( sys-libs/gdbm )
	gtk? ( =x11-libs/gtk+-1.2* )
	jpeg? ( media-libs/jpeg )
	kerberos? ( virtual/krb5 )
	mysql? ( virtual/mysql )
	opengl? ( virtual/opengl virtual/glut )
	pcre? ( dev-libs/libpcre )
	pdf? ( media-libs/pdflib )
	!x86-fbsd? ( scanner? ( media-gfx/sane-backends ) )
	sdl? ( media-libs/libsdl media-libs/sdl-mixer )
	svg? ( gnome-base/librsvg )
	tiff? ( media-libs/tiff )
	truetype? ( media-libs/freetype )
	zlib? ( sys-libs/zlib )"
RDEPEND=""

#S=${WORKDIR}/Pike-v${PV}
S=${WORKDIR}/Pike-v7.8-snapshot

src_compile() {
	local myconf=""
	# ffmpeg is broken atm #110136
	myconf="${myconf} --without-_Ffmpeg"
	# on hardened, disable runtime-generated code
	# otherwise let configure work it out for itself
	use hardened && myconf="${myconf} --without-machine-code"

	make \
		CONFIGUREARGS=" \
			--prefix=/usr \
			--disable-make_conf \
			--disable-noopty-retry \
			--without-cdebug \
			--without-bundles \
			--without-copt \
			--without-ssleay \
			--with-crypt \
			--with-gif \
			--with-gmp \
			--with-bignums \
			$(use_with bzip2 Bz2) \
			$(use_with debug rtldebug) \
			$(use_with fftw) \
			$(use_with gdbm) \
			$(use_with jpeg jpeglib) \
			$(use_with kerberos Kerberos) \
			$(use_with mime MIME) \
			$(use_with mysql) \
			$(use_with opengl GL) \
			$(use_with opengl GLUT) \
			$(use_with pcre _Regexp_PCRE) \
			$(use_with pdf libpdf) \
			$(use_with scanner sane) \
			$(use_with sdl SDL) \
			$(use_with sdl SDL_mixer) \
			$(use_with svg) \
			$(use_with tiff tifflib) \
			$(use_with truetype ttflib) \
			$(use_with truetype freetype) \
			$(use_with zlib) \
			${myconf} \
			" || die "compilation failed"

	if use doc; then
		PATH="${S}/bin:${PATH}" make doc || die "doc failed"
	fi
}

src_install() {
	# do not remove modules to avoid sandbox violation.
	sed -i s/rm\(mod\+\"\.o\"\)\;/break\;/ "${S}"/bin/install.pike || die "Failed to modify install.pike"
	if use doc ; then
		make INSTALLARGS="--traditional" buildroot="${D}" install || die
		einfo "Installing 60MB of docs, this could take some time ..."
		dohtml -r "${S}"/refdoc/traditional_manual "${S}"/refdoc/modref
	else
		make INSTALLARGS="--traditional" buildroot="${D}" install_nodoc || die
	fi
	# Installation is a bit broken.. remove the doc sources.
	rm -rf "${D}/usr/doc"
	# Install the man pages in the proper location.
	rm -rf "${D}/usr/man" && doman "${S}/man/pike.1"
}