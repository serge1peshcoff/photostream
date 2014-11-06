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

	public PostBox(MediaInfo post)
	{
		box = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
		this.add(box);

		userToolbar = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
		var avatarFileName = PhotoStream.App.CACHE_AVATARS + getFileName(post.postedUser.profilePicture);
		downloadFile(post.postedUser.profilePicture, avatarFileName);

		Pixbuf avatarPixbuf = new Pixbuf.from_file(avatarFileName);	
		avatarPixbuf = avatarPixbuf.scale_simple(AVATAR_SIZE, AVATAR_SIZE, Gdk.InterpType.BILINEAR);	

		avatar = new Gtk.Image();
		avatar.set_from_pixbuf(avatarPixbuf);

		userNameLabel = new Gtk.Label("@" + post.postedUser.username);
		this.userNameLabel.set_markup(
                "<span underline='none' font_weight='bold' size='large'>" +
                post.postedUser.username + "</span>"
                );

		userToolbar.add(avatar);
		userToolbar.add(userNameLabel);
		box.pack_start(userToolbar, false, true);

		var imageFileName = PhotoStream.App.CACHE_URL + getFileName(post.image.url);
		downloadFile(post.image.url, imageFileName);

		Pixbuf imagePixbuf = new Pixbuf.from_file(imageFileName);	
		imagePixbuf = imagePixbuf.scale_simple(IMAGE_SIZE, IMAGE_SIZE, Gdk.InterpType.BILINEAR);

		image = new Gtk.Image();
		image.set_from_pixbuf(imagePixbuf);

		box.add(image);


		box.add(new Gtk.Label(post.title));
		box.add(new Gtk.Label( post.likesCount.to_string() + " likes."));
	}

	public string getFileName(string url)
	{
		var indexStart = url.last_index_of("/") + 1;
		return url.substring(indexStart, url.length - indexStart);
	}
}