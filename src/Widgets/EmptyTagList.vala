public class PhotoStream.Widgets.EmptyTagList: Gtk.Box
{
	public Gtk.Label privateLabel;
	public EmptyTagList()
	{
		this.set_orientation(Gtk.Orientation.VERTICAL);
		this.privateLabel = new Gtk.Label("");
		this.privateLabel.set_markup("<b>No tags to show.</b>");
		this.pack_start(privateLabel, true, true);
	}	
}