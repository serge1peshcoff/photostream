using PhotoStream.Utils;

public class PhotoStream.Widgets.HashTagBox : Gtk.EventBox
{
	public Gtk.Box box;

	public Gtk.Alignment hashtagNameAlignment;
	public Gtk.Alignment mediaCountAlignment;

	public Gtk.Label hashtagNameLabel;
	public Gtk.Label mediaCountLabel;

	public Tag tag;

	public HashTagBox(Tag tag)
	{
		this.tag = tag;

		box = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 0);

		this.hashtagNameAlignment = new Gtk.Alignment (0,0,1,1);
        this.hashtagNameAlignment.top_padding = 2;
        this.hashtagNameAlignment.right_padding = 6;
        this.hashtagNameAlignment.bottom_padding = 2;
        this.hashtagNameAlignment.left_padding = 6;

		hashtagNameLabel = new Gtk.Label("");
		hashtagNameLabel.set_markup((wrapInTags("#" + tag.tag)));

		this.hashtagNameAlignment.add(hashtagNameLabel);
		box.pack_start(hashtagNameAlignment, false, true);

		this.mediaCountAlignment = new Gtk.Alignment (0,0,1,1);
        this.mediaCountAlignment.top_padding = 2;
        this.mediaCountAlignment.right_padding = 6;
        this.mediaCountAlignment.bottom_padding = 2;
        this.mediaCountAlignment.left_padding = 6;

		mediaCountLabel = new Gtk.Label("");
		mediaCountLabel.set_markup("<b>" + tag.mediaCount.to_string() + "</b> posts.");

		this.mediaCountAlignment.add(mediaCountLabel);
		box.pack_end(mediaCountAlignment, false, true);
		this.add(box);
	}
}