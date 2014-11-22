using PhotoStream.Utils;

public class PhotoStream.Widgets.UserList : Gtk.ListBox
{
	public GLib.List<UserBox> boxes;
	public Gtk.Button moreButton;
	public string olderFeedLink;
	public UserList()
	{
		boxes = new GLib.List<UserBox>();
		this.moreButton = new Gtk.Button.with_label("Load more...");

		this.set_selection_mode (Gtk.SelectionMode.NONE);
		this.activate_on_single_click = false;
	}
	public void addMoreButton()
	{
		if(!this.moreButton.is_ancestor(this))
			base.prepend(this.moreButton);
	}
	public void deleteMoreButton()
	{
		this.remove(this.get_children().last().data);
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
		base.prepend(separator);
		UserBox box = new UserBox(user);
		base.prepend(box);
		boxes.append(box);		
	}

	public new void prepend(User user)
	{
		Gtk.Separator separator = new Gtk.Separator (Gtk.Orientation.HORIZONTAL);
		base.insert (separator, (int) this.get_children().length () - 1);
		UserBox box = new UserBox(user);
		base.insert (box, (int) this.get_children().length () - 1);
		boxes.append(box);			
	}

	public void clear()
	{
		foreach (var child in this.get_children())
			this.remove(child);
		this.boxes = new List<UserBox>();
	}
}