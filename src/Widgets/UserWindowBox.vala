using Gtk;
using PhotoStream.Utils;
public class PhotoStream.Widgets.UserWindowBox : Gtk.Box
{
	public Box box;
	public Viewport viewport;

	public Box userInfoBox;
	public Image avatar;
	public Label userName;

	public Box userCountsBox;
	public Label mediaCount;
	public Label followsCount;
	public Label followersCount;

	public Gtk.ScrolledWindow feedWindow;
	public PhotoStream.Widgets.PostList userFeed;

	public Box errorBox;
	public Label privateLabel;
	public Button followButton;

	public bool isPrivate = false;
	public string id;
	public string username;

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

		this.userInfoBox.pack_start(avatar, false, true);
		this.userInfoBox.add(userName);
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
		
		this.followButton = new Button.with_label("Follow...");
		this.errorBox.add(followButton);

		this.viewport = new Viewport(null, null);
		this.feedWindow.add(viewport);
	}
	public void load(User user)
	{
		string avatarFileName = PhotoStream.App.CACHE_AVATARS + getFileName(user.profilePicture);
		File file = File.new_for_path(avatarFileName);
        if (!file.query_exists()) // avatar not downloaded, download
        	downloadFile(user.profilePicture, avatarFileName);

        this.avatar.set_from_file(avatarFileName);

		this.userName.set_label(user.username + " (" + user.fullName + ")");
		this.mediaCount.set_label(user.mediaCount.to_string() + "media");
		this.followsCount.set_label(user.followed.to_string() + "follows");
		this.followersCount.set_label(user.followers.to_string() + "followers");
	}
	public void loadFeed(List<MediaInfo> feedList)
	{
		isPrivate = false;
		clearPrivate();

		if(!this.box.is_ancestor(viewport))
			viewport.add(box);

		userFeed.clear();   
		if (this.userFeed.olderFeedLink != "")
			userFeed.addMoreButton();

        foreach (MediaInfo post in feedList)
            userFeed.prepend(post);

        new Thread<int>("", loadImages);
	        
    	this.show_all();
	}
	public void loadPrivate(string id, string username)
	{
		isPrivate = true;
		this.id = id;
		this.username = username;
		clearFeed();

		if(!this.errorBox.is_ancestor(viewport))
			viewport.add(errorBox);
		this.show_all();
	}
	private void clearFeed()
	{
		if(this.box.is_ancestor(viewport))
			viewport.remove(box); // feedWindow -> GtkViewport -> box, that's why
	}
	public void clearPrivate()
	{
		if(this.errorBox.is_ancestor(viewport))
			viewport.remove(errorBox);
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