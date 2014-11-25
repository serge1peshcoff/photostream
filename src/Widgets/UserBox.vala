using PhotoStream.Utils;
using Gdk;

public class PhotoStream.Widgets.UserBox : Gtk.EventBox
{
	public Gtk.Box box;

	public Gtk.Box userToolbar;
	public Gtk.Label userNameLabel;
	public Gtk.Label titleLabel;
	public Gtk.Image avatarImage;
	public Gtk.EventBox avatarBox;
	public const int AVATAR_SIZE = 70;

	public CommentsList commentList;

	public User user;

	public UserBox(User user)
	{
		box = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 0);
		this.add(box);

		set_events (Gdk.EventMask.BUTTON_RELEASE_MASK);

		this.user = user;

		this.avatarImage = new Gtk.Image();
		this.avatarBox = new Gtk.EventBox();
		avatarBox.add(avatarImage);
		this.box.add(avatarBox);

		this.userNameLabel = new Gtk.Label("");
		if (user.fullName == "")
			userNameLabel.set_markup(wrapInTags("@" + user.username));
		else
			userNameLabel.set_markup("<b>" + user.fullName + "</b> (" + wrapInTags("@" + user.username) + ")");

		this.box.add(userNameLabel);
	}

	public void loadAvatar()
	{
		var avatarFileName = PhotoStream.App.CACHE_AVATARS + getFileName(user.profilePicture);
		File file = File.new_for_path(avatarFileName);
        if (!file.query_exists()) // avatar not downloaded, download
        	downloadFile(user.profilePicture, avatarFileName);

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

	public string getFileName(string url)
    {
        var indexStart = url.last_index_of("/") + 1;
        return url.substring(indexStart, url.length - indexStart);
    }

}