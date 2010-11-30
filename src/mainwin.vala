using Gtk;

public class MainWin : Window
{
	// Saved widget pointers
	private TextBuffer content;
	private ListStore documents;
	private Statusbar statusbar;
	// Dialogs
	private PasswordDialog password_dialog;
	// Internet stuff
	private string authkey = null;
	private Soup.Session session;

	// SIGNAL HANDLERS

	[CCode (instance_pos = -1)]
	public void on_docs_view_row_activated(TreeView source, TreePath path, TreeViewColumn column) { }

	[CCode (instance_pos = -1)]
	public void on_authenticate(Gtk.Action action) {
		var response = password_dialog.authenticate();
		if(response != ResponseType.OK)
			return;
		
		var username = password_dialog.username;
		var password = password_dialog.password;
		password_dialog.password = "";
		
		// Start the HTTP client and send a request
		session = new Soup.SessionSync();
		var message = Soup.form_request_new("POST", 
			"https://www.google.com/accounts/ClientLogin", 
			"accountType", "GOOGLE_OR_HOSTED",
			"Email", username,
			"Passwd", password,
			"service", "writely",
			"source", "BetaChi-TestProgram-0.1");
		var status = session.send_message(message);
	
		// Display the response status
		statusbar.push(0, "HTTP status: %u".printf(status));
		
		// Obtain the Auth token
		try {
			var regex = new Regex("^Auth=(.*)$", RegexCompileFlags.MULTILINE);
			MatchInfo match;
			if(!regex.match(message.response_body.flatten().data, 0, out match))
				throw new Error(0, 0, "Regex didn't match");
			authkey = match.fetch(1);
		} catch(Error e) {
			warning("Could not obtain Auth token: %s\n", e.message);
			return;
		}
			
		// Put the response in the text view
		content.set_text(authkey, -1);
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
			
			password_dialog = new PasswordDialog(builder, this);
			
		} catch(Error e) {
			error("Could not load UI: %s\n", e.message);
		}
			
		set_title(_("Google Docs 2 LaTeX"));
		set_default_size(800, 600);
		this.destroy.connect(main_quit);
	}

}
