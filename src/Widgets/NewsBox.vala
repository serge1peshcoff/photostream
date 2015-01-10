using PhotoStream.Utils;
using Gdk;

public class PhotoStream.Widgets.NewsBox : Gtk.EventBox
{
	public Gtk.Box box;

	public Gtk.Image avatarImage;
	public Gtk.Image postImage;
	public Gtk.Box textBox;
	public Gtk.Label commentLabel;
	public PhotoStream.Widgets.DateLabel dateLabel;

	public Gtk.EventBox avatarBox;
	public Gtk.EventBox postImageBox;

	public Gtk.Alignment avatarAlignment;
	public Gtk.Alignment commentAlignment;
	public Gtk.Alignment dateAlignment;
	public Gtk.Alignment postImageAlignment;

	public int AVATAR_SIZE = 50;

	public NewsActivity activity;

	public NewsBox(NewsActivity activity)
	{
		var actions = new Gee.HashMap<string, string>();
		actions["follow"] = "followed you.";
		actions["like"] = "liked your photo";
		actions["mention"] = "mentioned you in a comment:";
		actions["comment"] = "left a comment on your photo:";
		actions["tagged-in-photo"] = "took a picture of you.";
		actions["fb-contact-joined"] = "";

		this.box = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 0);
		this.add(box);

		this.activity = activity;

		this.avatarAlignment = new Gtk.Alignment (0,0,0,0);
        this.avatarAlignment.top_padding = 5;
        this.avatarAlignment.right_padding = 5;
        this.avatarAlignment.bottom_padding = 5;
        this.avatarAlignment.left_padding = 5;	

		this.avatarImage = new Gtk.Image();
		this.avatarBox = new Gtk.EventBox();
		this.avatarBox.add(avatarImage);
		this.avatarAlignment.add(avatarBox);
		this.box.add(avatarAlignment);

		this.textBox = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
		this.box.add(textBox);		

		new Thread<int>("", () => {
			this.loadAvatar();
			return 0;
		});

		string commentString = "<b>" + wrapInTags("@" + activity.username) + "</b> " + actions[activity.activityType];

		if (activity.activityType == "mention" || activity.activityType == "comment")
			commentString += "\n" + wrapInTags(activity.comment);
		if (activity.activityType == "fb-contact-joined")
			commentString = wrapInTags(activity.comment);

		this.commentAlignment = new Gtk.Alignment (0,1,1,1);
        this.commentAlignment.top_padding = 5;
        this.commentAlignment.right_padding = 5;
        this.commentAlignment.bottom_padding = 5;
        this.commentAlignment.left_padding = 5;	

        this.dateAlignment = new Gtk.Alignment (0,1,1,1);
        this.dateAlignment.top_padding = 5;
        this.dateAlignment.right_padding = 5;
        this.dateAlignment.bottom_padding = 5;
        this.dateAlignment.left_padding = 5;	

		this.commentLabel = new Gtk.Label("");
		this.commentLabel.set_markup(commentString);
		this.commentLabel.set_line_wrap(true);
		this.commentLabel.xalign = 0;
		this.commentLabel.wrap_mode = Pango.WrapMode.WORD_CHAR;
		this.dateLabel = new PhotoStream.Widgets.DateLabel(this.activity.time);
		
		this.commentAlignment.add(commentLabel);
		this.dateAlignment.add(dateLabel);
		this.textBox.add(commentAlignment);
		this.textBox.add(dateAlignment);

		this.postImage = new Gtk.Image();
		this.postImageBox = new Gtk.EventBox();
		this.postImageAlignment = new Gtk.Alignment (0,0,0,0);
        this.postImageAlignment.top_padding = 5;
        this.postImageAlignment.right_padding = 5;
        this.postImageAlignment.bottom_padding = 5;
        this.postImageAlignment.left_padding = 5;	


		if (activity.activityType != "follow")
		{
			postImageBox.add(postImage);
			postImageAlignment.add(postImageBox);
			this.box.pack_end(postImageAlignment, false, true);
			new Thread<int>("", () => {
				this.loadImage();
				return 0;
			});
		} 

