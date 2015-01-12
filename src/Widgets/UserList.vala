using PhotoStream.Utils;

public class PhotoStream.Widgets.UserList : Gtk.Box
{
	public GLib.List<UserBox> boxes;
	public Gtk.Button moreButton;
	public string olderUsersLink;

	public Gtk.ScrolledWindow userListWindow;
	public Gtk.ListBox userList;

	public UserList()
	{
		boxes = new GLib.List<UserBox>();
		this.moreButton = new Gtk.Button.with_label("Load more...");

		this.userListWindow = new Gtk.ScrolledWindow(null, null);
		this.userListWindow.set_policy(Gtk.PolicyType.NEVER, Gtk.PolicyType.ALWAYS);		

		this.userList = new Gtk.ListBox();
		this.userListWindow.add_with_viewport(userList);
		this.pack_start(userListWindow, true, true);

		this.userList.set_selection_mode (Gtk.SelectionMode.NONE);
		this.userList.activate_on_single_click = false;
	}
	public void addMoreButton()
	{
		if(!this.moreButton.is_ancestor(this))
			userList.prepend(this.moreButton);
	}
	public void deleteMoreButton()
	{
		this.userList.remove(this.get_children().last().data);
	}
	public bool contains(User user)
	{
		foreach(UserBox box in boxes)
			if(box.user.id == user.id)
				return true;

		return false;
	}
	public void append(User user)
	{
		Gtk.Separator separator = new Gtk.Separator (Gtk.Orientation.HORIZONTAL);
		userList.prepend(separator);
		UserBox box = new UserBox(user);
		userList.prepend(box);
		boxes.append(box);		
	}

	public new void prepend(User user)
	{
		Gtk.Separator separator = new Gtk.Separator (Gtk.Orientation.HORIZONTAL);
		userList.insert (separator, (int) this.userList.get_children().length () - 1);
		UserBox box = new UserBox(user);
		userList.insert (box, (int) this.userList.get_children().length () - 1);
		boxes.append(box);			
	}

	public void clear()
	{
		foreach (var child in this.userList.get_children())
			this.userList.remove(child);
		this.boxes = new List<UserBox>();

		this.userListWindow.get_vadjustment().set_value(0);
	}
}