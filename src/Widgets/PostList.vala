using PhotoStream.Utils;
using Gtk;

public class PhotoStream.Widgets.PostList : Gtk.ListBox
{
	public GLib.List<PostBox> boxes;
	public Gtk.Button moreButton;
	public Gtk.Alignment moreButtonAlignment;
	public string olderFeedLink;

	public PostList()
	{
		boxes = new GLib.List<PostBox>();	
		this.moreButton = new Gtk.Button.with_label("Load more...");	

		this.moreButtonAlignment = new Gtk.Alignment (1,0,1,0);
        this.moreButtonAlignment.add(moreButton);
        base.prepend(this.moreButtonAlignment);

		this.set_selection_mode (Gtk.SelectionMode.NONE);
		this.activate_on_single_click = false;
	}

	public void deleteMoreButton()
	{
		if (this.moreButtonAlignment.is_ancestor(this))
		{
			Gtk.ListBoxRow buttonRow = (Gtk.ListBoxRow)this.get_children().last().data;
			buttonRow.remove(moreButtonAlignment);
		}
	}
	public bool contains(MediaInfo post)
	{
		foreach(PostBox box in boxes)
			if(box.post.id == post.id)
				return true;

		return false;
	}
	public void append(MediaInfo post)
	{
		Gtk.Separator separator = new Gtk.Separator (Gtk.Orientation.HORIZONTAL);
		base.prepend(separator);
		PostBox box = new PostBox(post);

		var listBoxRow = new Gtk.ListBoxRow();
		//listBoxRow.set_selectable(false);
		listBoxRow.add(box);
		base.prepend(listBoxRow);
		boxes.prepend(box);		
	}

	public new void prepend(MediaInfo post)
	{
		Gtk.Separator separator = new Gtk.Separator (Gtk.Orientation.HORIZONTAL);
		base.insert (separator, (int) this.get_children().length () - 1);
		PostBox box = new PostBox(post);

		var listBoxRow = new Gtk.ListBoxRow();
		//listBoxRow.set_selectable(false);
		listBoxRow.add(box);
		base.insert (listBoxRow, (int) this.get_children().length () - 1);
		boxes.append(box);			
	}

	public void clear()
	{
		foreach (var child in this.get_children())
			if (!(((Gtk.ListBoxRow) child).get_child() is Gtk.Alignment)) // we don't want to remove "add more" button, right?
				this.remove(child);

		this.boxes = new List<PostBox>();

		if (!this.moreButtonAlignment.is_ancestor(this) && this.olderFeedLink != "")
			base.prepend(this.moreButtonAlignment);

		
	}
}