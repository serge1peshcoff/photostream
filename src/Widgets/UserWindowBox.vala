using Gtk;
using Gdk;
using PhotoStream.Utils;
public class PhotoStream.Widgets.UserWindowBox : Gtk.Box
{
	public Box box;
	public Viewport viewport;

	public Gtk.Alignment avatarAlignment;

	public EventBox userInfoEventBox;
	public Box userInfoBox;

	public Box avatarBox;
	public Pixbuf avatarPixbuf;
	public Image avatar;
	public Label userName;

	public Gtk.Alignment relationshipAlignment;
	public Gtk.EventBox relationshipBox;
	public Gtk.Image relationshipImage;

	public Pixbuf followingPixbuf;
	public Pixbuf notFollowingPixbuf;
	public Pixbuf unfollowPixbuf;
	public Pixbuf followPixbuf;
	public Pixbuf requestedPixbuf;

	public Box userCountsBox;
	public Box mediaCountBox;	
	public Box followsCountBox;
	public Box followersCountBox;
	public Alignment mediaCountBoxAlignment;
	public Alignment followsCountBoxAlignment;
	public Alignment followersCountBoxAlignment;

	public Label mediaCount;
	public Label followsCount;
	public Label followersCount;
	

	public Label mediaCountText;
	public Label followsCountText;
	public Label followersCountText;

	public EventBox followsCountEventBox;
	public EventBox followersCountEventBox;

	public Gtk.ScrolledWindow feedWindow;
	public PhotoStream.Widgets.PostList userFeed;

	public Box errorBox;
	public Label privateLabel;

	public bool isPrivate = false;
	private bool relationshipHandlersSet = false;

	public User user;

	public const int RELATIONSHIP_WIDTH = 100;
	public const int RELATIONSHIP_HEIGHT = 20;

