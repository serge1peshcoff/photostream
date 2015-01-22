using PhotoStream.Utils;
using Gdk;

public class PhotoStream.Widgets.PostBox : Gtk.EventBox
{
	public Gtk.Box box;

	public Gtk.Alignment avatarAlignment;
	public Gtk.Alignment userNameAlignment;
	public Gtk.Alignment dateAlignment;
	public Gtk.Alignment imageAlignment;
	public Gtk.Alignment titleAlignment;
	public Gtk.Alignment locationAlignment;
	public Gtk.Alignment likeAlignment;
	public Gtk.Alignment commentsAlignment;

	public Pixbuf likePixbuf;
	public Pixbuf dislikePixbuf;

	public Gtk.Box userToolbar;
	public Gtk.Label userNameLabel;
	public PhotoStream.Widgets.DateLabel dateLabel;
	public Gtk.Label titleLabel;
	public Gtk.Label likesLabel;
	public PhotoStream.Widgets.Image avatar;
	public Gtk.EventBox avatarBox;
	public Gtk.EventBox imageEventBox;
	public Gtk.Fixed imageBox;
	public PhotoStream.Widgets.Image image;
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
	public const int LIKE_SIZE = 20;
	public const int LOCATION_SIZE = 20;

	public bool windowOpened = false;

	public CommentsList commentList;

	public MediaInfo post;

	public signal void imageLoaded(MediaInfo post);

