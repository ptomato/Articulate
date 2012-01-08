using Gtk;

public class PasswordDialog
{
	private Dialog password_dialog;
	private Entry access_token_entry;
	
	public string access_token { get { return access_token_entry.get_text(); } }
	
	// Constructor requires a GtkBuilder and a main window
	public PasswordDialog(Builder builder, Window window) {
		password_dialog = builder.get_object("password_dialog") as Dialog;
		access_token_entry = builder.get_object("access_token_entry") as Entry;
		password_dialog.set_transient_for(window);
	}
	
	public int authenticate() {
		var retval = password_dialog.run();
		password_dialog.hide();
		
		return retval;
	}
}
