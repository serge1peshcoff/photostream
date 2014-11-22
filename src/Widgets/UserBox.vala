using PhotoStream.Utils;
using Gdk;

public class PhotoStream.Widgets.UserBox : Gtk.EventBox
{
	public Gtk.Box box;

	public Gtk.Box userToolbar;
	public Gtk.Label userNameLabel;
	public Gtk.Label dateLabel;
	public Gtk.Label titleLabel;
	public Gtk.Label likesLabel;
	public Gtk.Image avatar;
	public Gtk.EventBox avatarBox;
	public Gtk.Image image;
	public Gtk.Box likeToolbar;
	public Gtk.EventBox likeBox;
	public Gtk.Image likeImage;
	public Gtk.EventBox locationEventBox;
	public Gtk.Box locationBox;
	public Gtk.Image locationImage;
	public Gtk.Label locationLabel;
	public Pixbuf locationPixbuf;
	public string likesText;
	public const int AVATAR_SIZE = 70;
	public const int IMAGE_SIZE = 400;
	public const int LIKE_SIZE = 25;
	public const int LOCATION_SIZE = 25;

	public CommentsList commentList;

	public User user;

	public UserBox(User user)
	{
		box = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
		this.add(box);

		set_events (Gdk.EventMask.BUTTON_RELEASE_MASK);

		this.user = user;
		/*userToolbar = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);

		avatarBox = new Gtk.EventBox();
		avatar = new Gtk.Image();
		avatarBox.add(avatar);
		userToolbar.pack_start(avatarBox, false, true);	

		userNameLabel = new Gtk.Label("");
		userNameLabel.set_markup(
                "<span underline='none' font_weight='bold' size='large'>" +
                post.postedUser.username + "</span>"
                );
		userNameLabel.set_line_wrap(true);
		dateLabel = new Gtk.Label(post.creationTime.format("%e.%m.%Y %H:%M"));
		
		userToolbar.add(userNameLabel);
		userToolbar.add(dateLabel);
		box.pack_start(userToolbar, false, true);	

		image = new Gtk.Image();
		box.add(image);	

		titleLabel = new Gtk.Label("");
		titleLabel.set_markup(wrapInTags(post.title));
		titleLabel.set_line_wrap(true);
		titleLabel.set_justify(Gtk.Justification.LEFT);
		box.add(titleLabel);

		if (post.location != null)
		{
			this.locationEventBox = new Gtk.EventBox();
			loadLocation(post.location);
		}

		likeToolbar = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);

		Pixbuf likePixbuf;
		try 
        {
        	likePixbuf = new Pixbuf.from_file(post.didILikeThis 
        								? PhotoStream.App.CACHE_IMAGES + "like.png" 
        								: PhotoStream.App.CACHE_IMAGES + "dontlike.png");
        }	
        catch (Error e)
        {
        	GLib.error("Something wrong with file loading.\n");
        }


        likePixbuf = likePixbuf.scale_simple(LIKE_SIZE, LIKE_SIZE, Gdk.InterpType.BILINEAR);
        likeImage = new Gtk.Image.from_pixbuf(likePixbuf);
        likeBox = new Gtk.EventBox();
        likeBox.add(likeImage);
		likeToolbar.pack_start(likeBox, false, true);

		likeBox.button_release_event.connect(callback);

		likesText = "";
		if (post.likesCount == post.likes.length() && post.likesCount != 0) // if all likes can be displayed or there's no likes
		{
			foreach (User likedUser in post.likes)
				if(post.likes.index(likedUser) == post.likes.length() - 1 || post.likes.length() == 1) // last user
					likesText += "<a href=\"@" + likedUser.username + "\">" + likedUser.username + "</a>";
				else
					likesText += "<a href=\"@" + likedUser.username + "\">" + likedUser.username + "</a>, ";
		}
		else
			likesText = post.likesCount.to_string() + " likes.";

		likesLabel = new Gtk.Label("");
		likesLabel.set_markup(likesText);	

		likeToolbar.add(likesLabel);

		box.add(likeToolbar);
		commentList = new CommentsList();
		if (post.commentsCount != 0)
		{
			if(post.commentsCount !=  post.comments.length())
				commentList.addMoreButton();
			foreach(Comment comment in post.comments)
				commentList.prepend(comment, false);
			box.add(commentList);
		}*/
	}

}