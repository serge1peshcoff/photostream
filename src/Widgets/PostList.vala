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
	public Gtk.Box postsBox;
	public Gtk.Grid postList;
	public Gtk.Box imagesBox;
	public Gtk.Grid imagesGrid;

	private Gtk.Window parentWindow;
	private int prevWidth;
	private bool cannotViewImages;

	private int postsDisplayed = 0;

	public PostList(bool cannotViewImages = false)
	{
		this.cannotViewImages = cannotViewImages;
		this.set_orientation(Gtk.Orientation.VERTICAL);
		IMAGE_SIZE = 200;

		this.stack = new Gtk.Stack();
		this.postsBox = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
		this.postList = new Gtk.Grid();

		boxes = new GLib.List<PostBox>();	
		srcImages = new GLib.List<Pixbuf>();

		this.moreButton = new Gtk.Button.with_label("Load more...");	

		this.moreButtonAlignment = new Gtk.Alignment (1,0,1,0);
        this.moreButtonAlignment.add(moreButton);

        this.moreButtonImages = new Gtk.Button.with_label("Load more...");	

		this.moreButtonImagesAlignment = new Gtk.Alignment (1,0,1,0);
        this.moreButtonImagesAlignment.add(moreButtonImages);

		this.imagesBox = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
		this.imagesGrid = new Gtk.Grid();
		this.imagesGrid.set_row_spacing(5);
		this.imagesGrid.set_column_spacing(5);
		this.imagesBox.add(imagesGrid);
		this.imagesBox.pack_end(moreButtonImagesAlignment, false, false);

		this.postsBox.add(postList);

		this.postsWindow = new Gtk.ScrolledWindow(null, null);
		this.postsWindow.set_policy(Gtk.PolicyType.NEVER, Gtk.PolicyType.AUTOMATIC);
		this.postsWindow.add_with_viewport(postsBox);

		this.imagesWindow = new Gtk.ScrolledWindow(null, null);
		this.imagesWindow.set_policy(Gtk.PolicyType.NEVER, Gtk.PolicyType.AUTOMATIC);
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

		this.moreButton.clicked.connect(() => {
			new Thread<int>("", () => {
				loadOlderFeed();
				return 0;
			});
		});
		this.moreButtonImages.clicked.connect(() => {
			new Thread<int>("", () => {
				loadOlderFeed();
				return 0;
			});
		});
	}

	public void loadFeed(string response)
	{
		List<MediaInfo> feedPosts;
		try 
        {
            feedPosts = parseFeed(response);
            this.olderFeedLink = parsePagination(response);
        }
        catch (Error e) // wrong token
        {
        	error("Something wrong with parsing: %s.", e.message);
        }
        Idle.add(() => {
        	if (this.olderFeedLink != "")
        		addMoreButton();
        	loadFeedFromResponse(feedPosts);
        	this.postsWindow.set_policy(Gtk.PolicyType.NEVER, Gtk.PolicyType.AUTOMATIC);
        	this.show_all();
        	return false;
        });
        
	}

	private void loadFeedFromResponse(List<MediaInfo> posts)
	{
		this.clear();

		foreach (MediaInfo post in posts)
			this.prepend(post);

		new Thread<int>("", () => {
        	loadImages();
        	return 0;
        });
	}

	public void loadOlderFeed()
	{
		string response = getResponse(this.olderFeedLink);
        List<MediaInfo> feedList;

        try
        {
            feedList = parseFeed(response);
            this.olderFeedLink = parsePagination(response);
        }
        catch (Error e) 
        {
            error("Something wrong with parsing: " + e.message + ".\n");
        }

        Idle.add(() => {
            foreach (MediaInfo post in feedList)
	            if (!this.contains(post))
	                this.prepend(post);

	        if (this.olderFeedLink == "")
	            this.deleteMoreButton();

	        new Thread<int>("", () => {
	        	loadImages();
	        	return 0;
	        });
	        this.show_all();
            return false;
        });
	}

	public void loadImages()
    {
        foreach (PostBox postBox in this.boxes)
        {
            if (!postBox.avatar.isLoaded) // avatar not loaded, that means image was not added to PostList
            {        
                postBox.loadAvatar();
                postBox.loadImage();
            }
        }
    }

    public void addMoreButton()
	{
		if (!this.moreButtonAlignment.is_ancestor(this.postsBox))
			this.postsBox.pack_end(moreButtonAlignment, false, true);
	}
	public void deleteMoreButton()
	{
		this.postsBox.remove(moreButtonAlignment);
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
		postList.insert_row(0);
		Gtk.Separator separator = new Gtk.Separator (Gtk.Orientation.HORIZONTAL);
		postList.attach(separator, 0, 0, 1, 1);

		postsDisplayed++;

		postList.insert_row(0);
		PostBox box = new PostBox(post);
		postList.attach(box, 0, 0, 1, 1);
		boxes.prepend(box);	

		postsDisplayed++;

		connectImageLoadingHandler(box);

		this.show_all();
	}

	public new void prepend(MediaInfo post)
	{
		if (postsDisplayed != 0)
		{
			Gtk.Separator separator = new Gtk.Separator (Gtk.Orientation.HORIZONTAL);
			postList.attach(separator, 0, postsDisplayed, 1, 1);
		}

		postsDisplayed++;

		PostBox box = new PostBox(post);
		postList.attach(box, 0, postsDisplayed, 1, 1);
		boxes.append(box);	

		postsDisplayed++;

		connectImageLoadingHandler(box);

		this.show_all();
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
				Gtk.Image tmpImage = new Gtk.Image();
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

				this.parentWindow.size_allocate.connect((allocation) => {
					//if (allocation.width != prevWidth)
					//{
					//	print("%d\n", allocation.width);
					//	prevWidth = allocation.width;					
						resizeAllImages(allocation.width);
					//}
				});

				imagesGrid.attach(tmpEventBox, index % 3, index / 3, 1, 1);

				loadImageToFeed(index, box.post.type == PhotoStream.MediaType.VIDEO);
				if (loadPostsOrImages())
					this.stack.set_visible_child_name("images");
				this.imagesGrid.show_all();
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
		Gtk.Image image = (Gtk.Image) container.get_child();
		image.set_from_pixbuf(imagePixbuf);
	}

	public void clear()
	{
		foreach (var child in this.postList.get_children())
			this.postList.remove(child);

		this.boxes = new List<PostBox>();

		foreach (var child in this.imagesGrid.get_children())
			this.imagesGrid.remove(child);

		this.srcImages = new GLib.List<Pixbuf>();

		this.postsWindow.get_vadjustment().set_value(0);
		this.imagesWindow.get_vadjustment().set_value(0);	

		this.show_all();
	}
}