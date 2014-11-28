using PhotoStream.Utils;
using Gdk;

public class PhotoStream.Widgets.PostBox : Gtk.EventBox
{
	public Gtk.Box box;

	public Gtk.Alignment avatarAlignment;
	public Gtk.Alignment userNameAlignment;
	public Gtk.Alignment imageAlignment;
	public Gtk.Alignment titleAlignment;
	public Gtk.Alignment locationAlignment;
	public Gtk.Alignment likeAlignment;
	public Gtk.Alignment commentsAlignment;

	public Pixbuf likePixbuf;
	public Pixbuf dislikePixbuf;

	public Gtk.Box userToolbar;
	public Gtk.Label userNameLabel;
	public Gtk.Label dateLabel;
	public Gtk.Label titleLabel;
	public Gtk.Label likesLabel;
	public Gtk.Image avatar;
	public Gtk.EventBox avatarBox;
	public Gtk.EventBox imageEventBox;
	public Gtk.Fixed imageBox;
	public Gtk.Image image;
	public Gtk.Box likeToolbar;
	public Gtk.EventBox likeBox;
	public List<Gtk.Popover> usersOnPhoto;
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

	public MediaInfo post;

	public PostBox(MediaInfo post)
	{
		box = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
		this.add(box);

		set_events (Gdk.EventMask.BUTTON_RELEASE_MASK);
		set_events(Gdk.EventMask.ENTER_NOTIFY_MASK);
        set_events(Gdk.EventMask.LEAVE_NOTIFY_MASK);

		try 
        {
        	likePixbuf = new Pixbuf.from_file(PhotoStream.App.CACHE_IMAGES + "like.png" );
        	dislikePixbuf = new Pixbuf.from_file(PhotoStream.App.CACHE_IMAGES + "dontlike.png");
        }	
        catch (Error e)
        {
        	GLib.error("Something wrong with file loading.\n");
        }

		this.post = post;
		userToolbar = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);

		this.avatarAlignment = new Gtk.Alignment (0,0,0,1);
        this.avatarAlignment.top_padding = 6;
        this.avatarAlignment.right_padding = 4;
        this.avatarAlignment.bottom_padding = 6;
        this.avatarAlignment.left_padding = 6;

		avatarBox = new Gtk.EventBox();
		avatar = new Gtk.Image();
		avatarBox.add(avatar);
		avatarAlignment.add(avatarBox);
		userToolbar.pack_start(avatarAlignment, false, true);

		avatarBox.enter_notify_event.connect((event) => {
			event.window.set_cursor (
                new Gdk.Cursor.from_name (Gdk.Display.get_default(), "hand2")
            );
            return false;
		});

		this.userNameAlignment = new Gtk.Alignment (0,0,0,1);
        this.userNameAlignment.top_padding = 6;
        this.userNameAlignment.right_padding = 6;
        this.userNameAlignment.bottom_padding = 0;
        this.userNameAlignment.left_padding = 6;	

		userNameLabel = new Gtk.Label("");
		userNameLabel.set_markup(
                "<span underline='none' font_weight='bold' size='large'>" +
                post.postedUser.username + "</span>"
                );
		userNameLabel.set_line_wrap(true);
		dateLabel = new Gtk.Label(post.creationTime.format("%e.%m.%Y %H:%M"));
		

		userNameAlignment.add(userNameLabel);		
		userToolbar.add(userNameAlignment);
		userToolbar.add(dateLabel);
		box.pack_start(userToolbar, false, true);

		this.imageAlignment = new Gtk.Alignment (0,0,0,1);
        this.imageAlignment.top_padding = 6;
        this.imageAlignment.right_padding = 6;
        this.imageAlignment.bottom_padding = 0;
        this.imageAlignment.left_padding = 6;	

        imageEventBox = new Gtk.EventBox();
		imageBox = new Gtk.Fixed();
		image = new Gtk.Image();
		imageBox.put(image, 0, 0);
		imageEventBox.add(imageBox);
		imageAlignment.add(imageEventBox);
		box.add(imageAlignment);	

