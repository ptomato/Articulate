using Gtk;

public class MainWin : Window
{
	// Saved widget pointers
	private TextBuffer content;
	private ListStore documents;
	private Statusbar statusbar;

	// SIGNAL HANDLERS

	[CCode (instance_pos = -1)]
	public void on_docs_view_row_activated(TreeView source, TreePath path, TreeViewColumn column) { }

	[CCode (instance_pos = -1)]
	public void on_authenticate(Gtk.Action action) {
		Rest.Proxy oauth = new OAuthProxy("anonymous", "4572616e48616d6d65724c61686176", "https://www.google.com/accounts/OAuthGetRequestToken", false);

		try {
			OAuthProxy.request_token((OAuthProxy)oauth, "", "oob");
		} catch(Error e) {
			error("Something went wrong: %s", e.message);
		}

	}

	// CONSTRUCTOR

	public MainWin() {
		try {
			var builder = new Builder();
			builder.add_from_file("mainwin.ui");
			builder.connect_signals(this);
			add(builder.get_object("frame") as Widget);

			// Save widget pointers
			content = builder.get_object("text_model") as TextBuffer;
			documents = builder.get_object("docs_model") as ListStore;
			statusbar = builder.get_object("statusbar") as Statusbar;
		} catch(Error e) {
			error("Could not load UI: %s\n", e.message);
		}

		set_title(_("Google Docs 2 LaTeX"));
		set_default_size(800, 600);
		this.destroy.connect(main_quit);
	}

}
