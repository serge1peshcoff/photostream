using PhotoStream.Utils;
using Gdk;

public class PhotoStream.Widgets.PostBox : Gtk.EventBox
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
	public Gtk.Button likeButton;
	public Gtk.Image likeImage;
	public const int AVATAR_SIZE = 70;
	public const int IMAGE_SIZE = 400;
	public const int LIKE_SIZE = 20;

	public CommentsList commentList;

	public MediaInfo post;

	public PostBox(MediaInfo post)
	{
		box = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
		this.add(box);

		set_events (Gdk.EventMask.BUTTON_RELEASE_MASK);

		this.post = post;
		userToolbar = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);

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

		likeToolbar = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);

		Pixbuf likePixbuf;
		try 
        {
        	likePixbuf = new Pixbuf.from_file(post.didILikeThis 
        								? PhotoStream.App.CACHE_IMAGES + "like.jpg" 
        								: PhotoStream.App.CACHE_IMAGES + "dontlike.jpg");
        }	
        catch (Error e)
        {
        	GLib.error("Something wrong with file loading.\n");
        }


        likePixbuf = likePixbuf.scale_simple(LIKE_SIZE, LIKE_SIZE, Gdk.InterpType.BILINEAR);
        likeImage = new Gtk.Image.from_pixbuf(likePixbuf);
		likeToolbar.pack_start(likeImage, false, true);

		string likesText = "";
		if (post.likesCount == post.likes.length() && post.likesCount != 0) // if all likes can be displayed or there's no likes
		{
			foreach (User likedUser in post.likes)
				if(post.likes.index(likedUser) == post.likes.length() || post.likes.length() == 1) // last user
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
				commentList.prepend(comment);
			box.add(commentList);
		}
	}	
	public void loadAvatar()
	{
		var avatarFileName = PhotoStream.App.CACHE_AVATARS + getFileName(post.postedUser.profilePicture);
		File file = File.new_for_path(avatarFileName);
        if (!file.query_exists()) // avatar not downloaded, download
        	downloadFile(post.postedUser.profilePicture, avatarFileName);

        Idle.add(() => {
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
			return false;
        });
	}

	public void loadImage()
	{
		var imageFileName = PhotoStream.App.CACHE_URL + getFileName(post.type == PhotoStream.MediaType.VIDEO 
																		? post.media.previewUrl 
																		: post.media.url);

		File file = File.new_for_path(imageFileName);
        if (!file.query_exists()) // avatar not downloaded, download
        	downloadFile(post.type == PhotoStream.MediaType.VIDEO ? post.media.previewUrl : post.media.url, imageFileName);

        Idle.add(() => {
        	Pixbuf imagePixbuf; 
        	Pixbuf videoPixbuf;
	        try 
	        {
	        	imagePixbuf = new Pixbuf.from_file(imageFileName);
	        	imagePixbuf = imagePixbuf.scale_simple(IMAGE_SIZE, IMAGE_SIZE, Gdk.InterpType.BILINEAR);
	        	if (post.type == PhotoStream.MediaType.VIDEO)
	        	{	        		
	        		videoPixbuf = new Pixbuf.from_file(PhotoStream.App.CACHE_IMAGES + "video.png");
	        		videoPixbuf = videoPixbuf.scale_simple(IMAGE_SIZE, IMAGE_SIZE, Gdk.InterpType.BILINEAR);
	        		videoPixbuf.composite(imagePixbuf, 0, 0, 
	        									IMAGE_SIZE, IMAGE_SIZE, 0, 0, 1.0, 1.0, Gdk.InterpType.BILINEAR, 255);
	        	}
	        }	
	        catch (Error e)
	        {
	        	GLib.error("Something wrong with file loading.\n");
	        }	
			
			
			image.set_from_pixbuf(imagePixbuf);
			return false;
        }); 				
	}

	public string getFileName(string url)
    {
        var indexStart = url.last_index_of("/") + 1;
        return url.substring(indexStart, url.length - indexStart);
    }
}