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
	private OptionsDialog options_dialog;
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

	[CCode (instance_pos = -1)]
	public void on_options(Gtk.Action action) {
		options_dialog.run();
		options_dialog.hide();
	}

	[CCode (instance_pos = -1)]
	public void on_save(Gtk.Action action) {
		// Save the LaTeX code and accompanying graphics to a directory
		var dialog = new FileChooserDialog("Choose a directory to save to", this, FileChooserAction.SAVE, Stock.CANCEL, ResponseType.CANCEL, Stock.OK, ResponseType.OK);
		var filter = new FileFilter();
		filter.set_name("LaTeX files (*.tex)");
		filter.add_pattern("*.tex");
		dialog.add_filter(filter);
		dialog.do_overwrite_confirmation = true;
		var response = dialog.run();
		dialog.hide();
		if(response != ResponseType.OK)
			return;

		// Save LaTeX code
		var latexfile = dialog.get_file();
		try {
			latexfile.replace_contents(code_view.latex_code.data, null, false, FileCreateFlags.NONE, null);
		} catch(Error e) {
			error_dialog("There was an error saving the LaTeX file.", @"Error message: <b>\"$(e.message)\"</b>");
			return;
		}

		var parent = latexfile.get_parent();
		foreach(var entry in code_view.file_list.entries) {
			var destfile = parent.get_child(entry.key + ".png");
			if(destfile.query_exists()) {
				var pngdialog = new MessageDialog(this, DialogFlags.MODAL | DialogFlags.DESTROY_WITH_PARENT,
					MessageType.QUESTION, ButtonsType.NONE,
					"Are you sure you want to overwrite '%s'?", entry.key + ".png");
				pngdialog.add_buttons(Stock.CANCEL, ResponseType.CANCEL, "Overwrite", ResponseType.OK);
				pngdialog.secondary_text = "This will delete the previous file.";
				var pngresponse = pngdialog.run();
				pngdialog.hide();

				if(pngresponse != ResponseType.OK)
					continue;
			}

			try {
				var outputstream = destfile.replace(null, false, FileCreateFlags.NONE);
				var curlhandle = new Curl.EasyHandle();
				curlhandle.setopt(Curl.Option.URL, entry.value.get_uri());
				curlhandle.setopt(Curl.Option.WRITEDATA, outputstream);
				curlhandle.setopt(Curl.Option.WRITEFUNCTION, curl_callback);
				curlhandle.perform();
				outputstream.close();
			} catch (Error e) {
				error_dialog(@"There was an error downloading a graphics file.", @"Error message: <b>\"$(e.message)\"</b>");
			}
		}
	}

	public void on_quit() {
		try {
			var text = settings.to_data();
			settings_file.replace_contents(text.data, null, false, FileCreateFlags.NONE, null);
		} catch(Error e) {
			warning("Could not save settings file: %s", e.message);
		}
		main_quit();
	}

	// CONSTRUCTOR

	public MainWin() {
		google = new GoogleDocs();

		settings = new KeyFile();
		settings_file = File.new_for_path(Environment.get_home_dir()).get_child(".articulate");

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

		options_dialog = new OptionsDialog();
		options_dialog.bind_property("preamble-code", code_view, "preamble-code", 0);
		try {
			options_dialog.preamble_code = settings.get_string("options", "preamble");
		} catch {
			options_dialog.preamble_code = "";
		}
		options_dialog.hide.connect(() => {
			settings.set_string("options", "preamble", code_view.preamble_code);
		});

		options_dialog.transient_for = this;

		set_title(_("Articulate"));
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
		error_dialog.title = "Articulate";
		error_dialog.run();
		error_dialog.destroy();
	}
}

public size_t curl_callback(char* buffer, size_t size, size_t nitems, void *outputstream) {
	try {
		uint8[] bytes = new uint8[size * nitems];
		Posix.memcpy(bytes, buffer, size * nitems);
		return (outputstream as OutputStream).write(bytes);
	} catch(Error e) {
		return 0;
	}
}
