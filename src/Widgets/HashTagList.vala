using PhotoStream.Utils;

public class PhotoStream.Widgets.HashTagList : Gtk.Box
{
	public GLib.List<HashTagBox> boxes;
	public Gtk.Button moreButton;
	public string olderFeedLink;

	public Gtk.ListBox tagsList;
	public Gtk.ScrolledWindow tagsWindow;

	public HashTagList()
	{
		boxes = new GLib.List<HashTagBox>();
		this.moreButton = new Gtk.Button.with_label("Load more...");

		this.tagsList = new Gtk.ListBox();
		this.tagsList.set_selection_mode (Gtk.SelectionMode.NONE);
		this.tagsList.activate_on_single_click = false;

		this.tagsWindow = new Gtk.ScrolledWindow(null, null);
		this.tagsWindow.set_policy(Gtk.PolicyType.NEVER, Gtk.PolicyType.AUTOMATIC);

		this.tagsWindow.add_with_viewport(tagsList);
		this.pack_start(tagsWindow, true, true);
	}
	public void addMoreButton()
	{
		if(!this.moreButton.is_ancestor(this))
			tagsList.prepend(this.moreButton);
	}
	public void deleteMoreButton()
	{
		this.tagsList.remove(this.get_children().last().data);
	}
	public bool contains(Tag tag)
	{
		foreach(HashTagBox box in boxes)
			if(box.tag.tag == tag.tag)
				return true;

		return false;
	}

	public void loadTags(string response)
	{
		List<Tag> tagListRequested = new List<Tag>();

        try
        {
            tagListRequested = parseTagList(response);

        }
        catch (Error e) 
        {
            error("Something wrong with parsing: " + e.message + ".\n");
        }   

		Idle.add(() => {
			this.loadTagList(tagListRequested);
			return false;
		});
	}

	public void loadTagList(List<Tag> tagList)
	{
		this.clear();

		if (tagList.length() == 0)
		{
			stubEmptyList();
			return;
		}
		else if (!this.tagsList.is_ancestor(this))
		{
			if (this.get_children().length() != 0)
				this.remove(this.get_children().first().data);
			this.pack_start(this.tagsWindow, true, true);
		}

        foreach(Tag tagInList in tagList)
            this.prepend(tagInList); 
	}

	public void stubEmptyList()
	{
		if (!tagsWindow.is_ancestor(this) && this.get_children().length() != 0)
			return;

		EmptyTagList emptyTagList = new EmptyTagList();
		this.remove(tagsWindow);
		this.pack_end(emptyTagList, true, true);
		this.show_all();
	}

	public void append(Tag tag)
	{
		Gtk.Separator separator = new Gtk.Separator (Gtk.Orientation.HORIZONTAL);
		tagsList.prepend(separator);
		HashTagBox box = new HashTagBox(tag);
		tagsList.prepend(box);
		boxes.append(box);		
	}

	public new void prepend(Tag tag)
	{
		Gtk.Separator separator = new Gtk.Separator (Gtk.Orientation.HORIZONTAL);
		tagsList.insert (separator, (int) this.tagsList.get_children().length () - 1);
		HashTagBox box = new HashTagBox(tag);
		tagsList.insert (box, (int) this.tagsList.get_children().length () - 1);
		boxes.append(box);			
	}

	public void clear()
	{
		foreach (var child in this.tagsList.get_children())
			this.tagsList.remove(child);
		this.boxes = new List<HashTagBox>();
	}
}