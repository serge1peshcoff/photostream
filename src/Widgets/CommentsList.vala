using PhotoStream.Utils;
public class PhotoStream.Widgets.CommentsList : Gtk.ListBox
{
	public GLib.List<CommentBox> comments;
	public Gtk.LinkButton loadMoreButton;
	public Gtk.Box moreBox;
	public string postId;
	public Gtk.Entry commentBox;
	public Gtk.Alignment commentsBoxAlignment;

	public int commentsPosted = 0;

	public bool loadAvatars;

	public CommentsList()
	{
		loadAvatars = false;	
		initFields();
	}
	public CommentsList.withAvatars()
	{
		loadAvatars = true;	
		initFields();
	}

	private void initFields()
	{
		this.comments = new GLib.List<CommentBox>();
		this.set_selection_mode (Gtk.SelectionMode.NONE);

		this.commentsBoxAlignment = new Gtk.Alignment (1,0,1,1);
        this.commentsBoxAlignment.top_padding = 1;
        this.commentsBoxAlignment.right_padding = 0;
        this.commentsBoxAlignment.bottom_padding = 1;
        this.commentsBoxAlignment.left_padding = 0;

		this.commentBox = new Gtk.Entry();

		this.commentBox.activate.connect(() => {
			new Thread<int>("", () => {
				postCommentCallback();
				return 0;
			});			
		});

		Idle.add(() => {
			this.commentsBoxAlignment.add(commentBox);
			base.insert(commentsBoxAlignment, -1);
			this.show_all();
			return false;
		});		
	}

	public void addMoreButton(int64 commentsCount)
	{
		this.moreBox = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 0);
		this.loadMoreButton = new Gtk.LinkButton("Load all " + commentsCount.to_string() + " comments");

		this.moreBox.add(loadMoreButton);
		base.prepend(moreBox);
	}

	public void append(Comment post)
	{
		CommentBox box = new CommentBox(post, loadAvatars);
		base.prepend(box);
		comments.append(box);
		commentsPosted++;
		box.textEventBox.button_release_event.connect(() => {
			mentionUser(box.comment.user.username);
			return false;
		});		
	}

	public new void prepend(Comment post)
	{
		CommentBox box = new CommentBox(post, loadAvatars);	
		base.insert (box, commentsPosted);
		comments.append(box);
		commentsPosted++;
		box.textEventBox.button_release_event.connect(() => {
			mentionUser(box.comment.user.username);
			return false;
		});
		this.show_all();
	}

	public void mentionUser(string username)
	{
		commentBox.set_text(commentBox.get_text() + "@" + username + " ");
	}

	public void clear()
	{
		foreach (var child in this.get_children())
			if (((Gtk.ListBoxRow) child).get_child() is CommentBox)
				Idle.add (() => {
					this.remove(child);
					return false;
				});

		this.comments = new List<CommentBox>();	
	}
	private void postCommentCallback()
	{
		if (commentBox.get_text().strip() == "")
			return;

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
			this.prepend(commentReply);
			this.show_all();
			return false;
		});
	}
}