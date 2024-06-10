# -*- sh -*-
# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header$

EAPI="8"

inherit multilib

DESCRIPTION="Pike programming language and runtime"
HOMEPAGE="http://pike.lysator.liu.se/"
# Get the alpha/beta designator (if any).
MY_PR="${PV//[0-9._]/}"
MY_PR="${MY_PR:-all}"
# Strip the alpha/beta designator.
MY_PV="${PV/_*/}"
SRC_URI="http://pike.lysator.liu.se/pub/pike/${MY_PR}/${MY_PV}/Pike-v${MY_PV}.tar.gz"

MY_RELEASE="${MY_PV%.*}"
MY_MAJOR="${MY_PV//.[0-9.]*/}"
MY_MINOR="${MY_RELEASE/[0-9]./}"

LICENSE="GPL-2 LGPL-2.1 MPL-1.1"
SLOT="0/${MY_RELEASE}"

MY_STABLE="no"
case ${MY_MINOR} in
	*0|*2|*4|*6|*8)
		# Even minor means stable release.
		MY_STABLE="yes"
	;;
esac

KEYWORDS="~alpha ~amd64 ~hppa ~ia64 ~mips ~ppc ~sparc ~x86 ~x86-fbsd"

if [[ ${MY_PR} == all && ${MY_STABLE} == yes ]]; then
	# Stable branch and not an alpha or beta release.
	KEYWORDS="alpha amd64 hppa ia64 mips ppc sparc x86 x86-fbsd"
fi

IUSE="bzip2 debug doc fftw gdbm glut gnome gtk gtk1 hardened java jpeg kerberos msql mysql odbc opengl oracle pcre pdf scanner sdl sqlite svg test tiff truetype vcdiff webp zlib"

DEPEND="virtual/libcrypt:=
	dev-libs/nettle
	dev-libs/gmp
	media-libs/giflib
	bzip2? ( app-arch/bzip2 )
	fftw? ( sci-libs/fftw )
	gdbm? ( sys-libs/gdbm )
	gtk1? ( =x11-libs/gtk+-1.2* )
	gtk? ( >x11-libs/gtk+-2 )
	gtk? ( gnome? ( gnome-base/libgnome gnome-base/libgnomeui gnome-base/libglade ) )
	gtk? ( opengl? ( x11-libs/gtkglarea ) )
	java? ( virtual/jdk dev-libs/libffi )
	jpeg? ( virtual/jpeg )
	kerberos? ( virtual/krb5 net-libs/libgssglue )
	msql? ( dev-db/msql )
	mysql? ( || ( virtual/libmysqlclient <dev-db/mysql-5.6 <dev-db/mariadb-10 ) )
	odbc? ( dev-db/libiodbc )
	opengl? ( virtual/opengl glut? ( media-libs/freeglut ) )
	oracle? ( || ( dev-db/oracle-instantclient[sdk] dev-db/oracle-instantclient-basic ) )
	pcre? ( dev-libs/libpcre )
	pdf? ( media-libs/pdflib )
	!x86-fbsd? ( scanner? ( media-gfx/sane-backends ) )
	sdl? ( media-libs/libsdl media-libs/sdl-mixer )
	sqlite? ( dev-db/sqlite )
	svg? ( gnome-base/librsvg )
	test? ( sys-devel/m4 )
	tiff? ( media-libs/tiff )
	truetype? ( >media-libs/freetype-2 )
	vcdiff? ( dev-util/open-vcdiff )
	webp? ( media-libs/libwebp )
	zlib? ( sys-libs/zlib )"