	public PostBox(MediaInfo post)
	{
		box = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
		this.add(box);

		set_events(Gdk.EventMask.BUTTON_RELEASE_MASK);
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
		avatar = new PhotoStream.Widgets.Image(AVATAR_SIZE);
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

		this.dateAlignment = new Gtk.Alignment (0,0,0,1);
        this.dateAlignment.top_padding = 6;
        this.dateAlignment.right_padding = 6;
        this.dateAlignment.bottom_padding = 0;
        this.dateAlignment.left_padding = 6;

		dateLabel = new PhotoStream.Widgets.DateLabel(post.creationTime);	

		userNameAlignment.add(userNameLabel);	
		dateAlignment.add(dateLabel);	
		userToolbar.add(userNameAlignment);
		userToolbar.pack_end(dateAlignment, false, true);
		box.pack_start(userToolbar, false, true);

		this.imageAlignment = new Gtk.Alignment (0.5f,0,0,1);
        this.imageAlignment.top_padding = 6;
        this.imageAlignment.right_padding = 6;
        this.imageAlignment.bottom_padding = 0;
        this.imageAlignment.left_padding = 6;	

        imageEventBox = new Gtk.EventBox();
		imageBox = new Gtk.Fixed();
		image = new PhotoStream.Widgets.Image(IMAGE_SIZE);
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
			if (!windowOpened)
				openMedia();
			return false;
		});

		this.titleAlignment = new Gtk.Alignment (0,0,1,0);
        this.titleAlignment.top_padding = 6;
        this.titleAlignment.right_padding = 6;
        this.titleAlignment.bottom_padding = 0;
        this.titleAlignment.left_padding = 6;

		titleLabel = new Gtk.Label("");
		titleLabel.set_markup(wrapInTags(post.title));
		titleLabel.set_line_wrap(true);
		titleLabel.wrap_mode = Pango.WrapMode.WORD_CHAR;
		titleLabel.set_justify(Gtk.Justification.LEFT);
		titleLabel.xalign = 0;

		titleAlignment.add(titleLabel);
		box.add(titleAlignment);

		if (post.taggedUsers.length() != 0)
		{
			usersOnPhoto = new List<Gtk.Popover>();
			foreach (TaggedUser userInPhoto in post.taggedUsers)
			{
				//Gtk.Box tmpBox = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 0);
				//imageBox.put(tmpBox, (int)(userInPhoto.x * IMAGE_SIZE), (int)(userInPhoto.y * IMAGE_SIZE));

				//Gtk.Popover userPopover = new Gtk.Popover(tmpBox);
				//Gtk.Button userPopover = new Gtk.Button.with_label(userInPhoto.user.username);
				//userPopover.add(new Gtk.Label(userInPhoto.user.username));
				//userPopover.set_modal(false);
				//this.usersOnPhoto.append(userPopover);
				//tmpBox.add(userPopover);

			}
		}

		if (post.location != null)
		{
			this.locationEventBox = new Gtk.EventBox();
			this.locationEventBox.set_events (Gdk.EventMask.BUTTON_RELEASE_MASK);
			this.locationEventBox.set_events(Gdk.EventMask.ENTER_NOTIFY_MASK);
	        this.locationEventBox.set_events(Gdk.EventMask.LEAVE_NOTIFY_MASK);
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
		else if (post.likesCount != 0)
			likesText = "<a href=\"getLikes\">" + post.likesCount.to_string() + " likes.</a>";
		else
			likesText = post.likesCount.to_string() + " likes.";

		likesLabel = new Gtk.Label("");
		likesLabel.set_markup(likesText);	

		likeToolbar.add(likesLabel);

		box.add(likeToolbar);
		commentList = new CommentsList();

		this.commentsAlignment = new Gtk.Alignment (1,1,1,1);
        this.commentsAlignment.top_padding = 3;
        this.commentsAlignment.right_padding = 6;
        this.commentsAlignment.bottom_padding = 3;
        this.commentsAlignment.left_padding = 6;

        this.commentList.set_halign(Gtk.Align.FILL);
        this.commentList.postId = post.id;

		if(post.commentsCount !=  post.comments.length())
			commentList.addMoreButton(post.commentsCount);
		foreach(Comment comment in post.comments)
			commentList.prepend(comment);

		commentsAlignment.add(commentList);
		box.pack_end(commentsAlignment, true, true);

		this.show_all();

		this.realize.connect(() => {
			this.connectHandlers();
		});		
	}	

	private void connectHandlers()
	{
		Gtk.Window parentWindow = (Gtk.Window)(this.get_toplevel().get_toplevel());
		PhotoStream.App app = (PhotoStream.App)parentWindow.get_application();

		this.titleLabel.activate_link.connect(app.handleUris);
        this.likesLabel.activate_link.connect((uri) => {
            if (uri == "getLikes")
            {
                new Thread<int>("", () => {
                    app.loadUsers(this.post.id, "likes");
                    return 0;
                });                
                return true;
            }
            else
                return app.handleUris(uri);
        });
        foreach(CommentBox commentBox in this.commentList.comments)
            commentBox.textLabel.activate_link.connect(app.handleUris);

        // for not crashing when using loadMissingLocation
        string tmpLocationId = (this.post.location == null) ? "0" : this.post.location.id; 
        bool locationMissing = false;

        if (this.post.location != null 
            && this.post.location.latitude == 0 
            && this.post.location.longitude == 0 
            && this.post.location.name == ""
            && this.post.location.id != "0") // sometimes location contains only ID, for such cases
        {
            locationMissing = true;
            new Thread<int>("", () => {
                loadMissingLocation(this, this.post.location.id);
                return 0;
            });
        }
        if (this.commentList.loadMoreButton != null)
            this.commentList.loadMoreButton.activate_link.connect(() => { 
                new Thread<int>("", () => {
                    app.loadComments(this.post.id);
                    return 0;
                });
                return true;
            });

        this.avatarBox.button_release_event.connect((event) =>{
            if (event.button == Gdk.BUTTON_PRIMARY)
            {
                new Thread<int>("", () => {
                    app.loadUser(this.post.postedUser.id, this.post.postedUser);
                    return 0;
                });
            }
            else
            {
                var menu = new Gtk.Menu();
                menu.attach_to_widget(this.avatarBox, null);

                var bulkDownloadItem = new Gtk.MenuItem.with_label ("Download all posts...");
                menu.add(bulkDownloadItem);

                var blockUserItem = new Gtk.MenuItem.with_label ("Block user...");
                menu.add(blockUserItem);

                bulkDownloadItem.activate.connect (() => {
                    var window = new PhotoStream.BulkDownloadWindow(this.post.postedUser.id);
                    window.show_all();
                });

                menu.popup(null, null, null, Gdk.BUTTON_SECONDARY, Gtk.get_current_event_time());
                menu.show_all();
            }
            return false;
        });
        if (this.locationEventBox != null)
        {
            this.locationEventBox.button_release_event.connect(() =>{
                new Thread<int>("", () => {
                    if (!locationMissing && this.post.location.id == "0") // only coordinates available
                        Idle.add(() => {
                            app.openLocationMap(this.post.location); 
                            return false;
                        });                                           
                    else if (locationMissing && tmpLocationId != "0")
                        app.loadLocation(tmpLocationId);
                    else
                        app.loadLocation(this.post.location.id);                                    
                    return 0;
                });
                
                return false;
            });
        }
	}


	private int loadMissingLocation(PostBox postBox, string id)
    {
        string response = getLocationInfo(id);
        Location location;
        try
        {
            location = parseLocation(response);
        }
        catch (Error e) 
        {
            error("Something wrong with parsing: " + e.message + ".\n");
        }
        Idle.add(() => {
            postBox.loadLocation(location);
            return false;
        });
        return 0;
    }

	public void openMedia()
	{
		MediaWindow mediaWindow = new MediaWindow(post.media.url, post.type == PhotoStream.MediaType.VIDEO);
		mediaWindow.show_all ();
		windowOpened = true;
		mediaWindow.destroy.connect(() => {
			windowOpened = false;
		});
	}

	public int switchLike()
	{
		likeBox.button_release_event.disconnect(callback);

		int64 beforeLikes = post.likesCount;

		string response; 
		if (!post.didILikeThis) // if not liked, then like
			this.post.likesCount += 1;
		else // dislike
			this.post.likesCount -= 1;

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

        if (beforeLikes != post.likes.length() && post.likesCount != 0)
			likesText = "<a href=\"getLikes\">" + post.likesCount.to_string() + " likes.</a>";
		else if (beforeLikes != post.likes.length() && post.likesCount == 0)
			likesText = post.likesCount.to_string() + " likes.";
        else if (this.post.likesCount != 1) // if only self liked this
        	likesText = "<a href=\"@" + PhotoStream.App.selfUser.username + "\">" + PhotoStream.App.selfUser.username + "</a>, " + likesText;
        else
        	likesText = "<a href=\"@" + PhotoStream.App.selfUser.username + "\">" + PhotoStream.App.selfUser.username + "</a>";

        likesLabel.set_markup(likesText);
        this.show_all();

        // we toggled didILikeThis before, to remember
		if (post.didILikeThis) // if not liked, then like
			response = likeMedia(post.id);
		else // dislike
			response = dislikeMedia(post.id);

		likeBox.button_release_event.connect(callback);

		return 0;
	}
	public bool callback()
	{
		new Thread<int>("", switchLike);
		return false;
	}

	public void loadAvatar()
	{
		avatar.download(post.postedUser.profilePicture, PhotoStream.App.CACHE_IMAGES + "avatar-mask.png", true);
	}

	public void loadImage()
	{
		image.download(post.type == PhotoStream.MediaType.VIDEO ? post.media.previewUrl: post.media.url, 
					post.type == PhotoStream.MediaType.VIDEO ? PhotoStream.App.CACHE_IMAGES + "video.png" : "");
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

        Pixbuf currentLikePixbuf = likePixbuf;

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