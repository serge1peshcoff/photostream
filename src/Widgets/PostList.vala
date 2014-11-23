using PhotoStream.Utils;

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

		this.set_selection_mode (Gtk.SelectionMode.NONE);
		this.activate_on_single_click = false;
	}
	public void addMoreButton()
	{				
		this.moreButtonAlignment = new Gtk.Alignment (1,0,1,0);
        this.moreButtonAlignment.add(moreButton);
		if(!this.moreButton.is_ancestor(this))
			base.prepend(this.moreButtonAlignment);
	}
	public void deleteMoreButton()
	{
		this.remove(this.get_children().last().data);
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
		base.prepend(box);
		boxes.append(box);		
	}

	public new void prepend(MediaInfo post)
	{
		Gtk.Separator separator = new Gtk.Separator (Gtk.Orientation.HORIZONTAL);
		base.insert (separator, (int) this.get_children().length () - 1);
		PostBox box = new PostBox(post);
		base.insert (box, (int) this.get_children().length () - 1);
		boxes.append(box);			
	}

	public void clear()
	{
		foreach (var child in this.get_children())
			this.remove(child);
		this.boxes = new List<PostBox>();
	}
}