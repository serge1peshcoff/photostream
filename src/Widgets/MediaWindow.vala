using Gst;

public class PhotoStream.Widgets.MediaWindow: Granite.Widgets.LightWindow
{
	public Gtk.Box windowBox;
	public Gtk.Image image;
	public Gtk.DrawingArea drawingArea;
	public Element src;
	public Element sink;
	public ulong xid;
	public string fileName;

	public MediaWindow(string fileName, bool video)
	{
		windowBox = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
		this.add(windowBox);

		if (video)
		{
			string downloadName = PhotoStream.App.CACHE_URL + getFileName(fileName);
			downloadFile(fileName, downloadName);
			this.drawingArea = new Gtk.DrawingArea ();

			// Create the elements:
			//Gst.Element source = Gst.ElementFactory.make ("videotestsrc", "source");
			//Gst.Element sink = Gst.ElementFactory.make ("autovideosink", "sink");

			// Create the empty pipeline:
			Gst.Element pipeline = Gst.parse_launch("playbin uri=file://" + downloadName);
			pipeline.set_state (Gst.State.PLAYING);

	
		}
		else
		{
			image = new Gtk.Image.from_file(PhotoStream.App.CACHE_URL + fileName);
			windowBox.add(image);
		}
	}

	public string getFileName(string url)
    {
        var indexStart = url.last_index_of("/") + 1;
        return url.substring(indexStart, url.length - indexStart);
    }
}