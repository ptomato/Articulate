using Gtk;
using GData;

public class MainWin : Window
{
	// Saved widget pointers
	private TextBuffer content;
	private TreeStore documents;
	private Statusbar statusbar;
	private ProgressBar progressbar;
	// Dialogs
	private PasswordDialog password_dialog;
	// Internet stuff
	private DocumentsService google;

	// SIGNAL HANDLERS

	[CCode (instance_pos = -1)]
	public void on_docs_view_row_activated(TreeView source, TreePath path, TreeViewColumn column) { }

	[CCode (instance_pos = -1)]
	public void on_authenticate(Gtk.Action action) {
		string username;
		void *password = null;
		bool cancel = false;

		// See if a password is stored in the keyring
		GnomeKeyring.find_password(GnomeKeyring.NETWORK_PASSWORD,
			(res, pass) => {
				switch(res) {
					case GnomeKeyring.Result.OK:
						password = GnomeKeyring.memory_strdup(pass);
						return;
					case GnomeKeyring.Result.DENIED:
					case GnomeKeyring.Result.CANCELLED:
						cancel = true;
						return;
					case GnomeKeyring.Result.NO_MATCH:
						return;
					default:
						warning(@"Problem finding password in Gnome Keyring: $res");
						return;
				}
			},
			"user", "philip.chimento@gmail.com",
			"server", "docs.google.com",
			"protocol", "gdata",
			"domain", "googledocs2latex",
			null);
		if(cancel)
			return;

		var response = password_dialog.authenticate();
		if(response != ResponseType.OK)
			return;
		
		username = password_dialog.username;
		password = GnomeKeyring.memory_strdup(password_dialog.password);
		password_dialog.password = "";
		
		// Start the Google Docs service and send a request
		google = new DocumentsService("BetaChi-TestProgram-0.1");
		try {
			google.authenticate(username, (string)password, null);

			// If it worked, save the password in the keyring
			GnomeKeyring.store_password(GnomeKeyring.NETWORK_PASSWORD,
				GnomeKeyring.DEFAULT,
				"Google Account password for GoogleDocs2LaTeX",
				(string)password,
				(res) => { },
				"user", username,
				"server", "docs.google.com",
				"protocol", "gdata",
				"domain", "googledocs2latex",
				null);
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
			return;
		} finally {
			GnomeKeyring.memory_free(password);
			password = null;
		}

		var query = new DocumentsQuery("");
		query.show_folders = true;
		statusbar.push(0, "Getting documents feed");
		google.query_documents_async.begin(query, null, (doc, count, total) => {
			// Progress callback
			if(total > 0) {
				progressbar.fraction = (float)count / total;
			} else {
				progressbar.pulse();
			}
			if(doc is DocumentsFolder) {
				TreeIter iter;
				documents.append(out iter, null);
				documents.set(iter,
					0, doc.title,
					1, doc.id,
					2, "folder",
					-1);
			} else if(doc is DocumentsText) {
				TreeIter iter;
				documents.append(out iter, null);
				documents.set(iter,
					0, doc.title,
					1, (doc as DocumentsText).document_id,
					2, "x-office-document",
					-1);
			}
		}, (obj, res) => {
			// Async operation finished callback
			// We don't need the results, so don't call google.query_async.finish(res)
			statusbar.pop(0);
			progressbar.fraction = 0.0;
		});
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
			documents = builder.get_object("docs_model") as TreeStore;
			statusbar = builder.get_object("statusbar") as Statusbar;
			progressbar = builder.get_object("progressbar") as ProgressBar;
			
			password_dialog = new PasswordDialog(builder, this);
		} catch(Error e) {
			error("Could not load UI: %s\n", e.message);
		}

		set_title(_("Google Docs 2 LaTeX"));
		set_default_size(800, 600);
		this.destroy.connect(main_quit);
	}
}