	public UserWindowBox()
	{
		GLib.Object (orientation: Gtk.Orientation.VERTICAL);

		box = new Box(Gtk.Orientation.VERTICAL, 0);

		this.userInfoBox = new Box(Gtk.Orientation.HORIZONTAL, 0);
		this.avatarBox = new Box(Gtk.Orientation.HORIZONTAL, 0);
		this.avatar = new Image();
		this.userName = new Label("username");

		try 
		{
			this.followingPixbuf = new Pixbuf.from_file(PhotoStream.App.CACHE_IMAGES + "following.png");
			this.notFollowingPixbuf = new Pixbuf.from_file(PhotoStream.App.CACHE_IMAGES + "not-following.png");
			this.unfollowPixbuf = new Pixbuf.from_file(PhotoStream.App.CACHE_IMAGES + "unfollow.png");
			this.followPixbuf = new Pixbuf.from_file(PhotoStream.App.CACHE_IMAGES + "follow.png");
			this.requestedPixbuf = new Pixbuf.from_file(PhotoStream.App.CACHE_IMAGES + "requested.png");
		}
		catch(Error e)
		{
			GLib.error("Something wrong with file loading.");
		}

		this.userCountsBox = new Box(Gtk.Orientation.HORIZONTAL, 0);
		this.mediaCount = new Label("0");
		this.followsCount = new Label("0");
		this.followersCount = new Label("0");

		this.mediaCountText = new Label("");
		this.followsCountText = new Label("");
		this.followersCountText = new Label("");

		this.mediaCountText.set_markup("media");
		this.followsCountText.set_markup("follows");
		this.followersCountText.set_markup("followers");

		this.followsCountEventBox = new EventBox();
		this.followersCountEventBox = new EventBox();

		this.mediaCountBox = new Box(Gtk.Orientation.VERTICAL, 0);
		this.mediaCountBox.add(mediaCount);
		this.mediaCountBox.add(mediaCountText);
		this.mediaCountBoxAlignment = new Gtk.Alignment (0,0,0,1);
        this.mediaCountBoxAlignment.top_padding = 3;
        this.mediaCountBoxAlignment.right_padding = 6;
        this.mediaCountBoxAlignment.bottom_padding = 0;
        this.mediaCountBoxAlignment.left_padding = 6;
        this.mediaCountBoxAlignment.add(mediaCountBox);	

		this.followsCountBox = new Box(Gtk.Orientation.VERTICAL, 0);
		this.followsCountBox.add(followsCount);
		this.followsCountBox.add(followsCountText);
		this.followsCountBoxAlignment = new Gtk.Alignment (0,0,0,1);
        this.followsCountBoxAlignment.top_padding = 3;
        this.followsCountBoxAlignment.right_padding = 6;
        this.followsCountBoxAlignment.bottom_padding = 0;
        this.followsCountBoxAlignment.left_padding = 6;
        this.followsCountBoxAlignment.add(followsCountBox);

		this.followersCountBox = new Box(Gtk.Orientation.VERTICAL, 0);
		this.followersCountBox.add(followersCount);
		this.followersCountBox.add(followersCountText);
		this.followersCountBoxAlignment = new Gtk.Alignment (0,0,0,1);
        this.followersCountBoxAlignment.top_padding = 3;
        this.followersCountBoxAlignment.right_padding = 6;
        this.followersCountBoxAlignment.bottom_padding = 0;
        this.followersCountBoxAlignment.left_padding = 6;
        this.followersCountBoxAlignment.add(followersCountBox);

        this.followsCountEventBox.set_events (Gdk.EventMask.BUTTON_RELEASE_MASK);
		this.followsCountEventBox.set_events(Gdk.EventMask.ENTER_NOTIFY_MASK);
        this.followsCountEventBox.set_events(Gdk.EventMask.LEAVE_NOTIFY_MASK);
        this.followersCountEventBox.set_events (Gdk.EventMask.BUTTON_RELEASE_MASK);
		this.followersCountEventBox.set_events(Gdk.EventMask.ENTER_NOTIFY_MASK);
        this.followersCountEventBox.set_events(Gdk.EventMask.LEAVE_NOTIFY_MASK);

		this.feedWindow = new ScrolledWindow(null, null);
		this.userFeed = new PostList();

		this.avatarAlignment = new Gtk.Alignment (0,0,0,1);
        this.avatarAlignment.top_padding = 6;
        this.avatarAlignment.right_padding = 6;
        this.avatarAlignment.bottom_padding = 0;
        this.avatarAlignment.left_padding = 6;	

        this.avatarBox.add(avatar);
        this.avatarAlignment.add(avatarBox);
		this.userInfoBox.pack_start(avatarAlignment, false, false);
		this.userInfoBox.add(userName);

		this.relationshipAlignment = new Gtk.Alignment (1,0,1,1);
        this.relationshipAlignment.top_padding = 6;
        this.relationshipAlignment.right_padding = 6;
        this.relationshipAlignment.bottom_padding = 0;
        this.relationshipAlignment.left_padding = 6;

		this.relationshipBox = new Gtk.EventBox();
		this.relationshipBox.set_events (Gdk.EventMask.BUTTON_RELEASE_MASK);
		this.relationshipBox.set_events(Gdk.EventMask.ENTER_NOTIFY_MASK);
        this.relationshipBox.set_events(Gdk.EventMask.LEAVE_NOTIFY_MASK);
		this.relationshipImage = new Gtk.Image();
		this.relationshipBox.add(relationshipImage);
		this.relationshipAlignment.add(relationshipBox);
		this.userInfoBox.pack_end(relationshipAlignment, false, false);

		this.userInfoEventBox = new EventBox();
		this.userInfoEventBox.add(userInfoBox);
		this.box.pack_start(userInfoEventBox, false, true);

		this.userInfoEventBox.set_events(Gdk.EventMask.BUTTON_RELEASE_MASK);
		this.userInfoEventBox.button_release_event.connect((event) => {
			if (event.button == Gdk.BUTTON_SECONDARY)
				userMenuPopup();			
			return false;
		});

		this.followsCountEventBox.add(followsCountBoxAlignment);
		this.followersCountEventBox.add(followersCountBoxAlignment);
		this.userCountsBox.pack_start(mediaCountBoxAlignment, false, true);
		this.userCountsBox.add(followsCountEventBox);
		this.userCountsBox.add(followersCountEventBox);
		this.box.add(userCountsBox);

		var separator = new Gtk.Separator(Gtk.Orientation.HORIZONTAL);
		this.box.add(separator);

		this.followsCountEventBox.enter_notify_event.connect((event) => {
			onCountsHover(event);
			return false;
		});
		this.followersCountEventBox.enter_notify_event.connect((event) => {
			onCountsHover(event);
			return false;
		});
		

		this.errorBox = new Box(Gtk.Orientation.VERTICAL, 0);
		this.privateLabel = new Label("");
		this.privateLabel.set_markup("<b>This user is private.</b>");
		this.errorBox.pack_start(privateLabel, true, true);

		this.viewport = new Viewport(null, null);
		

		this.box.pack_end(userFeed, true, true);
		this.viewport.add(box);
		this.feedWindow.add(viewport);
		this.pack_start(feedWindow, true, true);
	}
	public void load(User user)
	{
		this.user = user;
		string avatarFileName = PhotoStream.App.CACHE_AVATARS + getFileName(user.profilePicture);
		File file = File.new_for_path(avatarFileName);
        if (!file.query_exists()) // avatar not downloaded, download
        	try
        	{
        		downloadFile(user.profilePicture, avatarFileName);
        	}
        	catch (Error e)
        	{
        		error("Can't load avatar.");
        	}

        this.avatar.set_from_file(avatarFileName);

        string userNameString;
        if (user.fullName == "")
        	userNameString = "<i>@" +  GLib.Markup.escape_text(user.username) + "</i>";
        else
        	userNameString = "<span size=\"large\"><b>" + GLib.Markup.escape_text(user.fullName)
        					 + "</b></span> (<i>@" + GLib.Markup.escape_text(user.username) + "</i>)";

		this.userName.set_markup(userNameString);

		this.mediaCount.set_markup("<span size=\"large\"><b>" + (user.mediaCount == -1 ? "?" : user.mediaCount.to_string()) + "</b></span>");
		this.followsCount.set_markup("<span size=\"large\"><b>" + (user.followed == -1 ? "?" : user.followed.to_string()) + "</b></span>");
		this.followersCount.set_markup("<span size=\"large\"><b>" + (user.followers == -1 ? "?" : user.followers.to_string()) + "</b></span>");

		this.feedWindow.get_vadjustment().set_value(0);

		this.loadRelationship();
		
	}

