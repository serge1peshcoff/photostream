using PhotoStream.Utils;

public class PhotoStream.Widgets.NewsList : Gtk.ListBox
{
	public GLib.List<NewsBox> boxes;
	// there is no olderFeedLink, news can't do this
	// and there's also no loadMore button
	public NewsList()
	{
		boxes = new GLib.List<NewsBox>();
		this.set_selection_mode (Gtk.SelectionMode.NONE);
		this.activate_on_single_click = false;
	}

	public void append(NewsActivity post)
	{
		Gtk.Separator separator = new Gtk.Separator (Gtk.Orientation.HORIZONTAL);
		base.prepend(separator);
		NewsBox box = new NewsBox(post);
		base.prepend(box);
		boxes.append(box);		
	}

	public bool contains (NewsActivity activity)
	{
		foreach (NewsBox activityInList in boxes)
			if (activityInList.activity.time == activity.time
				&& activityInList.activity.username == activity.username
				&& activityInList.activity.activityType == activity.activityType)
				return true;

		return false;
	}

	public new void prepend(NewsActivity post)
	{
		Gtk.Separator separator = new Gtk.Separator (Gtk.Orientation.HORIZONTAL);
		base.insert (separator, (int) this.get_children().length () - 1);
		NewsBox box = new NewsBox(post);
		base.insert (box, (int) this.get_children().length () - 1);
		boxes.append(box);			
	}

	public void clear()
	{
		foreach (var child in this.get_children())
			this.remove(child);
		this.boxes = new List<NewsBox>();
	}
}