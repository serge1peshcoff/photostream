using PhotoStream.Utils;
using Gtk;
using Gdk;

public class PhotoStream.Widgets.PostList : Gtk.Box
{
	public GLib.List<PostBox> boxes;
	public GLib.List<Pixbuf> srcImages;
	public Gtk.Button moreButton;
	public Gtk.Alignment moreButtonAlignment;
	public Gtk.Button moreButtonImages;
	public Gtk.Alignment moreButtonImagesAlignment;
	public string olderFeedLink;
	public int IMAGE_SIZE;

	public Gtk.ScrolledWindow postsWindow;
	public Gtk.ScrolledWindow imagesWindow;

	public Gtk.Stack stack;
	public Gtk.ListBox postList;
	public Gtk.Box imagesBox;
	public Gtk.Grid imagesGrid;

	private Gtk.Window parentWindow;
	private int prevWidth;
	private bool cannotViewImages;

	public PostList(bool cannotViewImages = false)
	{
		this.cannotViewImages = cannotViewImages;
		this.set_orientation(Gtk.Orientation.VERTICAL);
		IMAGE_SIZE = 200;

		this.stack = new Gtk.Stack();
		this.postList = new Gtk.ListBox();

		boxes = new GLib.List<PostBox>();	
		srcImages = new GLib.List<Pixbuf>();

		this.moreButton = new Gtk.Button.with_label("Load more...");	

		this.moreButtonAlignment = new Gtk.Alignment (1,0,1,0);
        this.moreButtonAlignment.add(moreButton);
        postList.prepend(this.moreButtonAlignment);

        this.moreButtonImages = new Gtk.Button.with_label("Load more...");	

		this.moreButtonImagesAlignment = new Gtk.Alignment (1,0,1,0);
        this.moreButtonImagesAlignment.add(moreButtonImages);

		this.postList.set_selection_mode (Gtk.SelectionMode.NONE);
		this.postList.activate_on_single_click = false;

		this.imagesBox = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
		this.imagesGrid = new Gtk.Grid();
		this.imagesGrid.set_row_spacing(5);
		this.imagesGrid.set_column_spacing(5);
		this.imagesBox.add(imagesGrid);
		this.imagesBox.pack_end(moreButtonImagesAlignment, false, false);

		this.postsWindow = new Gtk.ScrolledWindow(null, null);
		this.postsWindow.set_policy(Gtk.PolicyType.NEVER, Gtk.PolicyType.ALWAYS);
		this.postsWindow.add_with_viewport(postList);

		this.imagesWindow = new Gtk.ScrolledWindow(null, null);
		this.imagesWindow.set_policy(Gtk.PolicyType.NEVER, Gtk.PolicyType.ALWAYS);
		this.imagesWindow.add_with_viewport(imagesBox);
		this.stack.add_named(postsWindow, "posts");
		if (!cannotViewImages)
		{
			this.stack.add_named(imagesWindow,  "images");
			if (loadPostsOrImages())
				this.stack.set_visible_child_name("images");
		}
		this.pack_start(stack, true, true);	
		this.show_all();	
	}

	public void deleteMoreButton()
	{
		if (this.moreButtonAlignment.is_ancestor(this.postList))
		{
			Gtk.ListBoxRow buttonRow = (Gtk.ListBoxRow)this.postList.get_children().last().data;
			buttonRow.remove(moreButtonAlignment);
		}
	}
	public bool contains(MediaInfo post)
	{
		foreach(PostBox box in boxes)
			if(box.post.id == post.id)
				return true;

		return false;
	}
	public void append(MediaInfo post)
	{
		Gtk.Separator separator = new Gtk.Separator (Gtk.Orientation.HORIZONTAL);
		postList.prepend(separator);
		PostBox box = new PostBox(post);

		var listBoxRow = new Gtk.ListBoxRow();
		//listBoxRow.set_selectable(false);
		listBoxRow.add(box);
		postList.prepend(listBoxRow);
		boxes.prepend(box);	

		connectImageLoadingHandler(box);
	}

	public new void prepend(MediaInfo post)
	{
		Gtk.Separator separator = new Gtk.Separator (Gtk.Orientation.HORIZONTAL);
		postList.insert (separator, (int) this.postList.get_children().length () - 1);
		PostBox box = new PostBox(post);

		var listBoxRow = new Gtk.ListBoxRow();
		//listBoxRow.set_selectable(false);
		listBoxRow.add(box);
		postList.insert (listBoxRow, (int) this.postList.get_children().length () - 1);
		boxes.append(box);	

		connectImageLoadingHandler(box);
	}

