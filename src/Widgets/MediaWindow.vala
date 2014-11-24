using Gst;

public class PhotoStream.Widgets.MediaWindow: Granite.Widgets.LightWindow
{
	public Gtk.Box windowBox;
	public Gtk.Image image;

	public Gtk.DrawingArea drawingArea;
	public Pipeline pipeline;
	public Element src;
	public Element sink;

	public Gdk.Pixbuf videoPixbuf;
	public ulong xid;

	public MediaWindow(string fileName, bool video)
	{
		windowBox = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
		this.add(windowBox);


		if (video)
			loadVideo(fileName);
		else
		{
			image = new Gtk.Image.from_file(PhotoStream.App.CACHE_URL + getFileName(fileName));
			windowBox.add(image);
		}
	}

	public void loadVideo(string fileName)
	{
		string downloadFileName = PhotoStream.App.CACHE_URL + getFileName(fileName);
		downloadFile(fileName, downloadFileName);

		/*this.pipeline = new Pipeline ("mypipeline");
		this.src = ElementFactory.make ("filesrc", "video");
		src.set("location", downloadFileName);
        this.sink = ElementFactory.make ("gdkpixbufsink", "sink");
        this.pipeline.add_many (this.src, this.sink);
        this.src.link (this.sink);

        this.pipeline.set_state (State.PLAYING);

        this.videoPixbuf = sink.get("last-pixbuf") as Gdk.Pixbuf;*/
	}

	public string getFileName(string url)
    {
        var indexStart = url.last_index_of("/") + 1;
        return url.substring(indexStart, url.length - indexStart);
    }
}