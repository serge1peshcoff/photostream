using PhotoStream.Utils;
using Gdk;

public class PhotoStream.PostBox : Gtk.EventBox
{
	public Gtk.Box box;

	public Gtk.Box userToolbar;
	public Gtk.Label userNameLabel;
	public Gtk.Image avatar;
	public Gtk.Image image;
	public const int AVATAR_SIZE = 70;
	public const int IMAGE_SIZE = 400;

	public MediaInfo post;

	public PostBox(MediaInfo post)
	{
		box = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
		this.add(box);

		this.post = post;

		userToolbar = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);

		avatar = new Gtk.Image();
		userToolbar.pack_start(avatar, false, true);		

		userNameLabel = new Gtk.Label("");
		userNameLabel.set_markup(
                "<span underline='none' font_weight='bold' size='large'>" +
                post.postedUser.username + "</span>"
                );

		
		userToolbar.add(userNameLabel);
		box.pack_start(userToolbar, false, true);	

		image = new Gtk.Image();
		box.add(image);	

		box.add(new Gtk.Label(post.title));
		box.add(new Gtk.Label( post.likesCount.to_string() + " likes."));
		print("finished.\n");

		this.set_sensitive (false);

		return;
	}	
	public void loadAvatar()
	{
		var avatarFileName = PhotoStream.App.CACHE_AVATARS + getFileName(post.postedUser.profilePicture);
        downloadFile(post.postedUser.profilePicture, avatarFileName);

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
		print("finished avatar.\n");
	}

	public void loadImage()
	{
		var imageFileName = PhotoStream.App.CACHE_URL + getFileName(post.image.url);
        downloadFile(post.image.url, imageFileName);

        Pixbuf imagePixbuf; 
        try 
        {
        	imagePixbuf = new Pixbuf.from_file(imageFileName);
        }	
        catch (Error e)
        {
        	GLib.error("Something wrong with file loading.\n");
        }	
		imagePixbuf = imagePixbuf.scale_simple(IMAGE_SIZE, IMAGE_SIZE, Gdk.InterpType.BILINEAR);

		
		image.set_from_pixbuf(imagePixbuf);
		print("finished image.\n");

				
	}

	public string getFileName(string url)
    {
        var indexStart = url.last_index_of("/") + 1;
        return url.substring(indexStart, url.length - indexStart);
    }
}