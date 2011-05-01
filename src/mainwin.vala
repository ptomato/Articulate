using Gtk;
using GData;

public class MainWin : Window
{
	// Saved widget pointers
	private TextBuffer content;
	private ListStore documents;
	private Statusbar statusbar;
	// Dialogs
	private PasswordDialog password_dialog;

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
		
		// Start the Google Docs service and send a request
		var service = new DocumentsService("BetaChi-TestProgram-0.1");
		try {
			service.authenticate(username, password, null);
			var query = new DocumentsQuery("");
			var feed = service.query_documents(query, null, null);
			foreach(var doc in feed.get_entries()) {
				TextIter end;
				content.get_end_iter(out end);
				content.insert(end, doc.title + "\n", -1);
			}
		} catch(Error e) {
			var error_dialog = new MessageDialog(this,
				DialogFlags.MODAL | DialogFlags.DESTROY_WITH_PARENT,
				MessageType.ERROR, ButtonsType.OK,
				"There was a problem logging in to your account.");
			error_dialog.format_secondary_markup("Google returned the response:"
				+ " <b>\"%s\"</b>", e.message);
			error_dialog.title = "Google Docs 2 LaTeX";
			error_dialog.run();
			error_dialog.destroy();
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
			
			password_dialog = new PasswordDialog(builder, this);
			
		} catch(Error e) {
			error("Could not load UI: %s\n", e.message);
		}
			
		set_title(_("Google Docs 2 LaTeX"));
		set_default_size(800, 600);
		this.destroy.connect(main_quit);
	}

}
