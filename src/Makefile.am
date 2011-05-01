bin_PROGRAMS = googledocs2latex

googledocs2latex_SOURCES = \
	main.vala \
	mainwin.vala \
	passworddialog.vala

INCLUDES = \
	-include config.h \
	$(GOOGLEDOCS2LATEX_CFLAGS) \
	-DLOCALEDIR=\""$(localedir)"\" \
	-DPKGDATADIR=\""$(pkgdatadir)"\" \
	-DPKGLIBDIR=\""$(pkglibdir)"\"

VALAFLAGS = \
	--vapidir=$(srcdir)/../vapi --pkg config \
	@GOOGLEDOCS2LATEX_PACKAGES@

googledocs2latex_LDADD = \
	$(GOOGLEDOCS2LATEX_LIBS)

EXTRA_DIST = mainwin.ui
	
CLEANFILES = \
	main.c \
	manwin.c
