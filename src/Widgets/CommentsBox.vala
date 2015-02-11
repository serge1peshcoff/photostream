using PhotoStream.Utils;
using Gdk;

public class PhotoStream.Widgets.CommentBox : Gtk.EventBox
{
	public Comment comment;

	public Gtk.Alignment avatarAlignment;
	public Gtk.Alignment textAlignment;

	public Gtk.Box overallBox;

	public Gtk.Box textBox;
	public Gtk.Label textLabel;
	public Gtk.EventBox avatarBox;
	public Gtk.EventBox textEventBox;
	public PhotoStream.Widgets.Image avatar;
	public Gtk.ToolButton removeCommentButton;
	public int AVATAR_SIZE = 35;

	public CommentBox(Comment comment, bool withAvatar)
	{
		this.set_events(Gdk.EventMask.BUTTON_RELEASE_MASK);
		this.overallBox = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 0);
		this.add(overallBox);

		this.set_halign(Gtk.Align.FILL);
		this.hexpand = true;

		this.comment = comment;

		this.textAlignment = new Gtk.Alignment (0,0.5f,1,0);
        this.textAlignment.top_padding = 1;
        this.textAlignment.right_padding = 0;
        this.textAlignment.bottom_padding = 1;
        this.textAlignment.left_padding = 0;

        this.textBox = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 0);
        this.textEventBox = new Gtk.EventBox();
		this.textLabel = new Gtk.Label("");
		this.textLabel.set_markup("<b>" + wrapInTags("@" + comment.user.username) + "</b> " + wrapInTags(comment.text));
		this.textLabel.set_line_wrap(true);
		this.textLabel.set_line_wrap_mode(Pango.WrapMode.WORD_CHAR);
		//this.textLabel.set_max_width_chars(40);
		this.textLabel.set_justify(Gtk.Justification.LEFT);
		this.textLabel.set_halign(Gtk.Align.FILL);
		this.textLabel.set_valign(Gtk.Align.START);
		this.textLabel.xalign = 0;

		set_events (Gdk.EventMask.BUTTON_RELEASE_MASK);
		this.textEventBox.set_events(Gdk.EventMask.BUTTON_RELEASE_MASK);

		if (withAvatar)
		{
			this.avatarAlignment = new Gtk.Alignment (0,1,1,1);
	        this.avatarAlignment.top_padding = 1;
	        this.avatarAlignment.right_padding = 6;
	        this.avatarAlignment.bottom_padding = 1;
	        this.avatarAlignment.left_padding = 0;

			avatar = new PhotoStream.Widgets.Image(AVATAR_SIZE);

			avatarBox = new Gtk.EventBox();
		    avatarBox.add(avatar);
			avatarAlignment.add(avatarBox);
			this.overallBox.pack_start(avatarAlignment, false, true);	

			avatarBox.enter_notify_event.connect((event) => {
				event.window.set_cursor (
	                new Gdk.Cursor.from_name (Gdk.Display.get_default(), "hand2")
	            );
	            return false;
			});

			this.show_all();
		}

		this.removeCommentButton = new Gtk.ToolButton(new Gtk.Image.from_icon_name ("dialog-cancel", Gtk.IconSize.LARGE_TOOLBAR), "Go back");


		textBox.add(textLabel);
		textEventBox.add(textBox);
		textAlignment.add(textEventBox);		
		this.overallBox.add(textAlignment);
		if (PhotoStream.App.selfUser.id == comment.user.id)
			this.overallBox.pack_end(removeCommentButton, false, true);
			
		this.show_all();		

		this.realize.connect(() => {

			Gtk.Window parentWindow = (Gtk.Window) this.get_toplevel();
			PhotoStream.App app = (PhotoStream.App)parentWindow.get_application();
			
	        if(this.avatarBox != null)
	            this.avatarBox.button_release_event.connect(() => {
	                new Thread<int>("", () => {
	                    app.loadUser(comment.user.id, comment.user);
	                    return 0;
	                });                   
	                return false;
	            });
		});
		
	}

	public void loadAvatar()
	{
		avatar.download(comment.user.profilePicture, PhotoStream.App.CACHE_IMAGES + "avatar-mask.png", true);	
	}
}