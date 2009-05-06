# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header$

DESCRIPTION="Xenofarm compilation client"
HOMEPAGE="http://www.lysator.liu.se/xenofarm/"
#SRC_URI="http://www.lysator.liu.se/xenofarm/client.tar.gz"
SRC_URI="http://pike.ida.liu.se/projects/pikefarm/clientdists/xenoclient-${PV}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~hppa ~ia64 ~mips ~ppc ~sparc ~x86 ~x86-fbsd"
IUSE=""

DEPEND="net-misc/wget"
RDEPEND=""

src_compile() {
  cd xenoclient && make
}

src_install() {
  mkdir -p "$D/etc/xenofarm"
  (cd xenoclient/config && tar cf - .) | \
    (cd "$D/etc/xenoclient" && tar xf -) || die
  rm -rf xenoclient/config || die
  mkdir -p "$D/usr"
  tar cf - xenoclient | (cd "$D/usr" && tar xf -) || die
  ln -s /etc/xenoclient "$D/usr/xenoclient/config" || die  

  if [ -f /etc/xenoclient/contact.txt ]; then :; else
    elog "Please run /usr/xenoclient/client.sh once interactively"
    elog "to set the contact information."
  fi
}
