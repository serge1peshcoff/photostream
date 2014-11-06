using PhotoStream.Utils;

public class PhotoStream.PostList : Gtk.ListBox
{
	public GLib.List<PostBox> boxes;
	public PostList()
	{
		//boxes = new GLib.List<PostBox>;

	}
	public void append(MediaInfo post)
	{
		Gtk.Separator separator = new Gtk.Separator (Gtk.Orientation.HORIZONTAL);
		base.prepend(separator);
		PostBox box = new PostBox(post);
		base.prepend(box);		
	}
}