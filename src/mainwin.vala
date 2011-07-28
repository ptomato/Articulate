using Gtk;
using GData;

enum Repr {
	RAW_HTML,
	SEMANTIC_XML,
	LATEX_UTF8_INSERTS,
	LATEX_UTF8,
	FINAL_LATEX;

	public string to_string() {
		switch(this) {
			case RAW_HTML:
				return "Raw HTML from Google Docs";
			case SEMANTIC_XML:
				return "Semantic XML";
			case LATEX_UTF8_INSERTS:
				return "LaTeX with UTF-8 and inserts";
			case LATEX_UTF8:
				return "LaTeX with UTF-8";
			case FINAL_LATEX:
				return "LaTeX code";
			default:
				assert_not_reached();
		}
	}

	public static Repr[] all() {
		return { RAW_HTML, SEMANTIC_XML, LATEX_UTF8_INSERTS, LATEX_UTF8, FINAL_LATEX };
	}
}

public class MainWin : Window
{
	// Saved widget pointers
	private TextBuffer content;
	private TreeView documents_view;
	private TreeStore documents;
	private Statusbar statusbar;
	private ProgressBar progressbar;
	private ComboBox stage_selector;
	// Dialogs
	private PasswordDialog password_dialog;
	// Internet stuff
	private DocumentsService google;
	// Settings file
	private KeyFile settings_file;
	private string settings_filename;
	private string username;
	// Intermediate representations
	private string code[5];

	// SIGNAL HANDLERS

	[CCode (instance_pos = -1)]
	public void on_docs_view_row_activated(TreeView source, TreePath path, TreeViewColumn column) {
		foreach(Repr repr in Repr.all())
			code[repr] = "";

		TreeIter iter;
		source.model.get_iter(out iter, path);
		DocumentsText document;
		source.model.get(iter, 3, out document, -1);
		var uri = document.get_download_uri(DocumentsTextFormat.HTML);
		var stream = new DataInputStream(new DownloadStream(google, uri, null));
		string line;

		var builder = new StringBuilder();
		try {
			while((line = stream.read_line(null)) != null)
				builder.append(line);
		} catch {
			print("There was an error\n");
		}
		code[Repr.RAW_HTML] = builder.str;
		content.text = code[Repr.RAW_HTML];
	}

	[CCode (instance_pos = -1)]
	public void on_authenticate(Gtk.Action action) {
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
			"user", username,
			"server", "docs.google.com",
			"protocol", "gdata",
			"domain", "googledocs2latex",
			null);
		if(cancel)
			return;

		if(username != null)
			password_dialog.username = username;
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
			// And save the username
			settings_file.set_string("general", "username", username);
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

		// Now that we are authenticated, load the documents
		refresh_document_list();
	}

	public void on_quit() {
		try {
			FileUtils.set_contents(settings_filename, settings_file.to_data());
		} catch(Error e) {
			warning("Could not save settings file: %s", e.message);
		}
		main_quit();
	}

	[CCode (instance_pos = -1)]
	public void on_stage_selector_changed(ComboBox source) {
		content.text = code[source.active];
	}

	// CONSTRUCTOR

	public MainWin() {
		settings_file = new KeyFile();
		settings_filename = Path.build_filename(Environment.get_home_dir(),  ".googledocs2latex");

		try {
			settings_file.load_from_file(settings_filename, KeyFileFlags.NONE);
			username = settings_file.get_string("general", "username");
		} catch {
			username = null;
		}

		try {
			var builder = new Builder();
			builder.add_from_file("mainwin.ui");
			builder.connect_signals(this);
			add(builder.get_object("frame") as Widget);

			// Save widget pointers
			content = builder.get_object("text_model") as TextBuffer;
			statusbar = builder.get_object("statusbar") as Statusbar;
			documents_view = builder.get_object("docs_view") as TreeView;
			progressbar = builder.get_object("progressbar") as ProgressBar;
			stage_selector = builder.get_object("stage_selector") as ComboBox;

			password_dialog = new PasswordDialog(builder, this);
		} catch(Error e) {
			error("Could not load UI: %s\n", e.message);
		}
		documents = new TreeStore(4, typeof(string), typeof(string), typeof(string), typeof(DocumentsEntry));
		documents_view.set_model(documents);

		// Construct the combo box values from the enum
		foreach(Repr repr in Repr.all())
			stage_selector.append_text(repr.to_string());
		stage_selector.active = Repr.RAW_HTML;

		set_title(_("Google Docs 2 LaTeX"));
		set_default_size(800, 600);
		this.destroy.connect(on_quit);
	}

	public void refresh_document_list() {
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
					3, doc,
					-1);
			} else if(doc is DocumentsText) {
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
			// We don't need the results, so don't call google.query_async.finish(res)
			statusbar.pop(0);
			progressbar.fraction = 0.0;
		});
	}
}
