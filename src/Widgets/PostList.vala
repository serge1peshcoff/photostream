using PhotoStream.Utils;

public class PhotoStream.Widgets.PostList : Gtk.ListBox
{
	public GLib.List<PostBox> boxes;
	public Gtk.Button moreButton;
	public PostList()
	{
		boxes = new GLib.List<PostBox>();
		this.moreButton = new Gtk.Button.with_label("Load more...");
		base.prepend(this.moreButton);

		this.set_selection_mode (Gtk.SelectionMode.NONE);
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
}