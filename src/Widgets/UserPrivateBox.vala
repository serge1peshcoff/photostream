public class PhotoStream.Widgets.UserPrivateBox: Gtk.Box
{
	public Gtk.Label privateLabel;
	
	public UserPrivateBox()
	{
		this.set_orientation(Gtk.Orientation.VERTICAL);
		this.privateLabel = new Gtk.Label("");
		this.privateLabel.set_markup("<b>This user is private.</b>");
		this.pack_start(privateLabel, true, true);
	}	
}