	public void loadRelationship()
	{
		if (user.id != PhotoStream.App.selfUser.id)
		{
			Pixbuf relationshipPixbuf;
        	switch (user.relationship.outcoming)
        	{
        		case "follows":
        			relationshipPixbuf = followingPixbuf;
        			break;
        		case "none":
        			relationshipPixbuf = notFollowingPixbuf;
        			break;
        		case "requested":
        			relationshipPixbuf = requestedPixbuf;
        			break;
        		default:
        			error("Should've not reached here.");
        	}

	        relationshipPixbuf = relationshipPixbuf.scale_simple(RELATIONSHIP_WIDTH, RELATIONSHIP_HEIGHT, Gdk.InterpType.BILINEAR);
	        relationshipImage.set_from_pixbuf(relationshipPixbuf);

	        if (!relationshipHandlersSet)
	        {
		        relationshipBox.enter_notify_event.connect((event) => {
		        	onHover(event);
		        	return false;
		        });
		        relationshipBox.leave_notify_event.connect((event) => {
		        	onHoverOut(event);
		        	return false;
		        });

		        relationshipBox.button_release_event.connect(() => {
		        	confirmChangingRelationship();
		        	return false;
		        });
		    }
		    relationshipHandlersSet = true;
	    }
	    else
	    	relationshipImage.clear();
	}
	public void loadFeed(List<MediaInfo> feedList)
	{
		isPrivate = false;
		clearPrivate();

		if(!this.userFeed.is_ancestor(box))
			box.add(userFeed);

		userFeed.clear();   

        foreach (MediaInfo post in feedList)
            userFeed.prepend(post);

        if (this.userFeed.olderFeedLink == "")
            this.userFeed.deleteMoreButton();

        new Thread<int>("", loadImages);
	        
    	this.show_all();
	}
	public void loadPrivate()
	{
		isPrivate = true;
		clearFeed();

		if(!this.errorBox.is_ancestor(box))
			box.add(errorBox);
		this.show_all();
	}
	private void clearFeed()
	{
		if(this.userFeed.is_ancestor(box))
			box.remove(userFeed); // feedWindow -> GtkViewport -> box, that's why
	}
	public void clearPrivate()
	{
		if(this.errorBox.is_ancestor(box))
			box.remove(errorBox);
	}
	public void loadOlderFeed(List<MediaInfo> feedList)
	{      
        foreach (MediaInfo post in feedList)
            if (!userFeed.contains(post))
                userFeed.prepend(post);

        if (this.userFeed.olderFeedLink == "")
            this.userFeed.deleteMoreButton();

        new Thread<int>("", loadImages);
        this.show_all();
	}

