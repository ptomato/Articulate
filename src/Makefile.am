bin_PROGRAMS = articulate

articulate_SOURCES = \
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
	$(ARTICULATE_CFLAGS) \
	$(CURL_CFLAGS) \
	-DLOCALEDIR=\""$(localedir)"\" \
	-DPKGDATADIR=\""$(pkgdatadir)"\" \
	-DPKGLIBDIR=\""$(pkglibdir)"\"

# Disable warnings in the C compiler, since the Vala-generated C produces lots
AM_CFLAGS = -w

AM_VALAFLAGS = \
	--vapidir=$(srcdir)/../vapi --pkg config \
	@ARTICULATE_PACKAGES@

articulate_LDADD = \
	$(ARTICULATE_LIBS) \
	$(CURL_LIBS)

EXTRA_DIST = mainwin.ui
	
CLEANFILES = \
	main.c \
	manwin.c
