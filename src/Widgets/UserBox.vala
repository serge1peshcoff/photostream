using PhotoStream.Utils;
using PhotoStream.Widgets;
using Gdk;

public class PhotoStream.Widgets.UserBox : Gtk.EventBox
{
	public Gtk.Box box;

	public Gtk.Box userToolbar;
	public Gtk.Label userNameLabel;
	public Gtk.Label titleLabel;
	public Image avatarImage;
	public Gtk.EventBox avatarBox;
	public const int AVATAR_SIZE = 70;

	public Gtk.Alignment relationshipAlignment;
	public Gtk.EventBox relationshipBox;
	public Gtk.Image relationshipImage;

	public Pixbuf followingPixbuf;
	public Pixbuf notFollowingPixbuf;
	public Pixbuf unfollowPixbuf;
	public Pixbuf followPixbuf;
	public Pixbuf requestedPixbuf;

	public CommentsList commentList;

	public User user;

	public const int RELATIONSHIP_WIDTH = 100;
	public const int RELATIONSHIP_HEIGHT = 20;

	private bool relationshipHandlersSet = false;

	public UserBox(User user)
	{
		box = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 0);
		this.add(box);

		try 
		{
			this.followingPixbuf = new Pixbuf.from_file(PhotoStream.App.CACHE_IMAGES + "following.png");
			this.notFollowingPixbuf = new Pixbuf.from_file(PhotoStream.App.CACHE_IMAGES + "not-following.png");
			this.unfollowPixbuf = new Pixbuf.from_file(PhotoStream.App.CACHE_IMAGES + "unfollow.png");
			this.followPixbuf = new Pixbuf.from_file(PhotoStream.App.CACHE_IMAGES + "follow.png");
			this.requestedPixbuf = new Pixbuf.from_file(PhotoStream.App.CACHE_IMAGES + "requested.png");
		}
		catch(Error e)
		{
			GLib.error("Something wrong with file loading.");
		}

		set_events (Gdk.EventMask.BUTTON_RELEASE_MASK);

		this.relationshipAlignment = new Gtk.Alignment (1,0,1,1);
        this.relationshipAlignment.top_padding = 6;
        this.relationshipAlignment.right_padding = 6;
        this.relationshipAlignment.bottom_padding = 0;
        this.relationshipAlignment.left_padding = 6;

		this.relationshipBox = new Gtk.EventBox();
		this.relationshipBox.set_valign(Gtk.Align.CENTER);
		this.relationshipBox.set_events (Gdk.EventMask.BUTTON_RELEASE_MASK);
		this.relationshipBox.set_events(Gdk.EventMask.ENTER_NOTIFY_MASK);
        this.relationshipBox.set_events(Gdk.EventMask.LEAVE_NOTIFY_MASK);
		this.relationshipImage = new Gtk.Image();
		this.relationshipBox.add(relationshipImage);
		this.relationshipAlignment.add(relationshipBox);
		this.box.pack_end(relationshipAlignment, false, false);

		this.user = user;

		this.avatarImage = new Image(AVATAR_SIZE);
		this.avatarBox = new Gtk.EventBox();
		avatarBox.add(avatarImage);
		this.box.add(avatarBox);

		this.userNameLabel = new Gtk.Label("");
		if (user.fullName == "")
			userNameLabel.set_markup(wrapInTags("@" + user.username));
		else
			userNameLabel.set_markup("<b>" + GLib.Markup.escape_text(user.fullName) + "</b> (" + wrapInTags("@" + user.username) + ")");

