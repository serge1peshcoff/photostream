using Gtk;
using PhotoStream.Utils;
public class PhotoStream.Widgets.UserWindowBox : Gtk.Box
{
	public Box userInfoBox;
	public Image avatar;
	public Label userName;

	public Box userCountsBox;
	public Label mediaCount;
	public Label followsCount;
	public Label followersCount;

	public Gtk.ScrolledWindow feedWindow;
	public PhotoStream.Widgets.PostList userFeed;

	public UserWindowBox()
	{
		GLib.Object (orientation: Gtk.Orientation.VERTICAL);

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
		this.userInfoBox.add(avatar);
		this.userInfoBox.add(userName);
		this.pack_start(userInfoBox, false, true);

		this.userCountsBox.pack_start(mediaCount, false, true);
		this.userCountsBox.add(followsCount);
		this.userCountsBox.add(followersCount);
		this.add(userCountsBox);

		this.feedWindow.add_with_viewport(userFeed);
		this.pack_end(feedWindow, true, true);
	}
	public void load(User user)
	{
		string avatarFileName = PhotoStream.App.CACHE_AVATARS + getFileName(user.profilePicture);
		File file = File.new_for_path(avatarFileName);
        if (!file.query_exists()) // avatar not downloaded, download
        	downloadFile(user.profilePicture, avatarFileName);

        this.avatar.set_from_file(avatarFileName);

		this.userName.set_label(user.username);
		this.mediaCount.set_label(user.mediaCount.to_string() + "media");
		this.followsCount.set_label(user.followed.to_string() + "follows");
		this.followersCount.set_label(user.followers.to_string() + "followers");
	}
	public void loadFeed(List<MediaInfo> feedList)
	{
		userFeed.clear();        
        foreach (MediaInfo post in feedList)
            if (!userFeed.contains(post))
                userFeed.prepend(post);

        new Thread<int>("", loadImages);
        this.show_all();
	}

	public int loadImages()
    {
        foreach (PostBox postBox in userFeed.boxes)
        {
            if (postBox.avatar.pixbuf == null) //avatar not loaded, that means image was not added to PostList
            {        
                postBox.loadAvatar();
                postBox.loadImage();
            }
            else
                print("already loaded.\n");
        }
        return 0;
    }

	public string getFileName(string url)
    {
        var indexStart = url.last_index_of("/") + 1;
        return url.substring(indexStart, url.length - indexStart);
    }
}