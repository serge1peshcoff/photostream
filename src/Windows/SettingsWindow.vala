using Gtk;

public class PhotoStream.SettingsWindow : Gtk.Window
{
	public Granite.Widgets.ThinPaned pane;
	public Granite.Widgets.SourceList sourceList;
	public Granite.Widgets.SourceList.Item editProfileItem;
	public Granite.Widgets.SourceList.Item changePasswordItem;
	public Granite.Widgets.SourceList.Item manageAppsItem;
	public Granite.Widgets.SourceList.Item logOutItem;

	public Gtk.Stack settingsStack;

	public SettingsWindow () 
	{
		this.set_title("Settings");

		this.set_default_size (800, 700);
        this.set_size_request (800, 700);
		this.resizable = false;	

		this.settingsStack = new Gtk.Stack();

		this.editProfileItem = new Granite.Widgets.SourceList.Item("Profile Settings");
		this.changePasswordItem = new Granite.Widgets.SourceList.Item("Change password");
		this.manageAppsItem = new Granite.Widgets.SourceList.Item("Manage applications");
		this.logOutItem = new Granite.Widgets.SourceList.Item("Log out");

		logOutItem.activated.connect(() => {
			logOutConfirm();
		});

		pane = new Granite.Widgets.ThinPaned();
		sourceList = new Granite.Widgets.SourceList();
		var root = sourceList.root;
		root.add(editProfileItem);
		root.add(changePasswordItem);
		root.add(manageAppsItem);
		root.add(logOutItem);
		sourceList.set_size_request(150, -1);

		pane.pack1 (sourceList, false, false);
		pane.pack2 (settingsStack, true, false);
		this.add(pane);	
	}

	public void logOutConfirm()
	{
		Gtk.MessageDialog msg = new Gtk.MessageDialog (null, Gtk.DialogFlags.MODAL, 
													Gtk.MessageType.QUESTION, Gtk.ButtonsType.OK_CANCEL, 
													"Are you sure you want to log out?");
		msg.response.connect ((response_id) => {
			bool allowedToUnfollow = (response_id == Gtk.ResponseType.OK);

			msg.destroy();

			if (!allowedToUnfollow)
				return;
			else
				new Thread<int>("", () => {
	        		logOut();
	        		return 0;
	        	});				
		});
		msg.show ();
	}

	public void logOut()
	{
		setToken("");
		File file = File.new_for_path(PhotoStream.App.CACHE_URL + "cookie.txt"); 
		try
		{
			file.delete();
		}
		catch (Error e)
		{
			error("Something wrong with file removing: %s", e.message);
		}
		this.destroy();
	}
}