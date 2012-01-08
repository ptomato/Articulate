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
	private DocumentsService google;
	private OAuth1Authorizer authorizer;
	private string? access_token;
	// Settings file
	private KeyFile settings_file;
	private string settings_filename;

	// SIGNAL HANDLERS

	[CCode (instance_pos = -1)]
	public void on_docs_view_row_activated(TreeView source, TreePath path, TreeViewColumn column) {
		code_view.clear_code();

		TreeIter iter;
		source.model.get_iter(out iter, path);
		DocumentsText document;
		source.model.get(iter, 3, out document, -1);
		var uri = document.get_download_uri(DocumentsTextFormat.HTML);
		var stream = new DataInputStream(new DownloadStream(google, null, uri, null));
		string line;

		var builder = new StringBuilder();
		try {
			while((line = stream.read_line(null)) != null)
				builder.append(line);
		} catch {
			print("There was an error\n");
		}
		code_view.html_code = builder.str;
	}

	[CCode (instance_pos = -1)]
	public void on_authenticate(Gtk.Action action) {
		// Start the Google Docs service and send a request
		authorizer = new OAuth1Authorizer("BetaChi-TestProgram-0.1", typeof(DocumentsService));
		google = new DocumentsService(authorizer);

		// Step 1 of OAuth1 protocol - request a token, token secret, and URI
		// where the user can grant access to the application
		statusbar.push(0, "Requesting authentication URI");
		authorizer.request_authentication_uri_async.begin(null, (obj, res) => {
			string uri, token, token_secret;
			statusbar.pop(0);
			try {
				uri = authorizer.request_authentication_uri_async.end(res, out token, out token_secret);
			} catch(Error e) {
				error_dialog("There was a problem requesting authorization to your account.",
					@"Google returned the response: <b>\"$(e.message)\"</b>");
				return;
			}

			// Display the URI in the user's browser
			try {
				show_uri(null, uri, get_current_event_time());
			} catch(Error e) {
				var clipboard = Clipboard.get(Gdk.SELECTION_CLIPBOARD);
				clipboard.set_text(uri, -1);
				error_dialog("Automatically displaying the authentication page didn't work.",
					@"The error was: <b>\"$(e.message)\"</b>.\n\nThe link <a href='$uri'>$uri</a> has been copied to your clipboard. Please paste it into your browser.");
			}

			// Ask the user to enter the verification access token
			var response = password_dialog.authenticate();
			if(response != ResponseType.OK)
				return;
			access_token = password_dialog.access_token;

			// Send the access token and request authorization
			statusbar.push(0, "Requesting authorization");
			authorizer.request_authorization_async.begin(token, token_secret, access_token, null, (obj, res) => {
				statusbar.pop(0);
				try {
					if(!authorizer.request_authorization_async.end(res))
						throw new Error(Quark.from_string("GoogleDocs2LaTeX"), 0, "Request denied");
				} catch(Error e) {
					error_dialog("There was a problem requesting authorization to your account.",
						@"Google returned the response: <b>\"$(e.message)\"</b>");
					return;
				}

				// The verification token worked, save it
				settings_file.set_string("general", "access_token", access_token);

				// Now that we are authorized, load the documents
				refresh_document_list();
			});

			// Zero out the secret before freeing
			Posix.memset((void *)token_secret, 0, token_secret.length);
		});
	}

	public void on_quit() {
		try {
			FileUtils.set_contents(settings_filename, settings_file.to_data());
		} catch(Error e) {
			warning("Could not save settings file: %s", e.message);
		}
		main_quit();
	}

	// CONSTRUCTOR

	public MainWin() {
		settings_file = new KeyFile();
		settings_filename = Path.build_filename(Environment.get_home_dir(),  ".googledocs2latex");

		try {
			settings_file.load_from_file(settings_filename, KeyFileFlags.NONE);
			access_token = settings_file.get_string("general", "access_token");
		} catch {
			access_token = null;
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
