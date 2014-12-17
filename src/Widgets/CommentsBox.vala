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
	public Gtk.EventBox textEventBox;
	public Gtk.Image avatar;
	public Gtk.ToolButton removeCommentButton;
	public int AVATAR_SIZE = 35;

	public CommentBox(Comment comment, bool withAvatar)
	{
		this.set_halign(Gtk.Align.START);

		this.comment = comment;

		this.textAlignment = new Gtk.Alignment (0,0.5f,1,0);
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
        this.textEventBox = new Gtk.EventBox();
		this.textLabel = new Gtk.Label("");
		this.textLabel.set_markup("<b>" + wrapInTags("@" + comment.user.username) + "</b> " + wrapInTags(comment.text));
		this.textLabel.set_line_wrap(true);
		this.textLabel.set_line_wrap_mode(Pango.WrapMode.WORD_CHAR);
		this.textLabel.set_max_width_chars(40);
		this.textLabel.set_justify(Gtk.Justification.LEFT);
		this.textLabel.set_halign(Gtk.Align.START);
		this.textLabel.set_valign(Gtk.Align.START);
		this.textLabel.xalign = 0;

		set_events (Gdk.EventMask.BUTTON_RELEASE_MASK);
		this.textEventBox.set_events(Gdk.EventMask.BUTTON_RELEASE_MASK);

		if (withAvatar)
		{
			bool isImageLoaded = true;
			var avatarFileName = PhotoStream.App.CACHE_AVATARS + getFileName(comment.user.profilePicture);
			File file = File.new_for_path(avatarFileName);
	        if (!file.query_exists()) // avatar not downloaded, download
	        	try {
	        		downloadFile(comment.user.profilePicture, avatarFileName);
	        	}
	        	catch (Error e) // broken download
	        	{
	        		isImageLoaded = false;
	        	}	        	

	        if (isImageLoaded)
	        {
	        	avatar = new Gtk.Image();
	        	avatar.set_size_request(AVATAR_SIZE, AVATAR_SIZE);
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

				avatarBox.enter_notify_event.connect((event) => {
					event.window.set_cursor (
		                new Gdk.Cursor.from_name (Gdk.Display.get_default(), "hand2")
		            );
		            return false;
				});
			}
		}

		this.removeCommentButton = new Gtk.ToolButton(new Gtk.Image.from_icon_name ("dialog-cancel", Gtk.IconSize.LARGE_TOOLBAR), "Go back");


		textBox.add(textLabel);
		textEventBox.add(textBox);
		textAlignment.add(textEventBox);		
		this.add(textAlignment);
		if (PhotoStream.App.selfUser.id == comment.user.id)
			this.pack_end(removeCommentButton, false, true);
		this.set_size_request(625, -1);

		this.show_all();
	}
}