		imageEventBox.enter_notify_event.connect((event) => {
			event.window.set_cursor (
                new Gdk.Cursor.from_name (Gdk.Display.get_default(), "hand2")
            );
            return false;
		});
		imageEventBox.button_release_event.connect(() => {
			openMedia();
			return false;
		});

		this.titleAlignment = new Gtk.Alignment (0,0,1,1);
        this.titleAlignment.top_padding = 6;
        this.titleAlignment.right_padding = 6;
        this.titleAlignment.bottom_padding = 0;
        this.titleAlignment.left_padding = 6;

		titleLabel = new Gtk.Label("");
		titleLabel.set_markup(wrapInTags(post.title));
		titleLabel.set_line_wrap(true);
		titleLabel.set_justify(Gtk.Justification.LEFT);
		titleLabel.set_halign(Gtk.Align.START);
		titleAlignment.add(titleLabel);
		box.add(titleAlignment);

		if (post.taggedUsers.length() != 0)
		{
			usersOnPhoto = new List<Gtk.Popover>();
			foreach (TaggedUser userInPhoto in post.taggedUsers)
			{
				Gtk.Box tmpBox = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 0);
				imageBox.put(tmpBox, (int)(userInPhoto.x * IMAGE_SIZE), (int)(userInPhoto.y * IMAGE_SIZE));

				//Gtk.Popover userPopover = new Gtk.Popover(tmpBox);
				Gtk.Button userPopover = new Gtk.Button.with_label(userInPhoto.user.username);
				//userPopover.add(new Gtk.Label(userInPhoto.user.username));
				//userPopover.set_modal(false);
				//this.usersOnPhoto.append(userPopover);
				tmpBox.add(userPopover);

			}
		}

		if (post.location != null)
		{
			this.locationEventBox = new Gtk.EventBox();
			loadLocation(post.location);
		}

		likeToolbar = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);

		

        this.likeAlignment = new Gtk.Alignment (0,0,0,0);
        this.likeAlignment.top_padding = 6;
        this.likeAlignment.right_padding = 6;
        this.likeAlignment.bottom_padding = (post.commentsCount == 0) ? 6 : 0;
        this.likeAlignment.left_padding = 6;

        Pixbuf currentLikePixbuf = (post.didILikeThis? likePixbuf : dislikePixbuf);

        currentLikePixbuf = currentLikePixbuf.scale_simple(LIKE_SIZE, LIKE_SIZE, Gdk.InterpType.BILINEAR);
        likeImage = new Gtk.Image.from_pixbuf(currentLikePixbuf);
        likeBox = new Gtk.EventBox();
        likeBox.add(likeImage);
        likeAlignment.add(likeBox);
		likeToolbar.pack_start(likeAlignment, false, true);

		likeBox.enter_notify_event.connect((event) => {
			onLikeHover(event);
			return false;
		});

		likeBox.leave_notify_event.connect((event) => {
			onLikeHoverOut(event);
			return false;
		});

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
			likesText = "<a href=\"getLikes\">" + post.likesCount.to_string() + " likes.</a>";

		likesLabel = new Gtk.Label("");
		likesLabel.set_markup(likesText);	

		likeToolbar.add(likesLabel);

		box.add(likeToolbar);
		commentList = new CommentsList();
		if (post.commentsCount != 0)
		{
			this.commentsAlignment = new Gtk.Alignment (1,1,1,1);
	        this.commentsAlignment.top_padding = 3;
	        this.commentsAlignment.right_padding = 6;
	        this.commentsAlignment.bottom_padding = 3;
	        this.commentsAlignment.left_padding = 6;

	        this.commentList.set_halign(Gtk.Align.START);

			if(post.commentsCount !=  post.comments.length())
				commentList.addMoreButton(post.commentsCount);
			foreach(Comment comment in post.comments)
				commentList.prepend(comment, false);

			commentsAlignment.add(commentList);
			//commentsList.
			box.pack_end(commentsAlignment, false, false);
		}
	}	

	public void openMedia()
	{
		MediaWindow mediaWindow = new MediaWindow(post.media.url, post.type == PhotoStream.MediaType.VIDEO);
		mediaWindow.show_all ();
	}

	public int switchLike()
	{
		likeBox.button_release_event.disconnect(callback);

		int64 beforeLikes = post.likesCount;

		string response; 
		if (!post.didILikeThis) // if not liked, then like
		{
			response = likeMedia(post.id);
			this.post.likesCount += 1;
		}
		else // dislike
		{
			response = dislikeMedia(post.id);
			this.post.likesCount -= 1;
		}

		post.didILikeThis = !post.didILikeThis;

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
        likeImage.set_from_pixbuf(likePixbuf);

        if (beforeLikes != post.likes.length())
        	likesText = post.likesCount.to_string() + " likes.";
        else if (this.post.likesCount != 1) // if only self liked this
        	likesText = "<a href=\"@" + PhotoStream.App.selfUser.username + "\">" + PhotoStream.App.selfUser.username + "</a>, " + likesText;
        else
        	likesText = "<a href=\"@" + PhotoStream.App.selfUser.username + "\">" + PhotoStream.App.selfUser.username + "</a>";

        likesLabel.set_markup(likesText);

		likeBox.button_release_event.connect(callback);

		this.show_all();
		return 0;
	}
	public bool callback()
	{
		new Thread<int>("", switchLike);
		return false;
	}

	public void loadAvatar()
	{
		var avatarFileName = PhotoStream.App.CACHE_AVATARS + getFileName(post.postedUser.profilePicture);
		File file = File.new_for_path(avatarFileName);
        if (!file.query_exists()) // avatar not downloaded, download
        	downloadFile(post.postedUser.profilePicture, avatarFileName);

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

    public void loadLocation(Location location)
    {
    	this.post.location = location;
    	if (!locationEventBox.is_ancestor(box))
    	{
    		this.locationAlignment = new Gtk.Alignment (0,0,0,1);
	        this.locationAlignment.top_padding = 6;
	        this.locationAlignment.right_padding = 4;
	        this.locationAlignment.bottom_padding = 0;
	        this.locationAlignment.left_padding = 6;

			this.locationBox = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 0);
			this.locationAlignment.add(locationBox);
			this.locationEventBox.add(locationAlignment);

			try 
	        {
	        	locationPixbuf = new Pixbuf.from_file(PhotoStream.App.CACHE_IMAGES + "location.png");
	        }	
	        catch (Error e)
	        {
	        	GLib.error("Something wrong with file loading.\n");
	        }

	        locationPixbuf = locationPixbuf.scale_simple(LOCATION_SIZE, LOCATION_SIZE, Gdk.InterpType.BILINEAR);
	        locationImage = new Gtk.Image.from_pixbuf(locationPixbuf);
	        locationBox.add(locationImage);


        	locationLabel = new Gtk.Label(post.location.name);


	        locationBox.add(locationLabel);

	        box.add(locationEventBox);

        }
        else
        	locationLabel.set_text(post.location.name);

        locationEventBox.enter_notify_event.connect((event) => {
			event.window.set_cursor (
                new Gdk.Cursor.from_name (Gdk.Display.get_default(), "hand2")
            );
            return false;
		});

        this.show_all();
    }

    private void onLikeHover(EventCrossing event)
    {
    	event.window.set_cursor (
            new Gdk.Cursor.from_name (Gdk.Display.get_default(), "hand2")
        );

        Pixbuf currentLikePixbuf = (!post.didILikeThis? likePixbuf : dislikePixbuf);

        currentLikePixbuf = currentLikePixbuf.scale_simple(LIKE_SIZE, LIKE_SIZE, Gdk.InterpType.BILINEAR);
        likeImage.set_from_pixbuf(currentLikePixbuf);
    }
    private void onLikeHoverOut(EventCrossing event)
    {
    	Pixbuf currentLikePixbuf = (post.didILikeThis? likePixbuf : dislikePixbuf);

        currentLikePixbuf = currentLikePixbuf.scale_simple(LIKE_SIZE, LIKE_SIZE, Gdk.InterpType.BILINEAR);
        likeImage.set_from_pixbuf(currentLikePixbuf);
    }

}