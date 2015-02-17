using Gst;

public class PhotoStream.Widgets.MediaWindow: Gtk.Window
{
	public Gtk.Box windowBox;
	public Gtk.Image image;
	public Gtk.EventBox eventBox;

	public Gtk.DrawingArea drawingArea;
	public Pipeline pipeline;
	public Element src;
	public Element videoSink;
	public Element audioSink;
	public Element decode;
	public Element videoConvert;
	public Element audioConvert;
	public bool video;
	public bool videoPlaying = false;
	public bool finishedPlaying = false;

	public MediaWindow(string fileName, bool video)
	{
		this.set_resizable(false);
		eventBox = new Gtk.EventBox();
		windowBox = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);

		eventBox.add(windowBox);
		this.add(eventBox);

		this.eventBox.set_events(Gdk.EventMask.BUTTON_RELEASE_MASK);		

		this.video = video;

		if (video)
			loadVideo(fileName);
		else
		{
			image = new Gtk.Image.from_file(PhotoStream.App.CACHE_URL + getFileName(fileName));
			windowBox.add(image);

			this.eventBox.button_release_event.connect((event) => {
	        	if (event.button == Gdk.BUTTON_SECONDARY)
	        		saveCallback(fileName);

	        	return false;
	        });
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
        this.videoSink = ElementFactory.make ("gdkpixbufsink", "videoSink");
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

        this.pipeline.get_bus().add_watch(0, (bus, message) => {
        	if (message.type == MessageType.EOS)
        	{
        		finishedPlaying = true;
        		this.pipeline.set_state(State.READY);
        		return true;
        	}
			GLib.Value videoValue = GLib.Value(typeof(Gdk.Pixbuf));
			Gdk.Pixbuf videoPixbuf;
			videoSink.get_property("last-pixbuf", ref videoValue);
			videoPixbuf = videoValue as Gdk.Pixbuf;

			this.image.set_from_pixbuf(videoPixbuf);			
			return true;
        });
        this.image = new Gtk.Image();
        windowBox.add(image);
        this.show_all();

        this.eventBox.button_release_event.connect((event) => {
        	if (event.button == Gdk.BUTTON_PRIMARY)
        		switchVideoPlayback();
        	else if (event.button == Gdk.BUTTON_SECONDARY)
        		saveCallback(fileName);

        	return false;
        });

        this.pipeline.set_state (State.PLAYING); 
        videoPlaying = true;       
	}

	private void saveCallback(string fileName)
	{
		string titleString = "Save %s ...".printf(video ? "video" : "image");
		var menu = new Gtk.Menu();
        menu.attach_to_widget(this, null);

        var saveImageItem = new Gtk.MenuItem.with_label(titleString);
        menu.add(saveImageItem);

        saveImageItem.activate.connect (() => {
        	var fileChooser = new Gtk.FileChooserDialog(titleString, this,
                                  Gtk.FileChooserAction.SAVE,
                                  "Cancel", Gtk.ResponseType.CANCEL,
                                  "Save", Gtk.ResponseType.ACCEPT);

        	Gtk.FileFilter filter = new Gtk.FileFilter ();
			filter.set_filter_name(!video ? "JPG" : "MP4");
			filter.add_pattern(!video ? "*.jpg" : "*.mp4");
			fileChooser.add_filter(filter);

	        if (fileChooser.run () == Gtk.ResponseType.ACCEPT)
        	{
        		File origin = File.new_for_path(PhotoStream.App.CACHE_URL + getFileName(fileName));
        		File destination = File.new_for_path(fileChooser.get_filename());
        		try
        		{
        			origin.copy(destination, GLib.FileCopyFlags.OVERWRITE);
        		}
        		catch (Error e)
        		{
        			error("Something wrong with file writing: %s.", e.message);
        		}
        	}

        	fileChooser.destroy (); 
        });

        menu.popup(null, null, null, Gdk.BUTTON_SECONDARY, Gtk.get_current_event_time());
        menu.show_all();
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
			return ;
		}
		else
		{
			stdout.printf ("  It has video type '%s', loading.\n", new_pad_type);
			linkPads(new_pad, videoSinkPad, new_pad_type);
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

	public void switchVideoPlayback()
	{
		if (finishedPlaying)
		{			
			this.pipeline.set_state(State.PLAYING);
			finishedPlaying = false;
		}
		if (videoPlaying == true)
		{
			this.pipeline.set_state(State.PAUSED);
		}
		else
		{			
			this.pipeline.set_state(State.PLAYING);
		}

		videoPlaying = !videoPlaying;
	}

    protected override void destroy () 
    {
    	if (video)
    		this.pipeline.set_state (State.READY);
    }
}