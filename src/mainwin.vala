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
		var oauth = new Rest.OAuthProxy("anonymous", "anonymous", "https://www.google.com/accounts/", false);

		// Request token
		var call = oauth.new_call() as Rest.OAuthProxyCall;
		call.set_function("OAuthGetRequestToken");
		call.add_params(
			"scope", "https://docs.google.com/feeds/default/private/full",
			"oauth_callback", "oob",
			"xoauth_displayname", "GoogleDocs2LaTeX");
		try {
			call.run(null);
		} catch(Error e) {
			error("Something went wrong: %s", e.message);
		}
		call.parse_token_response();

		// Authorize token
		var escaped_token = Uri.escape_string(oauth.get_token(), "", false);
		var authorize_uri = @"https://www.google.com/accounts/OAuthAuthorizeToken?oauth_token=$escaped_token&hd=default";
		try {
			show_uri(null, authorize_uri, Gdk.CURRENT_TIME);
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
