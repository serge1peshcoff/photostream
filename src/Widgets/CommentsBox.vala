using PhotoStream.Utils;
using Gdk;

public class PhotoStream.Widgets.CommentBox : Gtk.Box
{
	public Comment comment;
	public Gtk.Label usernameLabel;
	public Gtk.Label textLabel;

	public CommentBox(Comment comment)
	{
		this.comment = comment;
		this.usernameLabel = new Gtk.Label("");
		this.usernameLabel.set_markup(wrapInTags("@" + comment.user.username));
		this.textLabel = new Gtk.Label("");
		this.textLabel.set_markup(wrapInTags(comment.text));

		this.add(usernameLabel);
		this.add(textLabel);
	}
}