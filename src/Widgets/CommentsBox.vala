using PhotoStream.Utils;
using Gdk;

public class PhotoStream.Widgets.CommentBox : Gtk.Box
{
	public Comment comment;

	public Gtk.Alignment avatarAlignment;
	public Gtk.Alignment textAlignment;

	public Gtk.Box textBox;
	public Gtk.Label textLabel;
	public Gtk.EventBox avatarBox;
	public Gtk.Image avatar;
	public int AVATAR_SIZE = 35;

	public CommentBox(Comment comment, bool withAvatar)
	{
		this.set_halign(Gtk.Align.START);

		this.comment = comment;

		this.textAlignment = new Gtk.Alignment (0,1,1,1);
        this.textAlignment.top_padding = 1;
        this.textAlignment.right_padding = 0;
        this.textAlignment.bottom_padding = 1;
        this.textAlignment.left_padding = 0;

        this.avatarAlignment = new Gtk.Alignment (0,1,1,1);
        this.avatarAlignment.top_padding = 1;
        this.avatarAlignment.right_padding = 6;
        this.avatarAlignment.bottom_padding = 1;
        this.avatarAlignment.left_padding = 0;

        this.textBox = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 0);
		this.textLabel = new Gtk.Label("");
		this.textLabel.set_markup("<b>" + wrapInTags("@" + comment.user.username) + "</b> " + wrapInTags(comment.text));
		this.textLabel.set_line_wrap(true);
		this.textLabel.set_line_wrap_mode(Pango.WrapMode.WORD_CHAR);
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

			avatarAlignment.add(avatarBox);
			this.pack_start(avatarAlignment, false, true);	
		}
		textBox.add(textLabel);
		textAlignment.add(textBox);
		this.pack_end(textAlignment, false, true);

		this.show_all();
	}

	public string getFileName(string url)
    {
        var indexStart = url.last_index_of("/") + 1;
        return url.substring(indexStart, url.length - indexStart);
    }
}