	public int loadImages()
    {
        foreach (PostBox postBox in userFeed.boxes)
        {
            if (postBox.avatar.pixbuf == null) // avatar not loaded, that means image was not added to PostList
            {        
                postBox.loadAvatar();
                postBox.loadImage();
            }
        }
        return 0;
    }

    private void onCountsHover(EventCrossing event)
    {
    	if (!this.isPrivate)
	    	event.window.set_cursor (    		
	            new Gdk.Cursor.from_name (Gdk.Display.get_default(), "hand2")
	        );
    }

    private void onHover(EventCrossing event)
    {
    	event.window.set_cursor (
            new Gdk.Cursor.from_name (Gdk.Display.get_default(), "hand2")
        );

		Pixbuf relationshipPixbuf;
		if (user.relationship.outcoming == "follows" || user.relationship.outcoming == "requested")
			relationshipPixbuf = unfollowPixbuf;
		else if (user.relationship.outcoming == "none")
			relationshipPixbuf = followPixbuf;
		else
			error("Should've not reached here.");

        relationshipPixbuf = relationshipPixbuf.scale_simple(RELATIONSHIP_WIDTH, RELATIONSHIP_HEIGHT, Gdk.InterpType.BILINEAR);
        relationshipImage.set_from_pixbuf(relationshipPixbuf);
    }
    private void onHoverOut(EventCrossing event)
    {
    	Pixbuf relationshipPixbuf;
		if (user.relationship.outcoming == "follows")
			relationshipPixbuf = followingPixbuf;
		else if (user.relationship.outcoming == "none")
			relationshipPixbuf = notFollowingPixbuf;
		else if (user.relationship.outcoming == "requested")
			relationshipPixbuf = requestedPixbuf;
		else
			error("Should've not reached here.");

        relationshipPixbuf = relationshipPixbuf.scale_simple(RELATIONSHIP_WIDTH, RELATIONSHIP_HEIGHT, Gdk.InterpType.BILINEAR);
        relationshipImage.set_from_pixbuf(relationshipPixbuf);
    }

    private void confirmChangingRelationship()
    {
    	string action;
		switch (user.relationship.outcoming)
		{
			case "follows":
			case "requested":
        		action = "unfollow";
        		break;
    		case "none":
    			action = "follow";
    			break;
    		default:
    			error("Should've not reached here.");
		}

		if (action == "unfollow") // make sure user want to unfollow
		{
			Gtk.MessageDialog msg = new Gtk.MessageDialog (null, Gtk.DialogFlags.MODAL, 
													Gtk.MessageType.QUESTION, Gtk.ButtonsType.OK_CANCEL, 
													"Are you sure you want to unfollow @" + user.username + "?");
			msg.response.connect ((response_id) => {
				bool allowedToUnfollow = (response_id == Gtk.ResponseType.OK);

				msg.destroy();

				if (!allowedToUnfollow)
					return;
				else
					new Thread<int>("", () => {
		        		changeRelationshipReally(action);
		        		return 0;
		        	});				
			});
			msg.show ();
		}
		else // following
			new Thread<int>("", () => {
        		changeRelationshipReally(action);
        		return 0;
        	});

    }

    private void changeRelationshipReally(string action)
    {
		// user agreed, continue unfollowing
		// or not unfollowing but following.

		string relationshipInfo = relationshipAction(this.user.id, action);
        Relationship relationship = null;

        try
        {
            relationship = parseRelationship(relationshipInfo);      
            user.relationship = relationship;
        }
        catch (Error e) // wrong token
        {
            error("Something wrong with parsing: " + e.message + ".\n");
        }

        Idle.add(() => {
        	this.loadRelationship();
        	return false;
        });
        
    }
    private void userMenuPopup()
    {
    	var menu = new Gtk.Menu();
    	menu.attach_to_widget(userInfoEventBox, null);

    	var bulkDownloadItem = new Gtk.MenuItem.with_label ("Download all posts...");
		menu.add(bulkDownloadItem);

		var blockUserItem = new Gtk.MenuItem.with_label ("Block user...");
		menu.add(blockUserItem);

		bulkDownloadItem.activate.connect (() => {
			var window = new PhotoStream.BulkDownloadWindow(this.user.id);
			window.show_all();
		});


		menu.popup(null, null, null, Gdk.BUTTON_SECONDARY, Gtk.get_current_event_time());
		menu.show_all();
    }
}