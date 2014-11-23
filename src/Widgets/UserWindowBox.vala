using Gtk;
using Gdk;
using PhotoStream.Utils;
public class PhotoStream.Widgets.UserWindowBox : Gtk.Box
{
	public Box box;
	public Viewport viewport;

	public Gtk.Alignment avatarAlignment;

	public Box userInfoBox;
	public Image avatar;
	public Label userName;

	public Gtk.EventBox relationshipBox;
	public Gtk.Image relationshipImage;

	public Box userCountsBox;
	public Label mediaCount;
	public Label followsCount;
	public Label followersCount;

	public Gtk.ScrolledWindow feedWindow;
	public PhotoStream.Widgets.PostList userFeed;

	public Box errorBox;
	public Label privateLabel;

	public bool isPrivate = false;

	public User user;

	public const int RELATIONSHIP_WIDTH = 100;
	public const int RELATIONSHIP_HEIGHT = 20;

	public UserWindowBox()
	{
		GLib.Object (orientation: Gtk.Orientation.VERTICAL);

		box = new Box(Gtk.Orientation.VERTICAL, 0);

		this.userInfoBox = new Box(Gtk.Orientation.HORIZONTAL, 0);
		this.avatar = new Image();
		this.userName = new Label("username");

		this.userCountsBox = new Box(Gtk.Orientation.HORIZONTAL, 0);
		this.mediaCount = new Label("0 media.");
		this.followsCount = new Label("0 follows.");
		this.followersCount = new Label("0 followers.");

		this.feedWindow = new ScrolledWindow(null, null);
		this.userFeed = new PostList();

		this.avatarAlignment = new Gtk.Alignment (0,0,0,1);
        this.avatarAlignment.top_padding = 6;
        this.avatarAlignment.right_padding = 6;
        this.avatarAlignment.bottom_padding = 0;
        this.avatarAlignment.left_padding = 6;	

        avatarAlignment.add(avatar);
		this.userInfoBox.pack_start(avatarAlignment, false, true);
		this.userInfoBox.add(userName);

		this.relationshipBox = new Gtk.EventBox();
		this.relationshipImage = new Gtk.Image();
		this.relationshipBox.add(relationshipImage);
		this.userInfoBox.add(relationshipBox);

		this.box.pack_start(userInfoBox, false, true);

		this.userCountsBox.pack_start(mediaCount, false, true);
		this.userCountsBox.add(followsCount);
		this.userCountsBox.add(followersCount);
		this.box.add(userCountsBox);

		this.box.pack_end(userFeed, true, true);
		this.pack_start(feedWindow, true, true);

		this.errorBox = new Box(Gtk.Orientation.VERTICAL, 0);
		this.privateLabel = new Label("");
		this.privateLabel.set_markup("<b>This user is private.</b>");
		this.errorBox.pack_start(privateLabel, true, true);

		this.viewport = new Viewport(null, null);
		this.feedWindow.add(viewport);

		this.viewport.add(box);
	}
	public void load(User user)
	{
		this.user = user;
		string avatarFileName = PhotoStream.App.CACHE_AVATARS + getFileName(user.profilePicture);
		File file = File.new_for_path(avatarFileName);
        if (!file.query_exists()) // avatar not downloaded, download
        	downloadFile(user.profilePicture, avatarFileName);

        this.avatar.set_from_file(avatarFileName);

        string userNameString;
        if (user.fullName == "")
        	userNameString = "@" +  user.username;
        else
        	userNameString = "<b>" + user.fullName + "</b> (@" + user.username + ")";

		this.userName.set_markup(userNameString);

		

		this.mediaCount.set_markup("<b>" + (user.mediaCount == 0 ? "?" : user.mediaCount.to_string()) + "</b>\nmedia");
		this.followsCount.set_markup("<b>" + (user.followed == 0 ? "?" : user.followed.to_string()) + "</b>\nfollows");
		this.followersCount.set_markup("<b>" + (user.followers == 0 ? "?" : user.followers.to_string()) + "</b>\nfollowers");

		if (user.id != PhotoStream.App.selfUser.id)
		{
			Pixbuf relationshipPixbuf;
			try 
	        {
	        	switch (user.relationship.outcoming)
	        	{
	        		case "follows":
	        			relationshipPixbuf = new Pixbuf.from_file(PhotoStream.App.CACHE_IMAGES + "following.png");
	        			break;
	        		default:
	        			relationshipPixbuf = new Pixbuf.from_file(PhotoStream.App.CACHE_IMAGES + "not-following.png");
	        			break;
	        	}
	        }	
	        catch (Error e)
	        {
	        	GLib.error("Something wrong with file loading.\n");
	        }


	        relationshipPixbuf = relationshipPixbuf.scale_simple(RELATIONSHIP_WIDTH, RELATIONSHIP_HEIGHT, Gdk.InterpType.BILINEAR);
	        relationshipImage.set_from_pixbuf(relationshipPixbuf);
	    }
	    else
	    	relationshipImage = new Gtk.Image();
	}
	public void loadFeed(List<MediaInfo> feedList)
	{
		isPrivate = false;
		clearPrivate();

		if(!this.userFeed.is_ancestor(box))
			box.add(userFeed);

		userFeed.clear();   
		if (this.userFeed.olderFeedLink != "")
			userFeed.addMoreButton();

        foreach (MediaInfo post in feedList)
            userFeed.prepend(post);

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

	public string getFileName(string url)
    {
        var indexStart = url.last_index_of("/") + 1;
        return url.substring(indexStart, url.length - indexStart);
    }
}