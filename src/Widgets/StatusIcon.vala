public class PhotoStream.Widgets.StatusIcon: Gtk.StatusIcon
{
	public StatusIcon()
	{
		this.has_tooltip = true;
		this.set_tooltip_text("PhotoStream");
	}
}