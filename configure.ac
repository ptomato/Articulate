# configure.ac

AC_INIT([Articulate], [0.1])
AC_CONFIG_SRCDIR([src/main.vala])
AC_CONFIG_HEADERS([config.h])

AM_INIT_AUTOMAKE([foreign])
AM_SILENT_RULES([yes])

AC_PROG_CC
AC_PROG_CC_STDC
AM_PROG_VALAC([0.17.2])
AC_PROG_INSTALL
IT_PROG_INTLTOOL([0.35])

ARTICULATE_PACKAGES="--pkg gtk+-3.0 --pkg gio-2.0 --pkg gmodule-2.0 --pkg gtksourceview-3.0 --pkg gnome-keyring-1-mod --pkg libgdata --pkg libxslt --pkg gee-0.8 --pkg libcurl --pkg posix"
PKG_CHECK_MODULES(ARTICULATE, [
	gtk+-3.0
	gio-2.0
	gmodule-2.0
	gtksourceview-3.0
	gee-0.8
	gnome-keyring-1 >= 2.22 dnl Not in ARTICULATE_PACKAGES, as we provide our own non-buggy VAPI
	libgdata  dnl also not in PACKAGES
	libxslt libexslt  dnl doesn't even have a VAPI, we provide our own
])
AC_SUBST(ARTICULATE_CFLAGS)
AC_SUBST(ARTICULATE_LIBS)
AC_SUBST(ARTICULATE_PACKAGES)
PKG_CHECK_MODULES(CURL, [libcurl], [], dnl we provide our own VAPI
[
	# Try this if libcurl.pc wasn't found
	LIBCURL_CHECK_CONFIG
	CURL_CFLAGS=$(LIBCURL_CPPFLAGS)
	CURL_LIBS=$(LIBCURL)
])
AC_SUBST([CURL_CFLAGS])
AC_SUBST([CURL_LIBS])

GETTEXT_PACKAGE=articulate
AC_DEFINE_UNQUOTED([GETTEXT_PACKAGE], ["$GETTEXT_PACKAGE"], [Gettext Package])
AC_SUBST(GETTEXT_PACKAGE)
AM_GNU_GETTEXT([external])
AM_GNU_GETTEXT_VERSION([0.17])

AC_CONFIG_FILES([
	Makefile
	data/articulate.desktop.in
	data/Makefile
	data/icons/Makefile
	po/Makefile.in
	src/Makefile
	vapi/Makefile
])
AC_OUTPUT
