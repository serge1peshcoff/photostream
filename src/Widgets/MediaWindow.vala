using Gst;

public class PhotoStream.Widgets.MediaWindow: Granite.Widgets.LightWindow
{
	public Gtk.Box windowBox;
	public Gtk.Image image;

	public Gtk.DrawingArea drawingArea;
	public Pipeline pipeline;
	public Element src;
	public Element sink;
	public Element decode;
	public uint* xid;

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

		this.pipeline = new Pipeline ("mypipeline");
		this.src = ElementFactory.make ("filesrc", "video");
		src.set("location", downloadFileName);
		this.decode = ElementFactory.make ("decodebin", "decode");
        this.sink = ElementFactory.make ("autoaudiosink", "sink");
        this.pipeline.add_many (this.src, this.decode,  this.sink);

        if (this.src == null)
        	error("Gstreamer element init error 1");
        if (this.decode == null)
        	error("Gstreamer element init error 2");
        if (this.sink == null)
        	error("Gstreamer element init error 3");

        if (!this.src.link (this.decode))
        	error("GStreamer linking problems.");
        if (!this.decode.link (this.sink))
        	error("GStreamer linking problems 2.");
        

        this.drawingArea = new Gtk.DrawingArea();
        this.add(drawingArea);
        this.drawingArea.realize.connect(() => {
        	this.xid = (uint*)(((Gdk.X11.Window) this.drawingArea.get_window()).get_xid ());

        	var xoverlay = this.sink as Gst.Video.Overlay;
	        xoverlay.set_window_handle (this.xid);
	        this.pipeline.set_state (State.PLAYING);
        });       
	}

	public string getFileName(string url)
    {
        var indexStart = url.last_index_of("/") + 1;
        return url.substring(indexStart, url.length - indexStart);
    }
}