		this.box.add(userNameLabel);
	}

	public void loadAvatar()
	{
		avatarImage.download(user.profilePicture, PhotoStream.App.CACHE_IMAGES + "avatar-mask.png", true);
	}

    public void loadRelationship()
	{
		if (user.id != PhotoStream.App.selfUser.id)
		{
			Pixbuf relationshipPixbuf;
        	switch (user.relationship.outcoming)
        	{
        		case "follows":
        			relationshipPixbuf = followingPixbuf;
        			break;
        		case "none":
        			relationshipPixbuf = notFollowingPixbuf;
        			break;
        		case "requested":
        			relationshipPixbuf = requestedPixbuf;
        			break;
        		default:
        			error("Should've not reached here.");
        	}

	        relationshipPixbuf = relationshipPixbuf.scale_simple(RELATIONSHIP_WIDTH, RELATIONSHIP_HEIGHT, Gdk.InterpType.BILINEAR);
	        relationshipImage.set_from_pixbuf(relationshipPixbuf);

	        if (!relationshipHandlersSet)
	        {
		        relationshipBox.enter_notify_event.connect((event) => {
		        	onHover(event);
		        	return false;
		        });
		        relationshipBox.leave_notify_event.connect((event) => {
		        	onHoverOut(event);
		        	return false;
		        });

		        relationshipBox.button_release_event.connect(() => {
		        	confirmChangingRelationship();
		        	return false;
		        });
		    }
		    relationshipHandlersSet = true;
	    }
	    else
	    	relationshipImage.clear();
	}

	private void onHover(EventCrossing event)
    {
    	event.window.set_cursor (
            new Gdk.Cursor.from_name (Gdk.Display.get_default(), "hand2")
        );

		Pixbuf relationshipPixbuf;
		if (user.relationship.outcoming == "follows" || user.relationship.outcoming == "requested")
			relationshipPixbuf = unfollowPixbuf;
		else if (user.relationship.outcoming == "none")
			relationshipPixbuf = followPixbuf;
		else
			error("Should've not reached here.");

        relationshipPixbuf = relationshipPixbuf.scale_simple(RELATIONSHIP_WIDTH, RELATIONSHIP_HEIGHT, Gdk.InterpType.BILINEAR);
        relationshipImage.set_from_pixbuf(relationshipPixbuf);
    }
    private void onHoverOut(EventCrossing event)
    {
    	Pixbuf relationshipPixbuf;
		if (user.relationship.outcoming == "follows")
			relationshipPixbuf = followingPixbuf;
		else if (user.relationship.outcoming == "none")
			relationshipPixbuf = notFollowingPixbuf;
		else if (user.relationship.outcoming == "requested")
			relationshipPixbuf = requestedPixbuf;
		else
			error("Should've not reached here.");

        relationshipPixbuf = relationshipPixbuf.scale_simple(RELATIONSHIP_WIDTH, RELATIONSHIP_HEIGHT, Gdk.InterpType.BILINEAR);
        relationshipImage.set_from_pixbuf(relationshipPixbuf);
    }

    private void confirmChangingRelationship()
    {
    	string action;
		switch (user.relationship.outcoming)
		{
			case "follows":
			case "requested":
        		action = "unfollow";
        		break;
    		case "none":
    			action = "follow";
    			break;
    		default:
    			error("Should've not reached here.");
		}

		if (action == "unfollow") // make sure user want to unfollow
		{
			Gtk.MessageDialog msg = new Gtk.MessageDialog (null, Gtk.DialogFlags.MODAL, 
													Gtk.MessageType.QUESTION, Gtk.ButtonsType.OK_CANCEL, 
													"Are you sure you want to unfollow @" + user.username + "?");
			msg.response.connect ((response_id) => {
				bool allowedToUnfollow = (response_id == Gtk.ResponseType.OK);

				msg.destroy();

				if (!allowedToUnfollow)
					return;
				else
					new Thread<int>("", () => {
		        		changeRelationshipReally(action);
		        		return 0;
		        	});				
			});
			msg.show ();
		}
		else // following
			new Thread<int>("", () => {
        		changeRelationshipReally(action);
        		return 0;
        	});

    }

    private void changeRelationshipReally(string action)
    {
		// user agreed, continue unfollowing
		// or not unfollowing but following.

		string relationshipInfo = relationshipAction(this.user.id, action);
        Relationship relationship = null;

        try
        {
            relationship = parseRelationship(relationshipInfo);      
            user.relationship = relationship;
        }
        catch (Error e) // wrong token
        {
            error("Something wrong with parsing: " + e.message + ".\n");
        }

        Idle.add(() => {
        	this.loadRelationship();
        	return false;
        });
        
    }

}