using PhotoStream.Utils;
using Gtk;
using Gdk;

public class PhotoStream.Widgets.PostList : Gtk.Box
{
	public GLib.List<PostBox> boxes;
	public Gtk.Button moreButton;
	public Gtk.Alignment moreButtonAlignment;
	public Gtk.Button moreButtonImages;
	public Gtk.Alignment moreButtonImagesAlignment;
	public string olderFeedLink;
	public int IMAGE_SIZE;


	public Gtk.Stack stack;
	public Gtk.ListBox postList;
	public Gtk.Box imagesBox;
	public Gtk.Grid imagesGrid;

	public PostList()
	{
		IMAGE_SIZE = (this.get_root_window().get_width() - 10) / 3;

		this.stack = new Gtk.Stack();
		this.postList = new Gtk.ListBox();

		boxes = new GLib.List<PostBox>();	
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

		this.stack.add_named(postList, "posts");
		//this.stack.add_named(imagesBox,  "images");
		this.stack.set_visible_child_name("images");
		this.add(stack);	
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

		this.stack.set_visible_child_name("images");
		this.show_all();
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

		box.imageLoaded.connect((post) => {
			var imageFileName = PhotoStream.App.CACHE_URL + getFileName(post.type == PhotoStream.MediaType.VIDEO 
																		? post.media.previewUrl 
																		: post.media.url);

			int index = boxes.index(box);

			Pixbuf imagePixbuf; 
        	Pixbuf videoPixbuf;
	        try 
	        {
	        	imagePixbuf = new Pixbuf.from_file(imageFileName);
	        	imagePixbuf = imagePixbuf.scale_simple(IMAGE_SIZE, IMAGE_SIZE, Gdk.InterpType.BILINEAR);
	        	if (post.type == PhotoStream.MediaType.VIDEO)
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
			
			
			Image tmpImage = new Image.from_pixbuf(imagePixbuf);
			imagesGrid.attach(tmpImage, index % 3, index / 3, 1, 1);
			this.show_all();
		});	

		this.stack.set_visible_child_name("images");	
		this.show_all();	
	}

	public void clear()
	{
		foreach (var child in this.postList.get_children())
			if (!(((Gtk.ListBoxRow) child).get_child() is Gtk.Alignment)) // we don't want to remove "add more" button, right?
				this.postList.remove(child);

		this.boxes = new List<PostBox>();

		if (!this.moreButtonAlignment.is_ancestor(this.postList) && this.olderFeedLink != "")
			postList.prepend(this.moreButtonAlignment);

		
	}
}