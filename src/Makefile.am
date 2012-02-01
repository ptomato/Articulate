bin_PROGRAMS = googledocs2latex

googledocs2latex_SOURCES = \
	main.vala \
	mainwin.vala \
	passworddialog.vala \
	optionsdialog.vala \
	googledocs.vala \
	codeview.vala \
	semantictransform.vala \
	latextransform.vala \
	utf8transform.vala

INCLUDES = \
	-include config.h \
	$(GOOGLEDOCS2LATEX_CFLAGS) \
	$(LIBCURL_CPPFLAGS) \
	-DLOCALEDIR=\""$(localedir)"\" \
	-DPKGDATADIR=\""$(pkgdatadir)"\" \
	-DPKGLIBDIR=\""$(pkglibdir)"\"

# Disable warnings in the C compiler, since the Vala-generated C produces lots
AM_CFLAGS = -w

AM_VALAFLAGS = \
	--vapidir=$(srcdir)/../vapi --pkg config \
	@GOOGLEDOCS2LATEX_PACKAGES@

googledocs2latex_LDADD = \
	$(GOOGLEDOCS2LATEX_LIBS) \
	$(LIBCURL)

EXTRA_DIST = mainwin.ui
	
CLEANFILES = \
	main.c \
	manwin.c
