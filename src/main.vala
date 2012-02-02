int
main(string[] args)
{
	Intl.bindtextdomain(Config.GETTEXT_PACKAGE, Config.LOCALEDIR);
	Intl.bind_textdomain_codeset(Config.GETTEXT_PACKAGE, "UTF-8");
	Intl.textdomain(Config.GETTEXT_PACKAGE);

	Curl.global_init(Curl.GLOBAL_ALL);
	
	var gk_available = GnomeKeyring.is_available();
	if(!gk_available)
		warning("Gnome Keyring not available");

	Gtk.init(ref args);

	var mainwin = new MainWin();
	mainwin.show_all();
	Gtk.main();

	Curl.global_cleanup();

	return 0;
}

