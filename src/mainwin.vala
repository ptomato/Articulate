using Gtk;
using GData;


public class MainWin : Window
{
	// Saved widget pointers
	private TreeView documents_view;
	private TreeStore documents;
	private Statusbar statusbar;
	private ProgressBar progressbar;
	private CodeView code_view;
	// Dialogs
	private PasswordDialog password_dialog;
	// Internet stuff
	private GoogleDocs google;
	// Settings file
	private KeyFile settings;
	private File settings_file;

	// SIGNAL HANDLERS

	[CCode (instance_pos = -1)]
	public void on_docs_view_row_activated(TreeView source, TreePath path, TreeViewColumn column) {
		code_view.clear_code();

		TreeIter iter;
		source.model.get_iter(out iter, path);
		DocumentsText document;
		source.model.get(iter, 3, out document, -1);
		try {
			code_view.html_code = google.load_document_contents(document);
		} catch(Error e) {
			warning("There was an error: $(e.message)\n");
		}
	}

	[CCode (instance_pos = -1)]
	public void on_authenticate(Gtk.Action action) {
		try {
			google.find_password_in_keyring();
		} catch(Error e) {
			if(e is IOError.CANCELLED)
				return;
			warning(@"Error searching for password in keyring: $(e.message)");
		}

		if(!google.can_login()) {
			password_dialog.username = google.username;
			var response = password_dialog.authenticate();
			if(response != ResponseType.OK)
				return;
		
			google.username = password_dialog.username;
			google.password = password_dialog.password;
			password_dialog.password = "";
		}

		try {
			google.login();
		} catch(Error e) {
			error_dialog("There was a problem logging in to your account.",
				@"Google returned the response: <b>\"$(e.message)\"</b>");
			return;
		}

		// If it worked, save the password in the keyring
		google.save_password_in_keyring();
		// And save the username
		settings.set_string("general", "username", google.username);

		// Now that we are authenticated, load the documents
		refresh_document_list();
	}

	public void on_quit() {
		try {
			var text = settings.to_data();
			settings_file.replace_contents(text, text.length, null, false, FileCreateFlags.NONE, null);
		} catch(Error e) {
			warning("Could not save settings file: %s", e.message);
		}
		main_quit();
	}

	// CONSTRUCTOR

	public MainWin() {
		google = new GoogleDocs();

		settings = new KeyFile();
		settings_file = File.new_for_path(Environment.get_home_dir()).get_child(".googledocs2latex");

		try {
			settings.load_from_file(settings_file.get_path(), KeyFileFlags.NONE);
			google.username = settings.get_string("general", "username");
		} catch {
			google.username = null;
		}

		try {
			var builder = new Builder();
			builder.add_from_file("mainwin.ui");
			builder.connect_signals(this);
			add(builder.get_object("frame") as Widget);

			// Save widget pointers
			statusbar = builder.get_object("statusbar") as Statusbar;
			documents_view = builder.get_object("docs_view") as TreeView;
			progressbar = builder.get_object("progressbar") as ProgressBar;
			var pane = builder.get_object("pane") as HPaned;
			code_view = new CodeView();
			pane.add2(code_view);

			password_dialog = new PasswordDialog(builder, this);
		} catch(Error e) {
			error("Could not load UI: %s\n", e.message);
		}
		documents = new TreeStore(4, typeof(string), typeof(string), typeof(string), typeof(DocumentsEntry));
		documents_view.set_model(documents);

		set_title(_("Google Docs 2 LaTeX"));
		set_default_size(800, 600);
		this.destroy.connect(on_quit);
	}

	public void refresh_document_list() {
		assert(google.is_authorized());
		var query = new DocumentsQuery("");
		query.show_folders = false;
		statusbar.push(0, "Getting documents feed");
		google.query_documents_async.begin(query, null, (doc, count, total) => {
			// Progress callback
			if(total > 0) {
				progressbar.fraction = (float)count / total;
			} else {
				progressbar.pulse();
			}
			if(doc is DocumentsText) {
				TreeIter iter;
				documents.append(out iter, null);
				documents.set(iter,
					0, doc.title,
					1, (doc as DocumentsText).document_id,
					2, "x-office-document",
					3, doc,
					-1);
			}
		}, (obj, res) => {
			// Async operation finished callback
			statusbar.pop(0);
			progressbar.fraction = 0.0;
			try {
				google.query_async.end(res);
			} catch(Error e) {
				var message = Markup.escape_text(e.message);
				error_dialog("There was a problem retrieving the list of documents.",
					@"Google returned the response: <b>\"$message\"</b>");
			}
		});
	}

	public void error_dialog(string primary, string secondary) {
		var error_dialog = new MessageDialog(this,
			DialogFlags.MODAL | DialogFlags.DESTROY_WITH_PARENT,
			MessageType.ERROR, ButtonsType.OK,
			"%s", primary);
		error_dialog.secondary_use_markup = true;
		error_dialog.secondary_text = secondary;
		error_dialog.title = "Google Docs 2 LaTeX";
		error_dialog.run();
		error_dialog.destroy();
	}
}
