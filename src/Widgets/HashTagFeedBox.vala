using Gtk;
using Gdk;
using PhotoStream.Utils;

public class PhotoStream.Widgets.HashTagFeedBox : Gtk.Box
{
	public Gtk.Label hashtagTitleLabel;
	public PostList hashtagFeed;
	public Gtk.Alignment hashtagTitleAlignment;

	public Tag tag;

	public HashTagFeedBox()
	{
		GLib.Object (orientation: Gtk.Orientation.VERTICAL);

		this.hashtagTitleAlignment = new Gtk.Alignment (0,0,0,1);
        this.hashtagTitleAlignment.top_padding = 10;
        this.hashtagTitleAlignment.right_padding = 10;
        this.hashtagTitleAlignment.bottom_padding = 10;
        this.hashtagTitleAlignment.left_padding = 10;	

		this.hashtagTitleLabel = new Gtk.Label("");
		this.hashtagTitleAlignment.add(hashtagTitleLabel);
		this.add(hashtagTitleAlignment);

		var separator = new Gtk.Separator(Gtk.Orientation.HORIZONTAL);
        this.add(separator);

		this.hashtagFeed = new PostList();
		this.pack_end(hashtagFeed, true, true);
	}
	public void loadTag(Tag tag)
	{
		this.tag = tag;
		this.hashtagTitleLabel.set_markup("<span size=\"large\"><b>#" + tag.tag + "</b> (" + tag.mediaCount.to_string() + " media).</span>");
	}
}