	private void connectImageLoadingHandler(PostBox box)
	{
		if (!cannotViewImages)
		{
			box.imageLoaded.connect((post) => {
				var imageFileName = PhotoStream.App.CACHE_URL + getFileName(post.type == PhotoStream.MediaType.VIDEO 
																			? post.media.previewUrl 
																			: post.media.url);
				int index = boxes.index(box);

		        try 
		        {
		        	srcImages.append(new Pixbuf.from_file(imageFileName));
		        }	
		        catch (Error e)
		        {
		        	GLib.error("Something wrong with file loading.\n");
		        }	        			

		        EventBox tmpEventBox = new Gtk.EventBox();			
				Image tmpImage = new Image();
				tmpEventBox.add(tmpImage);

				tmpEventBox.set_events(Gdk.EventMask.BUTTON_RELEASE_MASK);
				tmpEventBox.set_events(Gdk.EventMask.ENTER_NOTIFY_MASK);
		        tmpEventBox.set_events(Gdk.EventMask.LEAVE_NOTIFY_MASK);

		        Gtk.Widget toplevel = this.get_toplevel();
				parentWindow = (Gtk.Window)toplevel;
				parentWindow.add_events(Gdk.EventType.CONFIGURE);
				prevWidth = parentWindow.get_allocated_width();

				var app = (PhotoStream.App)parentWindow.get_application();

		        tmpEventBox.enter_notify_event.connect((event) => {
					event.window.set_cursor (
		                new Gdk.Cursor.from_name (Gdk.Display.get_default(), "hand2")
		            );
		            return false;
				});

				tmpEventBox.button_release_event.connect((event) => {				
					app.loadPost(post.id);
					return false;
				});

				/*this.parentWindow.size_allocate.connect((allocation) => {
					if (allocation.width != prevWidth)
					{
						print("%d\n", allocation.width);
						prevWidth = allocation.width;					
						resizeAllImages(allocation.width);
					}
				});*/

				imagesGrid.attach(tmpEventBox, index % 3, index / 3, 1, 1);

				loadImageToFeed(index, box.post.type == PhotoStream.MediaType.VIDEO);
				if (loadPostsOrImages())
					this.stack.set_visible_child_name("images");
				this.show_all();
			});	
		}
	}


	public void resizeAllImages(int windowSize)
	{

		IMAGE_SIZE = (windowSize - 10) / 3 - 1;
		foreach (PostBox box in boxes)
		{
			int index = boxes.index(box);
			if (imagesGrid.get_child_at(index % 3, index / 3) == null)
				continue;

			loadImageToFeed(index, box.post.type == PhotoStream.MediaType.VIDEO);	
			this.show_all();
		}
	}

	private void loadImageToFeed(int index, bool isVideo)
	{
		Pixbuf imagePixbuf; 
        Pixbuf videoPixbuf;
		try 
        {
        	imagePixbuf = srcImages.nth(index).data.scale_simple(IMAGE_SIZE, IMAGE_SIZE, Gdk.InterpType.BILINEAR);
        	if (isVideo)
        	{	        		
        		videoPixbuf = new Pixbuf.from_file(PhotoStream.App.CACHE_IMAGES + "video.png");
        		videoPixbuf = videoPixbuf.scale_simple(IMAGE_SIZE, IMAGE_SIZE, Gdk.InterpType.BILINEAR);
        		videoPixbuf.composite(imagePixbuf, 0, 0, 
        									IMAGE_SIZE, IMAGE_SIZE, 0, 0, 1.0, 1.0, Gdk.InterpType.BILINEAR, 255);
        	}
        }	
        catch (Error e)
        {
        	GLib.error("Something wrong with file loading.\n");
        }	
		

		Gtk.Bin container = (Bin)imagesGrid.get_child_at(index % 3, index / 3);
		Gtk.Image image = (Image) container.get_child();
		image.set_from_pixbuf(imagePixbuf);
	}

	public void clear()
	{
		foreach (var child in this.postList.get_children())
			if (!(((Gtk.ListBoxRow) child).get_child() is Gtk.Alignment)) // we don't want to remove "add more" button, right?
				this.postList.remove(child);

		this.boxes = new List<PostBox>();

		if (!this.moreButtonAlignment.is_ancestor(this.postList) && this.olderFeedLink != "")
			postList.prepend(this.moreButtonAlignment);	

		foreach (var child in this.imagesGrid.get_children())
			this.imagesGrid.remove(child);

		this.srcImages = new GLib.List<Pixbuf>();

		this.postsWindow.get_vadjustment().set_value(0);
		this.imagesWindow.get_vadjustment().set_value(0);	

		this.show_all();
	}
}