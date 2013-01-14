using GData;

// Class that takes care of storing passwords and logging into Google Docs
public class GoogleDocs : DocumentsService {

	public string? username { get; set; default = null; }
	
	private void* _password;
	public string? password {
		set {
			if(_password != null)
				GnomeKeyring.memory_free(_password);
			if(value != null)
				_password = GnomeKeyring.memory_strdup(value);
			else
				_password = null;
		}
	}

	public bool can_login() {
		return username != null && _password != null;
	}

	public void login()
		throws Error
		requires(can_login())
	{
		var login_authorizer = new ClientLoginAuthorizer("BetaChi-TestProgram-0.1", typeof(DocumentsService));
		login_authorizer.authenticate(username, (string)_password, null);

		this.authorizer = login_authorizer;
	}

	public string load_document_contents(DocumentsText document)
		throws Error
	{
		var builder = new StringBuilder();
		var stream = document.download(this, DocumentsTextFormat.HTML, null);
		var datastream = new DataInputStream(stream);
		string line;
		while((line = datastream.read_line(null)) != null)
			builder.append(line);
		datastream.close();
		stream.close();
		return builder.str;
	}

	public void find_password_in_keyring()
		throws IOError
	{
		string _temp_password;
		password = null;
		
		// See if a password is stored in the keyring
		var res = GnomeKeyring.find_password_sync(GnomeKeyring.NETWORK_PASSWORD, 
			out _temp_password,
			"user", username,
			"server", "docs.google.com",
			"protocol", "gdata",
			"domain", "articulate",
			null);
		switch(res) {
			case GnomeKeyring.Result.OK:
				password = _temp_password;
				GnomeKeyring.free_password(_temp_password);
				break;
			case GnomeKeyring.Result.NO_MATCH:
				break;
			case GnomeKeyring.Result.DENIED:
			case GnomeKeyring.Result.CANCELLED:
				// If the operation was cancelled, throw an exception
				throw new IOError.CANCELLED("User cancelled");
			default:
				var msg = GnomeKeyring.result_to_message(res);
				warning(@"Problem finding password in Gnome Keyring: $msg");
				break;
		}
	}

	public void save_password_in_keyring() {
		var res = GnomeKeyring.store_password_sync(GnomeKeyring.NETWORK_PASSWORD,
			GnomeKeyring.DEFAULT,
			"Google Account password for Articulate",
			(string)_password,
			"user", username,
			"server", "docs.google.com",
			"protocol", "gdata",
			"domain", "articulate",
			null);
		if(res != GnomeKeyring.Result.OK) {
			var msg = GnomeKeyring.result_to_message(res);
			warning(@"Problem saving password in Gnome Keyring: $msg");
		}
	}

	public GoogleDocs() {
		_password = null;
	}

	~GoogleDocs() {
		if(_password != null)
			GnomeKeyring.memory_free(_password);
	}
}
	
