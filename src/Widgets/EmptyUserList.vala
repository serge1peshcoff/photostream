public class PhotoStream.Widgets.EmptyUserList: Gtk.Box
{
	public Gtk.Label privateLabel;
	public EmptyUserList()
	{
		this.set_orientation(Gtk.Orientation.VERTICAL);
		this.privateLabel = new Gtk.Label("");
		this.privateLabel.set_markup("<b>No users to show.</b>");
		this.pack_start(privateLabel, true, true);
	}	
}