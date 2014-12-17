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
}