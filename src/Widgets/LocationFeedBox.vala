using Gtk;
using Gdk;
using PhotoStream.Utils;

public class PhotoStream.Widgets.LocationFeedBox : Gtk.Box
{
	public Gtk.Box locationInfoBox;
	public Gtk.Label locationTitleLabel;
	public Gtk.Image locationImage;
	public PostList locationFeed;
	public Gtk.Alignment locationTitleAlignment;
	public Gtk.Alignment locationImageAlignment;

	public Gtk.LinkButton openLocationButton;

	public const int LOCATION_SIZE = 25;

	public Location location;

	public LocationFeedBox()
	{
		GLib.Object (orientation: Gtk.Orientation.VERTICAL);

		locationInfoBox = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 0);

		this.locationTitleAlignment = new Gtk.Alignment (0,0,0,1);
        this.locationTitleAlignment.top_padding = 10;
        this.locationTitleAlignment.right_padding = 10;
        this.locationTitleAlignment.bottom_padding = 10;
        this.locationTitleAlignment.left_padding = 10;

        this.locationImageAlignment = new Gtk.Alignment (0,0,0,1);
        this.locationImageAlignment.top_padding = 10;
        this.locationImageAlignment.right_padding = 10;
        this.locationImageAlignment.bottom_padding = 10;
        this.locationImageAlignment.left_padding = 10;	

        Pixbuf locationPixbuf;
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
        
        locationImageAlignment.add(locationImage);	

		this.locationTitleLabel = new Gtk.Label("");
		this.locationTitleAlignment.add(locationTitleLabel);

		this.locationInfoBox.add(locationImageAlignment);
		this.locationInfoBox.add(locationTitleAlignment);

		this.pack_start(locationInfoBox, false, true);

		this.locationFeed = new PostList();
		this.pack_end(locationFeed, true, true);
	}
	public void loadLocation(Location location)
	{
		this.location = location;
		this.locationTitleLabel.set_markup("<span size=\"large\"><b>" + location.name + "</b></span>");
	}

	public void loadFeed(List<MediaInfo> posts)
	{

		foreach (MediaInfo post in posts)
		{
			post.location = location; // if there is only ID available in feed
			locationFeed.prepend(post);
		}

		foreach (PostBox box in locationFeed.boxes)
		{
			box.loadAvatar();
			box.loadImage();
		}

	}

	public void loadOlderFeed (List<MediaInfo> posts)
	{
		foreach (MediaInfo post in posts)
			locationFeed.prepend(post);

		foreach (PostBox box in locationFeed.boxes)
			if (box.avatar.pixbuf == null)
			{
				box.loadAvatar();
				box.loadImage();
			}
		this.show_all();
	}
}