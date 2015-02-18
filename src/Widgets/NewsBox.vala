using PhotoStream.Utils;
using Gdk;

public class PhotoStream.Widgets.NewsBox : Gtk.EventBox
{
	public Gtk.Box box;

	public PhotoStream.Widgets.Image avatarImage;
	public PhotoStream.Widgets.Image postImage;
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
		actions["vkontakte-contact-joined"] = "";

		this.box = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 0);
		this.add(box);

		this.activity = activity;

		this.avatarAlignment = new Gtk.Alignment (0,0,0,0);
        this.avatarAlignment.top_padding = 5;
        this.avatarAlignment.right_padding = 5;
        this.avatarAlignment.bottom_padding = 5;
        this.avatarAlignment.left_padding = 5;	

		this.avatarImage = new PhotoStream.Widgets.Image(AVATAR_SIZE);
		this.avatarBox = new Gtk.EventBox();
		this.avatarBox.add(avatarImage);
		this.avatarAlignment.add(avatarBox);
		this.box.add(avatarAlignment);

		this.textBox = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
		this.box.add(textBox);		

		/*new Thread<int>("", () => {
			this.loadAvatar();
			return 0;
		});*/

		string commentString = "<b>" + wrapInTags("@" + activity.username) + "</b> " + actions[activity.activityType];

		if (activity.activityType == "mention" || activity.activityType == "comment")
			commentString += "\n" + wrapInTags(activity.comment);
		if (activity.activityType == "fb-contact-joined" || activity.activityType == "vkontakte-contact-joined")
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

		this.postImage = new PhotoStream.Widgets.Image(AVATAR_SIZE);
		this.postImageBox = new Gtk.EventBox();
		this.postImageAlignment = new Gtk.Alignment (0,0,0,0);
        this.postImageAlignment.top_padding = 5;
        this.postImageAlignment.right_padding = 5;
        this.postImageAlignment.bottom_padding = 5;
        this.postImageAlignment.left_padding = 5;	

		if (activity.activityType != "follow" 
			&& activity.activityType != "fb-contact-joined" 
			&& activity.activityType != "vkontakte-contact-joined")
		{
			postImageBox.add(postImage);
			postImageAlignment.add(postImageBox);
			this.box.pack_end(postImageAlignment, false, true);
			/*new Thread<int>("", () => {
				this.loadImage();
				return 0;
			});*/
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

		this.realize.connect(() => {
			var app = (PhotoStream.App)((Gtk.Window)this.get_toplevel()).get_application();

			this.avatarBox.button_release_event.connect(() => {
	            new Thread<int>("", () => {
	                app.loadUserFromUsername(this.activity.username);
	                return 0;
	            });                    
	            return false;
	        });
	        this.postImageBox.button_release_event.connect(() => {
	            new Thread<int>("", () => {
	                app.loadPost(this.activity.postId);
	                return 0;
	            });                    
	            return false;
	        });
	        this.commentLabel.activate_link.connect(app.handleUris); 
		});
    }

    public void loadAvatar()
    {
    	avatarImage.download(activity.userProfilePicture, PhotoStream.App.CACHE_IMAGES + "avatar-mask.png", true);
    }

    public void loadImage()
    {
    	postImage.download(activity.imagePicture);
    }
}