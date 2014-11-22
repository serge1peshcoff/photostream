using PhotoStream.Utils;

public class PhotoStream.Widgets.HashTagList : Gtk.ListBox
{
	public GLib.List<HashTagBox> boxes;
	public Gtk.Button moreButton;
	public string olderFeedLink;
	public HashTagList()
	{
		boxes = new GLib.List<HashTagBox>();
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
	public bool contains(Tag tag)
	{
		foreach(HashTagBox box in boxes)
			if(box.tag.tag == tag.tag)
				return true;

		return false;
	}
	public void append(Tag tag)
	{
		Gtk.Separator separator = new Gtk.Separator (Gtk.Orientation.HORIZONTAL);
		base.prepend(separator);
		HashTagBox box = new HashTagBox(tag);
		base.prepend(box);
		boxes.append(box);		
	}

	public new void prepend(Tag tag)
	{
		Gtk.Separator separator = new Gtk.Separator (Gtk.Orientation.HORIZONTAL);
		base.insert (separator, (int) this.get_children().length () - 1);
		HashTagBox box = new HashTagBox(tag);
		base.insert (box, (int) this.get_children().length () - 1);
		boxes.append(box);			
	}

	public void clear()
	{
		foreach (var child in this.get_children())
			this.remove(child);
		this.boxes = new List<HashTagBox>();
	}
}