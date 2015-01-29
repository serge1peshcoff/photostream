using Gdk;

public class PhotoStream.Widgets.Image: Gtk.Box
{
	public Gtk.Image image;
	public Gtk.Spinner spinner;
	public bool isLoaded = false;
	public int size;

	public Image(int size)
	{
		this.size = size;

		this.image = new Gtk.Image();
		this.set_size_request(size, size);

		this.spinner = new Gtk.Spinner();
		this.spinner.set_halign(Gtk.Align.CENTER);	
		this.spinner.set_valign(Gtk.Align.CENTER);			
		this.pack_start(spinner, true, true);
		this.spinner.start();
		this.show_all();
	}

	public void download(string downloadUrl, string maskImage = "", bool isAvatar = false)
	{
		string imageFileName;
		if (!isAvatar)
			imageFileName = PhotoStream.App.CACHE_URL + getFileName(downloadUrl);
		else
			imageFileName = PhotoStream.App.CACHE_AVATARS + getFileName(downloadUrl);

		File file = File.new_for_path(imageFileName);
        if (!file.query_exists()) // avatar not downloaded, download
        	try
        	{
        		downloadFile(downloadUrl, imageFileName);
        	}
        	catch (Error e)
        	{
        		return; // not loading avatar, to fix.
        	}

        Idle.add(() => {
        	Pixbuf imagePixbuf; 
	        try 
	        {
	        	imagePixbuf = new Pixbuf.from_file(imageFileName);
	        }	
	        catch (Error e)
	        {
	        	GLib.error("Something wrong with file loading.\n");
	        }
			imagePixbuf = imagePixbuf.scale_simple(size, size, Gdk.InterpType.BILINEAR);
			

			if (maskImage != "")
			{
				Pixbuf imageMaskPixbuf;
				try 
		        {
		        	imageMaskPixbuf = new Pixbuf.from_file(PhotoStream.App.CACHE_IMAGES + "avatar-mask.png");
		        }	
		        catch (Error e)
		        {
		        	GLib.error("Something wrong with file loading.\n");
		        }
		        imageMaskPixbuf = imageMaskPixbuf.scale_simple(size, size, Gdk.InterpType.BILINEAR);
		        imageMaskPixbuf.composite(imagePixbuf, 0, 0, 
	        						size, size, 0, 0, 1.0, 1.0, Gdk.InterpType.BILINEAR, 255);
			}			

			image.set_from_pixbuf(imagePixbuf);	


			if (spinner.is_ancestor(this))
			{
				this.remove(spinner);
				this.pack_start(image, true, true);
			}			
			this.show_all();
			this.isLoaded = true;	
			return false;
        });
	}
}