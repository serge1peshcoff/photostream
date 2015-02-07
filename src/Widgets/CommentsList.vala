using PhotoStream.Utils;
public class PhotoStream.Widgets.CommentsList : Gtk.Box
{
	public GLib.List<CommentBox> comments;
	public Gtk.LinkButton loadMoreButton;
	public string postId;
	public Gtk.Entry commentBox;
	public Gtk.Alignment commentsBoxAlignment;

	public Gtk.Box containerBox;
	public Gtk.ScrolledWindow commentsWindow;
	public Gtk.Grid commentsList;

	public int commentsPosted = 0;

	public const int REFRESH_INTERVAL = 10;
	private bool isActive = false;

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
		var rgba = Gdk.RGBA();
		rgba.red = 1;
		rgba.green = 1;
		rgba.blue = 1;
		rgba.alpha = 1;
		this.override_background_color(Gtk.StateFlags.NORMAL, rgba);

		this.containerBox = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
		this.comments = new GLib.List<CommentBox>();

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

		this.commentsList = new Gtk.Grid();

		if (loadAvatars)
		{
			this.commentsWindow = new Gtk.ScrolledWindow(null, null);
			commentsWindow.set_policy(Gtk.PolicyType.NEVER, Gtk.PolicyType.AUTOMATIC);
					
			this.commentsWindow.add_with_viewport(commentsList);
			this.containerBox.pack_start(commentsWindow, true, true);	
		}	
		else
		{
			this.containerBox.pack_start(commentsList, true, true);	
		}		

		this.pack_start(containerBox, true, true);

		Idle.add(() => {
			this.commentBox.set_size_request(625, -1);
			this.commentsBoxAlignment.add(commentBox);
			this.containerBox.pack_end(commentsBoxAlignment, false, true);
			this.show_all();
			return false;
		});		
	}

	public void loadComments(string postId)
	{
		this.postId = postId;

		string response = getComments(postId);
        List<Comment> commentsListRequested = new List<Comment>();

        try
        {
            commentsListRequested = parseComments(response);

        }
        catch (Error e)
        {
            error("Something wrong with parsing: " + e.message + ".\n");
        }
        Idle.add(() => {
        	loadCommentsFromList(commentsListRequested);
        	return false;
        });        
	}

	public void loadCommentsFromList(List<Comment> commentsListRequested)
	{
		this.clear();
        foreach(Comment comment in commentsListRequested)
            this.prepend(comment);

        new Thread<int>("", () => {
        	foreach (CommentBox box in comments)
        		box.loadAvatar();

        	return 0;
        });
        

        /*if (!isActive)
        {
        	GLib.Timeout.add_seconds(REFRESH_INTERVAL, () => {
	            new Thread<int>("", () => {
	                refreshComments();
	                return 0;
	            });                
	            return false;
	        });
	        isActive = false;
        }*/

	}

	public void refreshComments()
	{
		string newComments = getComments(this.postId);
		List<Comment> commentsList;
		try
		{
			commentsList = parseComments(newComments);
		}
		catch (Error e)
		{
			error("Something wrong with JSON parsing: %s.\n", e.message);
		}
		commentsList.reverse();

		foreach (Comment comment in commentsList)
		{
			this.append(comment);
			this.show_all();
		}

		GLib.Timeout.add_seconds(REFRESH_INTERVAL, () => {
            new Thread<int>("", () => {
                refreshComments();
                return 0;
            });                
            return false;
       });
	}

	public void addMoreButton(int64 commentsCount)
	{
		this.loadMoreButton = new Gtk.LinkButton("Load all " + commentsCount.to_string() + " comments");
		containerBox.pack_start(loadMoreButton, false, true);
		containerBox.reorder_child(loadMoreButton, 0);
	}

	public void append(Comment post)
	{
		CommentBox box = new CommentBox(post, loadAvatars);
		box.removeCommentButton.clicked.connect(() => {
			removeComment(box);		
		});
		commentsList.insert_row(0);
		commentsList.attach(box, 0, 0, 1, 1);
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
		commentsList.attach(box, 0, commentsPosted, 1, 1);
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
		if (this.commentBox.get_text().index_of(username) == -1)
			commentBox.set_text(commentBox.get_text() + "@" + username + " ");
	}

	public void clear()
	{
		foreach (var child in comments)
			Idle.add (() => {
				this.commentsList.remove(child);
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
			foreach (var child in this.commentsList.get_children())
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