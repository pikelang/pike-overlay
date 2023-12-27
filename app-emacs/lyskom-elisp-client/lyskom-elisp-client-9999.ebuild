# Based on https://www.lysator.liu.se/~blambi/lyskom-elisp-client-9999.ebuild
# as of 2023-12-27.
EAPI=7

# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-emacs/lyskom-elisp-client/lyskom-elisp-client-0.48.ebuild,v 1.6 2007/07/03 09:45:44 opfer Exp $

inherit elisp git-r3

S="${WORKDIR}/${PN}"

DESCRIPTION="Elisp client for the LysKOM conference system"
HOMEPAGE="http://www.lysator.liu.se/lyskom/klienter/emacslisp/index.en.html"
#SRC_URI="http://www.lysator.liu.se/lyskom/klienter/emacslisp/${MY_P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~arm64 ~sparc ~x86"
IUSE=""

EGIT_REPO_URI="https://git.lysator.liu.se/lyskom-elisp-client/lyskom-elisp-client"

SITEFILE=50lyskom-elisp-client-gentoo.el
DOCS="doc/NEWS-* src/README"

src_compile() {
    cd src
    emake EMACS="emacs"
}

src_install() {
    elisp-install ${PN} src/lyskom.el src/lyskom.elc || \
        die "elisp-install failed"
    elisp-site-file-install "${FILESDIR}/${SITEFILE}" \
	|| die "elisp-site-file-install failed"
    if [ -n "${DOCS}" ]; then
	dodoc ${DOCS} || die "dodoc failed"
    fi
}

pkg_postinst() {
    elisp-site-regen
    ewarn
    ewarn "If you prefer Swedish language environment, add"
    ewarn "\t(setq-default kom-default-language 'sv)"
    ewarn "to your emacs configuration file."
    ewarn
}