RDEPEND="virtual/libcrypt:=
	dev-libs/nettle
	dev-libs/gmp
	media-libs/giflib
	bzip2? ( app-arch/bzip2 )
	fftw? ( sci-libs/fftw )
	gdbm? ( sys-libs/gdbm )
	gtk1? ( =x11-libs/gtk+-1.2* )
	gtk? ( >x11-libs/gtk+-2 )
	gtk? ( gnome? ( gnome-base/libgnome gnome-base/libgnomeui gnome-base/libglade ) )
	gtk? ( opengl? ( x11-libs/gtkglarea ) )
	java? ( virtual/jdk dev-libs/libffi )
	jpeg? ( virtual/jpeg )
	kerberos? ( virtual/krb5 net-libs/libgssglue )
	msql? ( dev-db/msql )
	mysql? ( || ( virtual/libmysqlclient <dev-db/mysql-5.6 <dev-db/mariadb-10 ) )
	odbc? ( dev-db/libiodbc )
	opengl? ( virtual/opengl glut? ( media-libs/freeglut ) )
	oracle? ( || ( dev-db/oracle-instantclient dev-db/oracle-instantclient-basic ) )
	pcre? ( dev-libs/libpcre )
	pdf? ( media-libs/pdflib )
	!x86-fbsd? ( scanner? ( media-gfx/sane-backends ) )
	sdl? ( media-libs/libsdl media-libs/sdl-mixer )
	sqlite? ( dev-db/sqlite )
	svg? ( gnome-base/librsvg )
	tiff? ( media-libs/tiff )
	truetype? ( >media-libs/freetype-2 )
	vcdiff? ( dev-util/open-vcdiff )
	webp? ( media-libs/libwebp )
	zlib? ( sys-libs/zlib )"

S=${WORKDIR}/Pike-v${MY_PV}

# terminfo-v6.patch:
#   Ncurses version 6 added a new (incompatible)
#   format for terminfo files.
PATCHES=(
	"${FILESDIR}/terminfo-v6.patch"
	)

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
			--without-ssleay \
			--with-crypt \
			--with-gif \
			--with-gmp \
			--with-bignums \
			$(use_with bzip2 Bz2) \
			$(use_with debug rtldebug) \
			$(use_with fftw) \
			$(use_with gdbm) \
			$(use_with gtk1 GTK1) \
			$(use_with gtk GTK2) \
			$(use_with java Java) \
			$(use_with jpeg jpeglib) \
			$(use_with kerberos Kerberos) \
			$(use_with kerberos gssapi) \
			$(use_with msql) \
			$(use_with mysql) \
			$(use_with odbc Odbc) \
			$(use_with opengl GL) \
			$(use_with oracle) \
			$(use opengl && use_with glut GLUT) \
			$(use opengl || use_with opengl GLUT) \
			$(use_with pcre _Regexp_PCRE) \
			$(use_with pdf libpdf) \
			$(use_with scanner sane) \
			$(use_with sdl SDL) \
			$(use_with sdl SDL_mixer) \
			$(use_with svg) \
			$(use_with tiff tifflib) \
			$(use_with truetype freetype) \
			$(use_with vcdiff) \
			$(use_with webp _Image_WebP) \
			$(use_with zlib) \
			${myconf} \
			" || die "compilation failed"

	if use doc; then
		PATH="${S}/bin:${PATH}" make doc || die "doc failed"
	fi
}

src_install() {
	# do not remove modules to avoid sandbox violation.
        # The sandbox really ought to allow deletion of files
        # that belong to previous installs of the ebuild, or
	# even better: hide them.
	sed -i s/rm\(mod\+\"\.o\"\)\;/break\;/ "${S}"/bin/install.pike || die "Failed to modify install.pike (1)"
	sed -i 's/\(Array.map *( *files_to_delete *- *files_to_not_delete, *rm *);\)/; \/\/ \1/' "${S}"/bin/install.pike || die "Failed to modify install.pike (2)"
	if use doc ; then
		make INSTALLARGS="--traditional" buildroot="${D}" install || die
		einfo "Installing 60MB of docs, this could take some time ..."
		dodoc -r "${S}"/refdoc/traditional_manual "${S}"/refdoc/modref
	else
		make INSTALLARGS="--traditional" buildroot="${D}" install_nodoc || die
	fi
	# Installation is a bit broken.. remove the doc sources.
	rm -rf "${D}/usr/doc"
	# Install the man pages in the proper location.
	rm -rf "${D}/usr/man" && doman "${S}/man/pike.1"
}
