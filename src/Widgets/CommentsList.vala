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
			this.commentBox.set_size_request(625, -1);
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
		box.removeCommentButton.clicked.connect(() => {
			removeComment(box);		
		});
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
		box.removeCommentButton.clicked.connect(() => {
			removeComment(box);		
		});
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

		string commentContains = commentBox.get_text();
		commentBox.set_text("");

		string response = postComment(postId, commentContains);
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

	private void removeComment(CommentBox box)
    {
		Gtk.MessageDialog msg = new Gtk.MessageDialog (null, Gtk.DialogFlags.MODAL, 
												Gtk.MessageType.QUESTION, Gtk.ButtonsType.OK_CANCEL, 
												"Are you sure you want to remove this comment: \n" + box.comment.text + "?");
		msg.response.connect ((response_id) => {
			bool allowedToUnfollow = (response_id == Gtk.ResponseType.OK);

			msg.destroy();

			if (!allowedToUnfollow)
				return;
			else
				new Thread<int>("", () => {
	        		removeCommentReally(box);
	        		return 0;
	        	});				
		});
		msg.show ();
	}

	public void removeCommentReally(CommentBox box)
	{
		string response = deleteComment(postId, box.comment.id);
		try
		{
			parseErrors(response);
		}
		catch (Error e)
		{
			error("Something wrong with JSON parsing.");
		}

		Idle.add(() => {
			foreach (var child in this.get_children())
				if ((CommentBox)((Gtk.ListBoxRow)child).get_child() == box)
				{
					((Gtk.ListBoxRow)child).remove(box);
					break;
				}
			comments.remove(box);
			return false;
		});
	}
}