		this.avatarBox.set_events (Gdk.EventMask.BUTTON_RELEASE_MASK);
		this.avatarBox.set_events (Gdk.EventMask.ENTER_NOTIFY_MASK);
		this.postImageBox.set_events (Gdk.EventMask.BUTTON_RELEASE_MASK);
		this.postImageBox.set_events (Gdk.EventMask.ENTER_NOTIFY_MASK);

		this.avatarBox.enter_notify_event.connect((event) => {
			event.window.set_cursor (
                new Gdk.Cursor.from_name (Gdk.Display.get_default(), "hand2")
            );
            return false;
		});
		this.postImageBox.enter_notify_event.connect((event) => {
			event.window.set_cursor (
                new Gdk.Cursor.from_name (Gdk.Display.get_default(), "hand2")
            );
            return false;
		});
    }

    private void loadAvatar()
    {
    	var avatarFileName = PhotoStream.App.CACHE_AVATARS + getFileName(activity.userProfilePicture);
		File file = File.new_for_path(avatarFileName);
        if (!file.query_exists()) // avatar not downloaded, download
        	try
        	{
        		downloadFile(activity.userProfilePicture, avatarFileName);
        	}
        	catch (Error e)
        	{
        		return; // not loading avatar, to fix.
        	}

        Idle.add(() => {
			Pixbuf avatarPixbuf; 
        	Pixbuf avatarMaskPixbuf;
	        try 
	        {
	        	avatarPixbuf = new Pixbuf.from_file(avatarFileName);
	        	avatarMaskPixbuf = new Pixbuf.from_file(PhotoStream.App.CACHE_IMAGES + "avatar-mask.png");
	        }	
	        catch (Error e)
	        {
	        	GLib.error("Something wrong with file loading.\n");
	        }
			avatarPixbuf = avatarPixbuf.scale_simple(AVATAR_SIZE, AVATAR_SIZE, Gdk.InterpType.BILINEAR);
			avatarMaskPixbuf = avatarMaskPixbuf.scale_simple(AVATAR_SIZE, AVATAR_SIZE, Gdk.InterpType.BILINEAR);

			avatarMaskPixbuf.composite(avatarPixbuf, 0, 0, 
	        						AVATAR_SIZE, AVATAR_SIZE, 0, 0, 1.0, 1.0, Gdk.InterpType.BILINEAR, 255);

			avatarImage.set_from_pixbuf(avatarPixbuf);
			return false;
        });
    }

    private void loadImage()
    {
    	var imageFileName = PhotoStream.App.CACHE_AVATARS + getFileName(activity.imagePicture);
		File file = File.new_for_path(imageFileName);
        if (!file.query_exists()) // avatar not downloaded, download
        	try
        	{
        		downloadFile(activity.imagePicture, imageFileName);
        	}
        	catch (Error e)
        	{
        		return; // not loading avatar, to fix.
        	}

        Idle.add(() => {
			Pixbuf imagePixbuf; 
        	Pixbuf imageMaskPixbuf;
	        try 
	        {
	        	imagePixbuf = new Pixbuf.from_file(imageFileName);
	        	imageMaskPixbuf = new Pixbuf.from_file(PhotoStream.App.CACHE_IMAGES + "avatar-mask.png");
	        }	
	        catch (Error e)
	        {
	        	GLib.error("Something wrong with file loading.\n");
	        }
			imagePixbuf = imagePixbuf.scale_simple(AVATAR_SIZE, AVATAR_SIZE, Gdk.InterpType.BILINEAR);
			imageMaskPixbuf = imageMaskPixbuf.scale_simple(AVATAR_SIZE, AVATAR_SIZE, Gdk.InterpType.BILINEAR);

			imageMaskPixbuf.composite(imagePixbuf, 0, 0, 
	        						AVATAR_SIZE, AVATAR_SIZE, 0, 0, 1.0, 1.0, Gdk.InterpType.BILINEAR, 255);

			postImage.set_from_pixbuf(imagePixbuf);
			return false;
        });
    }

}