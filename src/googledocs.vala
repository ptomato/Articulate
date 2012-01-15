using GData;

// Class that takes care of storing passwords and logging into Google Docs
public class GoogleDocs : DocumentsService {

	public string? username { get; set; default = null; }
	
	private unowned string? _password;
	public unowned string? password { 
		set {
			if(_password != null)
				GnomeKeyring.memory_free((void *)_password);
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
		login_authorizer.authenticate(username, _password, null);

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
		bool cancel = false;
		password = null;
		
		// See if a password is stored in the keyring
		GnomeKeyring.find_password(GnomeKeyring.NETWORK_PASSWORD,
			(res, pass) => {
				switch(res) {
					case GnomeKeyring.Result.OK:
						password = pass;
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

		// If the operation was cancelled, throw an exception
		if(cancel)
			throw new IOError.CANCELLED("User cancelled");
	}

	public void save_password_in_keyring() {
		GnomeKeyring.store_password(GnomeKeyring.NETWORK_PASSWORD,
			GnomeKeyring.DEFAULT,
			"Google Account password for GoogleDocs2LaTeX",
			_password,
			(res) => { },
			"user", username,
			"server", "docs.google.com",
			"protocol", "gdata",
			"domain", "googledocs2latex",
			null);
	}

	public GoogleDocs() {
		_password = null;
	}

	~GoogleDocs() {
		if(_password != null)
			GnomeKeyring.memory_free((void *)_password);
	}
}
	
