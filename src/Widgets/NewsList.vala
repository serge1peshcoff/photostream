using PhotoStream.Utils;

public class PhotoStream.Widgets.NewsList : Gtk.Box
{
	public GLib.List<NewsBox> boxes;
	// there is no olderFeedLink, news can't do this
	// and there's also no loadMore button

	public Gtk.ListBox newsList;
	public Gtk.ScrolledWindow newsWindow;

	public NewsList()
	{
		boxes = new GLib.List<NewsBox>();		

		this.newsList = new Gtk.ListBox();
		this.newsList.set_selection_mode (Gtk.SelectionMode.NONE);
		this.newsList.activate_on_single_click = false;

		this.newsWindow = new Gtk.ScrolledWindow(null, null);
		this.newsWindow.set_policy(Gtk.PolicyType.NEVER, Gtk.PolicyType.ALWAYS);
		this.newsWindow.add_with_viewport(newsList);

		this.newsWindow.add_with_viewport(newsList);
		this.pack_start(newsWindow, true, true);
	}

	public void append(NewsActivity post)
	{
		Gtk.Separator separator = new Gtk.Separator (Gtk.Orientation.HORIZONTAL);
		newsList.prepend(separator);
		NewsBox box = new NewsBox(post);
		newsList.prepend(box);
		boxes.append(box);		
	}

	public bool contains (NewsActivity activity)
	{
		foreach (NewsBox activityInList in boxes)
		{
			//print("%s vs %s, %s vs %s, %s vs %s\n", 
			//	activityInList.activity.time.to_string(),  activity.time.to_string(), 
			//	activityInList.activity.username, activity.username, 
			//	activityInList.activity.activityType, activity.activityType);
			if (activityInList.activity.time.to_string() == activity.time.to_string()
				&& activityInList.activity.username == activity.username
				&& activityInList.activity.activityType == activity.activityType)
				return true;
		}

		return false;
	}

	public new void prepend(NewsActivity post)
	{
		Gtk.Separator separator = new Gtk.Separator (Gtk.Orientation.HORIZONTAL);
		newsList.insert (separator, (int) this.newsList.get_children().length () - 1);
		NewsBox box = new NewsBox(post);
		newsList.insert (box, (int) this.newsList.get_children().length () - 1);
		boxes.append(box);			
	}

	public void clear()
	{
		foreach (var child in this.newsList.get_children())
			this.newsList.remove(child);
		this.boxes = new List<NewsBox>();
	}
}