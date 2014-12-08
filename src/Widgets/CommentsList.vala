using PhotoStream.Utils;
public class PhotoStream.Widgets.CommentsList : Gtk.ListBox
{
	public GLib.List<CommentBox> comments;
	public Gtk.LinkButton loadMoreButton;
	public Gtk.Box moreBox;
	public string postId;
	public Gtk.Entry commentBox;

	public void addMoreButton(int64 commentsCount)
	{
		this.moreBox = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 0);
		this.loadMoreButton = new Gtk.LinkButton("Load all " + commentsCount.to_string() + " comments");

		this.moreBox.add(loadMoreButton);
		base.prepend(moreBox);
	}

	public CommentsList()
	{
		this.comments = new GLib.List<CommentBox>();
		this.set_selection_mode (Gtk.SelectionMode.NONE);

		this.commentBox = new Gtk.Entry();
		Idle.add(() => {
			base.insert(commentBox, -1);
			this.show_all();
			return false;
		});

		this.commentBox.activate.connect(() => {
			new Thread<int>("", () => {
				postCommentCallback();
				return 0;
			});			
		});
		
	}
	public void append(Comment post, bool withAvatar)
	{
		CommentBox box = new CommentBox(post, withAvatar);
		base.prepend(box);
		comments.append(box);		
	}

	public new void prepend(Comment post, bool withAvatar)
	{
		CommentBox box = new CommentBox(post, withAvatar);
		base.insert (box, -1);
		comments.append(box);			
	}

	public void clear()
	{
		foreach (var child in this.get_children())
			this.remove(child);
		this.comments = new List<CommentBox>();

		base.insert(commentBox, -1);
		this.show_all();
	}
	private void postCommentCallback()
	{
		string response = postComment(postId, commentBox.get_text());
		Comment commentReply;
		try
		{
			commentReply = parseCommentFromReply(response);
		}
		catch (Error e)
		{
			error("Something wrong with JSON parsing.");
		}
		Idle.add(() => {
			this.prepend(commentReply, false);
			this.show_all();
			return false;
		});
	}
}