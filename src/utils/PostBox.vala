using PhotoStream.Utils;

public class PhotoStream.PostBox : Gtk.EventBox
{
	public Gtk.Box box;
	public PostBox(MediaInfo post)
	{
		box = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
		this.add(box);
		box.add(new Gtk.Label(post.title));
		//stdout.printf("%lld\n", post.likesCount);
		box.add(new Gtk.Label( post.likesCount.to_string() + " likes."));
	}
}