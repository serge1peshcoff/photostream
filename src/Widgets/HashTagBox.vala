using PhotoStream.Utils;
using Gdk;

public class PhotoStream.Widgets.HashTagBox : Gtk.EventBox
{
	public Gtk.Box box;

	public Gtk.Label hashtagNameLabel;
	public Gtk.Label mediaCountLabel;

	public Tag tag;

	public HashTagBox(Tag tag)
	{
		this.tag = tag;

		box = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 0);

		hashtagNameLabel = new Gtk.Label("");
		hashtagNameLabel.set_markup((wrapInTags("#" + tag.tag)));

		box.add(hashtagNameLabel);

		mediaCountLabel = new Gtk.Label("");
		mediaCountLabel.set_markup("<b>" + tag.mediaCount.to_string() + "</b> posts.");

		box.add(mediaCountLabel);
		this.add(box);
	}
}