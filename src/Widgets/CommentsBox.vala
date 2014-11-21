using PhotoStream.Utils;
using Gdk;

public class PhotoStream.Widgets.CommentBox : Gtk.Box
{
	public Comment comment;
	public Gtk.Label textLabel;
	public Gtk.EventBox avatarBox;
	public Gtk.Image avatar;
	public int AVATAR_SIZE = 35;

	public CommentBox(Comment comment, bool withAvatar)
	{
		this.comment = comment;
		this.textLabel = new Gtk.Label("");
		this.textLabel.set_markup("<b>" + wrapInTags("@" + comment.user.username) + "</b> " + wrapInTags(comment.text));
		this.textLabel.set_line_wrap(true);
		this.textLabel.set_justify(Gtk.Justification.LEFT);

		set_events (Gdk.EventMask.BUTTON_RELEASE_MASK);

		if (withAvatar)
		{
			var avatarFileName = PhotoStream.App.CACHE_AVATARS + getFileName(comment.user.profilePicture);
			File file = File.new_for_path(avatarFileName);
	        if (!file.query_exists()) // avatar not downloaded, download
	        	downloadFile(comment.user.profilePicture, avatarFileName);


        	avatar = new Gtk.Image();
        	avatarBox = new Gtk.EventBox();
        	avatarBox.add(avatar);
        	Pixbuf avatarPixbuf; 
	        try 
	        {
	        	avatarPixbuf = new Pixbuf.from_file(avatarFileName);
	        }	
	        catch (Error e)
	        {
	        	GLib.error("Something wrong with file loading.\n");
	        }
			avatarPixbuf = avatarPixbuf.scale_simple(AVATAR_SIZE, AVATAR_SIZE, Gdk.InterpType.BILINEAR);

			avatar.set_from_pixbuf(avatarPixbuf);	
			this.pack_start(avatarBox, false, true);	
		}
		this.add(textLabel);

		this.show_all();
	}

	public string getFileName(string url)
    {
        var indexStart = url.last_index_of("/") + 1;
        return url.substring(indexStart, url.length - indexStart);
    }
}