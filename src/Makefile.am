bin_PROGRAMS = articulate articulate-gui
noinst_LTLIBRARIES = libtransforms.la

articulate_gui_SOURCES = \
	main.vala \
	mainwin.vala \
	passworddialog.vala \
	optionsdialog.vala \
	googledocs.vala \
	codeview.vala \
	$(NULL)
articulate_gui_CPPFLAGS = \
	-include config.h \
	$(ARTICULATE_GUI_CFLAGS) \
	$(CURL_CFLAGS) \
	-DLOCALEDIR=\""$(localedir)"\" \
	-DPKGDATADIR=\""$(pkgdatadir)"\" \
	-DPKGLIBDIR=\""$(pkglibdir)"\" \
	$(NULL)
articulate_gui_VALAFLAGS = \
	--vapidir=$(srcdir)/../vapi \
	--vapidir=$(builddir) \
	--pkg config \
	--pkg Transforms \
	@ARTICULATE_GUI_PACKAGES@ \
	$(NULL)
articulate_gui_LDADD = \
	libtransforms.la \
	$(ARTICULATE_GUI_LIBS) \
	$(CURL_LIBS) \
	$(NULL)

articulate_SOURCES = articulate.vala
articulate_CPPFLAGS = \
	-include config.h \
	$(ARTICULATE_CFLAGS) \
	-DLOCALEDIR=\""$(localedir)"\" \
	-DPKGDATADIR=\""$(pkgdatadir)"\" \
	-DPKGLIBDIR=\""$(pkglibdir)"\" \
	$(NULL)
articulate_VALAFLAGS = \
	--vapidir=$(srcdir)/../vapi \
	--vapidir=$(builddir) \
	--pkg config \
	--pkg Transforms \
	@ARTICULATE_PACKAGES@ \
	$(NULL)
articulate_LDADD = \
	libtransforms.la \
	$(ARTICULATE_LIBS) \
	$(NULL)

libtransforms_la_SOURCES = \
	semantictransform.vala \
	latextransform.vala \
	utf8transform.vala \
	$(NULL)
libtransforms_la_CPPFLAGS = \
	$(TRANSFORMS_CFLAGS) \
	$(NULL)
libtransforms_la_VALAFLAGS = \
	--vapidir=$(srcdir)/../vapi \
	--library Transforms \
	-H transforms.h \
	@TRANSFORMS_PACKAGES@ \
	$(NULL)
libtransforms_la_LIBADD = \
	$(TRANSFORMS_LIBS) \
	$(NULL)

# Disable warnings in the C compiler, since the Vala-generated C produces lots
AM_CFLAGS = -w

EXTRA_DIST = mainwin.ui
	
CLEANFILES = \
	main.c \
	manwin.c \
	$(NULL)
