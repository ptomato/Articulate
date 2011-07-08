using Gtk;

public class PasswordDialog
{
	private Dialog password_dialog;
	private Entry username_entry;
	private Entry password_entry;
	
	public string username { 
		get { return username_entry.get_text(); }
		set {
			username_entry.set_text(value);
			password_entry.grab_focus();
		}
	}
	public string password {
		get { return password_entry.get_text(); }
		set { password_entry.set_text(value); }
	}
	
	// Constructor requires a GtkBuilder and a main window
	public PasswordDialog(Builder builder, Window window) {
		password_dialog = builder.get_object("password_dialog") as Dialog;
		username_entry = builder.get_object("username_entry") as Entry;
		password_entry = builder.get_object("password_entry") as Entry;
		password_dialog.set_transient_for(window);
	}
	
	public int authenticate() {
		var retval = password_dialog.run();
		password_dialog.hide();
		
		return retval;
	}
}
