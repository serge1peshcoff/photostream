using Gst;

public class PhotoStream.Widgets.MediaWindow: Granite.Widgets.LightWindow
{
	public Gtk.Box windowBox;
	public Gtk.Image image;

	public Gtk.DrawingArea drawingArea;
	public Pipeline pipeline;
	public Element src;
	public Element videoSink;
	public Element audioSink;
	public Element decode;
	public Element videoConvert;
	public Element audioConvert;
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
		try
		{
			downloadFile(fileName, downloadFileName);
		}
		catch (Error e)
		{
			error("Video cannot be loaded.");
		}

		this.pipeline = new Pipeline ("mypipeline");
		this.src = ElementFactory.make ("filesrc", "video");
		src.set("location", downloadFileName);
		this.decode = ElementFactory.make ("decodebin", "decode");
        this.videoConvert = ElementFactory.make ("videoconvert", "videoConvert");
        this.audioConvert = ElementFactory.make ("audioconvert", "audioConvert");
        this.videoSink = ElementFactory.make ("xvimagesink", "videoSink");
        this.audioSink = ElementFactory.make ("autoaudiosink", "audioSink");
        this.pipeline.add_many (this.src, this.decode, this.videoConvert, this.audioConvert, 
        												this.audioSink, this.videoSink);

        if (this.src == null)
        	error("Gstreamer element init error 1");
        if (this.decode == null)
        	error("Gstreamer element init error 2");
        if (this.videoSink == null)
        	error("Gstreamer element init error 3");
        if (this.videoConvert == null)
        	error("Gstreamer element init error 4");
        if (this.audioSink == null)
        	error("Gstreamer element init error 5");
        if (this.audioConvert == null)
        	error("Gstreamer element init error 6");
        

        if (!this.src.link (this.decode))
        	error("GStreamer linking problems.");
        if (!this.videoConvert.link (this.videoSink))
        	error("GStreamer linking problems 2.");
        if (!this.audioConvert.link (this.audioSink))
        	error("GStreamer linking problems 3.");

        this.decode.pad_added.connect(padAddedHandler);              

        this.drawingArea = new Gtk.DrawingArea();
        this.windowBox.pack_start(drawingArea, true, true, 0);

        this.drawingArea.realize.connect(() => {
        	this.xid = (uint*)(((Gdk.X11.Window) this.drawingArea.get_window()).get_xid ());      	
        }); 

        this.pipeline.get_bus().add_watch(0, (bus, message) => {
        	if(Gst.Video.is_video_overlay_prepare_window_handle_message (message)) 
        	{
				Gst.Video.Overlay overlay = message.src as Gst.Video.Overlay;
				assert (overlay != null);

				overlay.set_window_handle (this.xid);
				this.show_all();
			}
			return true;
        });

        this.pipeline.set_state (State.PLAYING);        
	}

	private void padAddedHandler(Gst.Element src, Gst.Pad new_pad)
	{
		Gst.Pad videoSinkPad = this.videoConvert.get_static_pad ("sink");
		Gst.Pad audioSinkPad = this.audioConvert.get_static_pad ("sink");
		stdout.printf ("Received new pad '%s' from '%s':\n", new_pad.name, src.name);

		Gst.Caps new_pad_caps = new_pad.query_caps (null);
		weak Gst.Structure new_pad_struct = new_pad_caps.get_structure (0);
		string new_pad_type = new_pad_struct.get_name ();
		if (new_pad_type.has_prefix ("audio/x-raw")) // if this is audio
		{
			stdout.printf ("  It has audio type '%s', loading.\n", new_pad_type);
			linkPads(new_pad, audioSinkPad, new_pad_type);
			//if (videoSinkPad.is_linked())
			//	playVideo();
			return ;
		}
		else
		{
			stdout.printf ("  It has video type '%s', loading.\n", new_pad_type);
			linkPads(new_pad, videoSinkPad, new_pad_type);
			//if (audioSinkPad.is_linked())
			//	playVideo();
			return ;
		}
	}
	private void linkPads(Gst.Pad source, Gst.Pad destination, string new_pad_type)
	{
		// Attempt the link:
		Gst.PadLinkReturn ret = source.link (destination);
		if (ret != Gst.PadLinkReturn.OK) {
			stdout.printf ("  Type is '%s' but link failed.\n", new_pad_type);
		} else {
			stdout.printf ("  Link succeeded (type '%s').\n", new_pad_type);
		}
	}

	public string getFileName(string url)
    {
        var indexStart = url.last_index_of("/") + 1;
        return url.substring(indexStart, url.length - indexStart);
    }
}