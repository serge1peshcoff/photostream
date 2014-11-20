using PhotoStream.Utils;
public class PhotoStream.Widgets.CommentsList : Gtk.ListBox
{
	public GLib.List<CommentBox> comments;
	public Gtk.LinkButton loadMoreButton;
	public Gtk.Box moreBox;

	public void addMoreButton()
	{
		this.moreBox = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 0);
		this.loadMoreButton = new Gtk.LinkButton("Load more...");

		this.moreBox.add(loadMoreButton);
		base.prepend(moreBox);
	}

	public CommentsList()
	{
		this.comments = new GLib.List<CommentBox>();
	}
	public void append(Comment post)
	{
		CommentBox box = new CommentBox(post);
		base.prepend(box);
		comments.append(box);		
	}

	public new void prepend(Comment post)
	{
		CommentBox box = new CommentBox(post);
		base.insert (box, -1);
		comments.append(box);			
	}
}