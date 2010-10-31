# configure.ac

AC_INIT([GoogleDocs2LaTeX], [0.1])
AC_CONFIG_SRCDIR([src/main.vala])
AC_CONFIG_HEADERS([config.h])

AM_INIT_AUTOMAKE([foreign])
AM_SILENT_RULES([yes])

AC_PROG_CC
AC_PROG_CC_STDC
AM_PROG_VALAC([0.7.0])
AC_PROG_INSTALL
AC_PROG_INTLTOOL([0.35])

GOOGLEDOCS2LATEX_PACKAGES="--pkg gtk+-2.0 --pkg gmodule-2.0 --pkg libsoup-2.4"
PKG_CHECK_MODULES(GOOGLEDOCS2LATEX, [
	gtk+-2.0 >= 2.14.0
	gmodule-2.0
	libsoup-2.4
])
AC_SUBST(GOOGLEDOCS2LATEX_CFLAGS)
AC_SUBST(GOOGLEDOCS2LATEX_LIBS)
AC_SUBST(GOOGLEDOCS2LATEX_PACKAGES)

GETTEXT_PACKAGE=googledocs2latex
AC_DEFINE_UNQUOTED([GETTEXT_PACKAGE], ["$GETTEXT_PACKAGE"], [Gettext Package])
AC_SUBST(GETTEXT_PACKAGE)
AM_GNU_GETTEXT([external])
AM_GNU_GETTEXT_VERSION([0.17])


AC_CONFIG_FILES([
	Makefile
	data/googledocs2latex.desktop.in
	data/Makefile
	data/icons/Makefile
	data/icons/16x16/Makefile
	data/icons/22x22/Makefile
	data/icons/24x24/Makefile
	data/icons/32x32/Makefile
	data/icons/48x48/Makefile
	data/icons/scalable/Makefile
	po/Makefile.in
	src/Makefile
	vapi/Makefile
])
AC_OUTPUT
