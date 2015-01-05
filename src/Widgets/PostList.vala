using PhotoStream.Utils;
using Gtk;

public class PhotoStream.Widgets.PostList : Gtk.Box
{
	public GLib.List<PostBox> boxes;
	public Gtk.Button moreButton;
	public Gtk.Alignment moreButtonAlignment;
	public string olderFeedLink;

	public Gtk.Stack stack;
	public Gtk.ListBox postList;
	public Gtk.Box imagesBox;

	public PostList()
	{
		this.stack = new Gtk.Stack();
		this.postList = new Gtk.ListBox();

		boxes = new GLib.List<PostBox>();	
		this.moreButton = new Gtk.Button.with_label("Load more...");	

		this.moreButtonAlignment = new Gtk.Alignment (1,0,1,0);
        this.moreButtonAlignment.add(moreButton);
        postList.prepend(this.moreButtonAlignment);

		this.postList.set_selection_mode (Gtk.SelectionMode.NONE);
		this.postList.activate_on_single_click = false;

		this.imagesBox = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);

		this.stack.add_named(postList, "posts");
		this.stack.add_named(imagesBox, "images");
		this.add(stack);
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
	}

	public new void prepend(MediaInfo post)
	{
		Gtk.Separator separator = new Gtk.Separator (Gtk.Orientation.HORIZONTAL);
		postList.insert (separator, (int) this.get_children().length () - 1);
		PostBox box = new PostBox(post);

		var listBoxRow = new Gtk.ListBoxRow();
		//listBoxRow.set_selectable(false);
		listBoxRow.add(box);
		postList.insert (listBoxRow, (int) this.get_children().length () - 1);
		boxes.append(box);			
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